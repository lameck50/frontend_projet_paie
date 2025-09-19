import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/app_scaffold.dart';
import '../config.dart';

class PersonnelFormScreen extends StatefulWidget {
  final Map? personnelData;

  PersonnelFormScreen({this.personnelData});

  @override
  _PersonnelFormScreenState createState() => _PersonnelFormScreenState();
}

class _PersonnelFormScreenState extends State<PersonnelFormScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController(); // Ajout du contrôleur de mot de passe
  final _salaryController = TextEditingController();
  final _airtelController = TextEditingController();
  bool loading = false;
  String? message;

  @override
  void initState() {
    super.initState();
    if (widget.personnelData != null) {
      _nameController.text = widget.personnelData!['fullName'] ?? '';
      _phoneController.text = widget.personnelData!['phone'] ?? '';
      _salaryController.text = widget.personnelData!['salary']?.toString() ?? '';
      _airtelController.text = widget.personnelData!['airtelNumber'] ?? '';
      // Le mot de passe n'est pas pré-rempli pour la modification
    }
  }

  Future<void> submit() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim(); // Récupération du mot de passe
    final salaryText = _salaryController.text.trim();
    final airtel = _airtelController.text.trim();

    if (name.isEmpty) {
      setState(() => message = "Le nom complet est obligatoire");
      return;
    }
    if (phone.isEmpty) {
      setState(() => message = "Le numéro de téléphone est obligatoire");
      return;
    }
    // Le mot de passe est obligatoire uniquement à la création
    if (widget.personnelData == null && password.isEmpty) {
      setState(() => message = "Le mot de passe est obligatoire");
      return;
    }
    if (salaryText.isEmpty || double.tryParse(salaryText) == null) {
      setState(() => message = "Un salaire valide est obligatoire");
      return;
    }

    setState(() => {loading = true, message = null});

    try {
      final url = widget.personnelData != null
          ? backendUrl('personnel/${widget.personnelData!['_id']}')
          : backendUrl('personnel');

      final body = {
        'fullName': name,
        'phone': phone,
        'salary': double.parse(salaryText),
        'airtelNumber': airtel,
      };

      // Ajoute le mot de passe seulement s'il est fourni
      if (password.isNotEmpty) {
        body['password'] = password;
      }

      final res = await (widget.personnelData != null
          ? http.put(
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body),
            )
          : http.post(
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body),
            ));

      final data = jsonDecode(res.body);

      if (data['ok'] == true) {
        Navigator.pop(context, true);
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
      title: widget.personnelData != null ? 'Modifier Personnel' : 'Ajouter Personnel',
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nom complet'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'Téléphone'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: widget.personnelData != null ? 'Nouveau mot de passe (optionnel)' : 'Mot de passe'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _salaryController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Salaire'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _airtelController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'Numéro Airtel (optionnel)'),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : submit,
                  child: loading
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(widget.personnelData != null ? 'Modifier' : 'Ajouter'),
                ),
              ),
              if (message != null)
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    message!,
                    style: TextStyle(
                      color: message!.startsWith("Erreur") ? Colors.red : Colors.green,
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
