import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/app_scaffold.dart';
import '../config.dart';
import 'payment_screen.dart';

class PaymentPersonnelListScreen extends StatefulWidget {
  @override
  _PaymentPersonnelListScreenState createState() => _PaymentPersonnelListScreenState();
}

class _PaymentPersonnelListScreenState extends State<PaymentPersonnelListScreen> {
  List personnelList = [];
  bool loading = true;
  String? message;

  Future<void> fetchPersonnel() async {
    setState(() {
      loading = true;
      message = null;
    });

    try {
      // 🔹 correction backendUrl()
      final res = await http.get(Uri.parse(backendUrl('personnel')));
      if (res.headers['content-type']?.contains('application/json') != true) {
        setState(() => message = "Erreur réseau: réponse inattendue du serveur (HTML reçu)");
        return;
      }

      final data = jsonDecode(res.body);
      if (data['ok'] == true) {
        setState(() => personnelList = data['list']);
      } else {
        setState(() => message = data['error'] ?? "Erreur inconnue");
      }
    } catch (e) {
      setState(() => message = "Erreur fetch personnel: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPersonnel();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Paiement Personnel',
      child: loading
          ? Center(child: CircularProgressIndicator())
          : message != null
              ? Center(child: Text(message!))
              : ListView.builder(
                  itemCount: personnelList.length,
                  itemBuilder: (_, i) {
                    final p = personnelList[i];
                    return ListTile(
                      title: Text(p['fullName'] ?? ''),
                      subtitle: Text("Salaire: \$${p['salary'] ?? 0}"),
                      trailing: IconButton(
                        icon: Icon(Icons.payments),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentScreen(personnel: p),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
