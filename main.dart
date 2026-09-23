import 'package:flutter/material.dart';

void main() => runApp(const SwiftEasyApp());

class SwiftEasyApp extends StatelessWidget {
  const SwiftEasyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Swift Easy',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
    home: const Home(),
  );
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final date = TextEditingController();
  final payee = TextEditingController();
  final amount = TextEditingController();
  final cheque = TextEditingController();
  double left = 10, top = 10;
  String bank = 'Standard';

  @override void dispose() {
    date.dispose(); payee.dispose(); amount.dispose(); cheque.dispose(); super.dispose();
  }

  void alignment() {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Alignment Settings'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Left: ${left.toStringAsFixed(1)} mm'),
        Slider(min: 0, max: 50, value: left, onChanged: (v) => setState(() => left = v)),
        Text('Top: ${top.toStringAsFixed(1)} mm'),
        Slider(min: 0, max: 50, value: top, onChanged: (v) => setState(() => top = v)),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Swift Easy'),
      actions: [IconButton(onPressed: alignment, icon: const Icon(Icons.tune))]),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      DropdownButtonFormField<String>(
        value: bank,
        decoration: const InputDecoration(labelText: 'Bank Template'),
        items: const ['Standard','Emirates NBD','ADCB','FAB']
          .map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
        onChanged: (v) => setState(() => bank = v ?? 'Standard'),
      ),
      const SizedBox(height: 12),
      TextField(controller: date, decoration: const InputDecoration(labelText: 'Date')),
      const SizedBox(height: 12),
      TextField(controller: payee, decoration: const InputDecoration(labelText: 'Payee')),
      const SizedBox(height: 12),
      TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(labelText: 'Amount (AED)')),
      const SizedBox(height: 12),
      TextField(controller: cheque, decoration: const InputDecoration(labelText: 'Cheque No.')),
      const SizedBox(height: 20),
      FilledButton.icon(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cheque preview module ready to be connected.'))),
        icon: const Icon(Icons.preview), label: const Text('Preview Cheque')),
      const SizedBox(height: 10),
      OutlinedButton.icon(onPressed: alignment, icon: const Icon(Icons.tune),
        label: const Text('Alignment Settings')),
      const SizedBox(height: 20),
      const Card(child: Padding(padding: EdgeInsets.all(16),
        child: Text('Cheque size: 205 × 127 mm'))),
    ]),
  );
}
