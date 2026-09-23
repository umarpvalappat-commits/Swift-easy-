import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const SwiftEasyApp());

class SwiftEasyApp extends StatelessWidget {
  const SwiftEasyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Swift Easy',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF172B4D)),
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const CustomerHome(),
    );
  }
}

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});
  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  final payee = TextEditingController();
  final amount = TextEditingController();
  final chequeNo = TextEditingController();
  final date = TextEditingController();

  String bank = 'Select Bank';
  double left = 0, top = 0, width = 205, height = 127;
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    payee.dispose();
    amount.dispose();
    chequeNo.dispose();
    date.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getStringList('history') ?? [];
    setState(() {
      history = raw.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    history.insert(0, {
      'payee': payee.text,
      'amount': amount.text,
      'date': date.text,
      'chequeNo': chequeNo.text,
      'bank': bank,
    });
    if (history.length > 100) history = history.sublist(0, 100);
    await p.setStringList('history', history.map(jsonEncode).toList());
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cheque saved')),
      );
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (d != null) {
      date.text = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      setState(() {});
    }
  }

  void _alignment() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Alignment Settings',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _slider('Left', left, -20, 20, (v) => setSheet(() => left = v)),
              _slider('Top', top, -20, 20, (v) => setSheet(() => top = v)),
              _slider('Width', width, 180, 220, (v) => setSheet(() => width = v)),
              _slider('Height', height, 110, 140, (v) => setSheet(() => height = v)),
              FilledButton(
                onPressed: () { setState(() {}); Navigator.pop(context); },
                child: const Text('Apply'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _slider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(1)} mm'),
        Slider(value: value, min: min, max: max, divisions: 80, onChanged: onChanged),
      ],
    );
  }

  void _preview() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cheque Preview'),
        content: SingleChildScrollView(
          child: AspectRatio(
            aspectRatio: 205 / 127,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Positioned(left: 8, top: 8, child: Text(bank, style: const TextStyle(fontWeight: FontWeight.bold))),
                  Positioned(right: 8, top: 8, child: Text(date.text)),
                  Positioned(left: 18, top: 55, child: Text('Pay: ${payee.text}')),
                  Positioned(left: 18, top: 88, child: Text(_words(double.tryParse(amount.text) ?? 0))),
                  Positioned(right: 12, top: 85, child: Text('AED ${amount.text}', style: const TextStyle(fontWeight: FontWeight.bold))),
                  Positioned(left: 18, bottom: 8, child: Text('Cheque No: ${chequeNo.text}')),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  String _words(double value) {
    final n = value.floor();
    final fils = ((value - n) * 100).round();
    final s = '${_num(n)} UAE Dirhams${fils > 0 ? ' and ${_num(fils)} Fils' : ''} Only';
    return s;
  }

  String _num(int n) {
    const a = ['', 'One','Two','Three','Four','Five','Six','Seven','Eight','Nine','Ten','Eleven','Twelve','Thirteen','Fourteen','Fifteen','Sixteen','Seventeen','Eighteen','Nineteen'];
    const b = ['', '', 'Twenty','Thirty','Forty','Fifty','Sixty','Seventy','Eighty','Ninety'];
    if (n == 0) return 'Zero';
    String small(int x) {
      if (x < 20) return a[x];
      if (x < 100) return b[x ~/ 10] + (x % 10 == 0 ? '' : ' ${a[x % 10]}');
      return '${a[x ~/ 100]} Hundred${x % 100 == 0 ? '' : ' ${small(x % 100)}'}';
    }
    if (n >= 1000000) return '${small(n ~/ 1000000)} Million${n % 1000000 == 0 ? '' : ' ${_num(n % 1000000)}'}';
    if (n >= 1000) return '${small(n ~/ 1000)} Thousand${n % 1000 == 0 ? '' : ' ${_num(n % 1000)}'}';
    return small(n);
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swift Easy', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: _alignment, icon: const Icon(Icons.tune), tooltip: 'Alignment'),
          IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryPage(items: history))), icon: const Icon(Icons.history)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(colors: [Color(0xFF172B4D), Color(0xFF345B9A)]),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Swift Easy Customer', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('Cheque printing & management', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: bank,
            decoration: _dec('Bank Template', Icons.account_balance),
            items: const [
              DropdownMenuItem(value: 'Select Bank', child: Text('Select Bank')),
              DropdownMenuItem(value: 'IndusInd Bank', child: Text('IndusInd Bank')),
              DropdownMenuItem(value: 'Emirates NBD', child: Text('Emirates NBD')),
              DropdownMenuItem(value: 'ADCB', child: Text('ADCB')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (v) => setState(() => bank = v ?? bank),
          ),
          const SizedBox(height: 12),
          TextField(controller: chequeNo, decoration: _dec('Cheque Number', Icons.confirmation_number_outlined)),
          const SizedBox(height: 12),
          TextField(controller: payee, decoration: _dec('Payee', Icons.person_outline)),
          const SizedBox(height: 12),
          TextField(
            controller: amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _dec('Amount (AED)', Icons.payments_outlined),
            onChanged: (_) => setState(() {}),
          ),
          if (amount.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_words(double.tryParse(amount.text) ?? 0), style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          const SizedBox(height: 12),
          TextField(controller: date, readOnly: true, onTap: _pickDate, decoration: _dec('Cheque Date', Icons.calendar_today)),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('Save'))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(onPressed: _preview, icon: const Icon(Icons.visibility), label: const Text('Preview'))),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(onPressed: _alignment, icon: const Icon(Icons.tune), label: const Text('Alignment Settings')),
        ],
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const HistoryPage({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cheque History')),
      body: items.isEmpty
          ? const Center(child: Text('No saved cheques'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => Card(
                child: ListTile(
                  title: Text(items[i]['payee'] ?? ''),
                  subtitle: Text('${items[i]['bank']} • ${items[i]['date']} • Cheque ${items[i]['chequeNo']}'),
                  trailing: Text('AED ${items[i]['amount']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
    );
  }
}