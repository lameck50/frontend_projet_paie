import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class PaymentScreen extends StatefulWidget {
  final Map personnel;
  PaymentScreen({required this.personnel});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool loading = false;
  String? message;

  Future<void> pay() async {
    setState(() => {loading = true, message = null});

    try {
      // 🔹 correction backendUrl()
      final res = await http.post(Uri.parse(backendUrl('payment/airtel')),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'personnelId': widget.personnel['_id']}));

      final data = jsonDecode(res.body);

      if (data['ok'] == true) {
        setState(() => message = "Paiement effectué !");
      } else {
        setState(() => message = data['error'] ?? "Erreur serveur");
      }
    } catch (e) {
      setState(() => message = "Erreur réseau: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Paiement ${widget.personnel['fullName']}')),
      body: Center(
        child: loading
            ? CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message != null) Text(message!),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: pay,
                    child: Text('Payer'),
                  )
                ],
              ),
      ),
    );
  }
}
