import 'package:flutter/material.dart';

void main() {
  runApp(const SwiftEasyApp());
}

class SwiftEasyApp extends StatelessWidget {
  const SwiftEasyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SwiftEasy',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      ),
      home: const SwiftEasyHomePage(),
    );
  }
}

class SwiftEasyHomePage extends StatefulWidget {
  const SwiftEasyHomePage({super.key});

  @override
  State<SwiftEasyHomePage> createState() => _SwiftEasyHomePageState();
}

class _SwiftEasyHomePageState extends State<SwiftEasyHomePage> {
  final _formKey = GlobalKey<FormState>();

  final _payeeController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();

  String _bank = 'Select Bank';
  String _amountWords = '';
  final List<Map<String, String>> _history = [];

  @override
  void dispose() {
    _payeeController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _updateAmountWords(String value) {
    final amount = double.tryParse(value.replaceAll(',', ''));
    setState(() {
      _amountWords = amount == null ? '' : _aedWords(amount);
    });
  }

  String _aedWords(double amount) {
    final dirhams = amount.floor();
    final fils = ((amount - dirhams) * 100).round();
    final result = '${_numberToWords(dirhams)} UAE Dirhams'
        '${fils > 0 ? ' and ${_numberToWords(fils)} Fils' : ''} Only';
    return result;
  }

  String _numberToWords(int n) {
    if (n == 0) return 'Zero';
    const ones = [
      '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight',
      'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen',
      'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'
    ];
    const tens = [
      '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy',
      'Eighty', 'Ninety'
    ];

    String belowThousand(int x) {
      var s = '';
      if (x >= 100) {
        s += '${ones[x ~/ 100]} Hundred';
        x %= 100;
        if (x > 0) s += ' ';
      }
      if (x >= 20) {
        s += tens[x ~/ 10];
        x %= 10;
        if (x > 0) s += ' ${ones[x]}';
      } else if (x > 0) {
        s += ones[x];
      }
      return s;
    }

    if (n >= 1000000) {
      final m = n ~/ 1000000;
      final r = n % 1000000;
      return '${belowThousand(m)} Million${r > 0 ? ' ${_numberToWords(r)}' : ''}';
    }
    if (n >= 1000) {
      final t = n ~/ 1000;
      final r = n % 1000;
      return '${belowThousand(t)} Thousand${r > 0 ? ' ${belowThousand(r)}' : ''}';
    }
    return belowThousand(n);
  }

  void _saveCheque() {
    if (!_formKey.currentState!.validate()) return;
    final payee = _payeeController.text.trim();
    final amount = _amountController.text.trim();

    setState(() {
      _history.insert(0, {
        'payee': payee,
        'amount': amount,
        'date': _dateController.text.trim(),
        'bank': _bank,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cheque saved to history')),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            '${picked.day.toString().padLeft(2, '0')}/'
            '${picked.month.toString().padLeft(2, '0')}/'
            '${picked.year}';
      });
    }
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * .75,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'Cheque History',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: _history.isEmpty
                    ? const Center(child: Text('No saved cheques yet'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _history.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final item = _history[i];
                          return ListTile(
                            tileColor: const Color(0xFFF1F3F8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            title: Text(item['payee'] ?? ''),
                            subtitle: Text(
                              '${item['bank']} • ${item['date']}',
                            ),
                            trailing: Text(
                              'AED ${item['amount']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 18,
        title: const Text(
          'SwiftEasy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'History',
            onPressed: _showHistory,
            icon: const Icon(Icons.history),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3949AB), Color(0xFF5C6BC0)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cheque Printing',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Create and manage your cheque details',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              DropdownButtonFormField<String>(
                value: _bank,
                decoration: _decoration('Bank', Icons.account_balance),
                items: const [
                  DropdownMenuItem(
                    value: 'Select Bank',
                    child: Text('Select Bank'),
                  ),
                  DropdownMenuItem(
                    value: 'IndusInd Bank',
                    child: Text('IndusInd Bank'),
                  ),
                  DropdownMenuItem(
                    value: 'Emirates NBD',
                    child: Text('Emirates NBD'),
                  ),
                  DropdownMenuItem(
                    value: 'ADCB',
                    child: Text('ADCB'),
                  ),
                  DropdownMenuItem(
                    value: 'Other',
                    child: Text('Other'),
                  ),
                ],
                onChanged: (v) => setState(() => _bank = v ?? 'Select Bank'),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _payeeController,
                decoration: _decoration('Payee Name', Icons.person_outline),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter payee name' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: _updateAmountWords,
                decoration: _decoration('Amount (AED)', Icons.payments_outlined),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter amount';
                  if (double.tryParse(v.replaceAll(',', '')) == null) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              if (_amountWords.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _amountWords,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _pickDate,
                decoration: _decoration('Cheque Date', Icons.calendar_today),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Select date' : null,
              ),
              const SizedBox(height: 18),

              FilledButton.icon(
                onPressed: _saveCheque,
                icon: const Icon(Icons.save_outlined),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 13),
                  child: Text(
                    'Save Cheque',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              OutlinedButton.icon(
                onPressed: _showHistory,
                icon: const Icon(Icons.history),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('History / Reprint'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
