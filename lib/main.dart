import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
void main() => runApp(MyFloatApp());
class MyFloatApp extends StatelessWidget {
  @override Widget build(BuildContext context) {
    return MaterialApp(title: 'My Float', theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true), debugShowCheckedModeBanner: false, home: FloatHome());
  }
}
class FloatHome extends StatefulWidget {
  @override State<FloatHome> createState() => _FloatHomeState();
}
class _FloatHomeState extends State<FloatHome> {
  double balance = 0; List<Map<String,dynamic>> txs = [];
  @override void initState() { super.initState(); loadData(); }
  loadData() async {
    final p = await SharedPreferences.getInstance();
    setState(() { balance = p.getDouble('balance') ?? 0; String? j = p.getString('txs'); if(j!=null) txs = List<Map<String,dynamic>>.from(json.decode(j)); });
  }
  saveData() async {
    final p = await SharedPreferences.getInstance();
    p.setDouble('balance', balance); p.setString('txs', json.encode(txs));
  }
  void addTx(double amount, bool isIn) {
    setState(() { balance += isIn ? amount : -amount; txs.insert(0, {'amount': amount, 'isIn': isIn, 'time': DateTime.now().toIso8601String()}); });
    saveData();
  }
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Float'), backgroundColor: Colors.green, foregroundColor: Colors.white, centerTitle: true),
      body: Column(children: [
        Container(width: double.infinity, margin: EdgeInsets.all(16), padding: EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
          child: Column(children: [Text('CURRENT FLOAT', style: TextStyle(color: Colors.white70, letterSpacing: 2)), SizedBox(height: 8), Text('KES ${NumberFormat('#,###').format(balance)}', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold))])),
        Expanded(child: txs.isEmpty ? Center(child: Text('No transactions yet\nTap + IN / OUT', textAlign: TextAlign.center)) : ListView.builder(itemCount: txs.length, itemBuilder: (c,i){
            final t = txs[i]; return ListTile(leading: CircleAvatar(backgroundColor: t['isIn'] ? Colors.green[100] : Colors.red[100], child: Icon(t['isIn'] ? Icons.arrow_downward : Icons.arrow_upward, color: t['isIn'] ? Colors.green : Colors.red)), title: Text('${t['isIn'] ? 'Float IN' : 'Float OUT'} - KES ${t['amount']}'), subtitle: Text(DateFormat('MMM dd, hh:mm a').format(DateTime.parse(t['time']))));
          })),
      ]),
      floatingActionButton: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        FloatingActionButton.extended(onPressed: () => showAdd(false), label: Text('OUT'), icon: Icon(Icons.remove), backgroundColor: Colors.red, heroTag: 'out'),
        SizedBox(width: 10),
        FloatingActionButton.extended(onPressed: () => showAdd(true), label: Text('IN'), icon: Icon(Icons.add), backgroundColor: Colors.green, heroTag: 'in'),
      ]),
    );
  }
  showAdd(bool isIn) {
    TextEditingController ctrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(isIn ? 'Add Float IN' : 'Add Float OUT'),
      content: TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Amount KES', border: OutlineInputBorder())),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')), ElevatedButton(onPressed: () { double? amt = double.tryParse(ctrl.text); if(amt != null) addTx(amt, isIn); Navigator.pop(context); }, child: Text('Save'))],
    ));
  }
}
