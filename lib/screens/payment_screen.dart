import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../widgets/app_scaffold.dart';

class PaymentScreen extends StatefulWidget {
  final Map personnel;
  PaymentScreen({required this.personnel});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool loading = false;
  String? message;

  @override
  void initState() {
    super.initState();
    // Pré-remplir la description avec le salaire pour plus de commodité
    final salary = widget.personnel['salary'] ?? 0;
    _descriptionController.text = 'Paiement salaire';
    _amountController.text = salary.toString();
  }

  Future<void> pay() async {
    final amountText = _amountController.text.trim();
    final description = _descriptionController.text.trim();

    if (amountText.isEmpty || double.tryParse(amountText) == null || double.parse(amountText) <= 0) {
      setState(() => message = "Veuillez entrer un montant valide.");
      return;
    }

    setState(() { loading = true; message = null; });

    try {
      final body = {
        'personnelId': widget.personnel['_id'],
        'amount': double.parse(amountText),
        'description': description,
        'airtelNumber': widget.personnel['airtelNumber'] ?? widget.personnel['phone'], // Utilise le numéro airtel ou le tel principal
      };

      final res = await http.post(
        Uri.parse(backendUrl('payment/airtel')),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(res.body);

      if (data['ok'] == true) {
        setState(() => message = "Paiement effectué avec succès !");
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
    return AppScaffold(
      title: 'Payer ${widget.personnel['fullName']}',
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Montant à payer'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 20),
              if (message != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    message!,
                    style: TextStyle(color: message!.contains("succès") ? Colors.green : Colors.red),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : pay,
                  child: loading
                      ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Confirmer le Paiement'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}