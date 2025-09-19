import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config.dart';
import '../widgets/app_scaffold.dart';
import 'employee_dashboard_screen.dart'; // Sera créé ensuite

class PersonnelLoginScreen extends StatefulWidget {
  @override
  _PersonnelLoginScreenState createState() => _PersonnelLoginScreenState();
}

class _PersonnelLoginScreenState extends State<PersonnelLoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool loading = false;
  String? message;

  Future<void> login() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      setState(() => message = "Téléphone et mot de passe obligatoires");
      return;
    }

    setState(() { loading = true; message = null; });

    try {
      final res = await http.post(
        Uri.parse(backendUrl('auth/personnel/login')),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'password': password,
        }),
      );

      final data = jsonDecode(res.body);

      if (data['ok'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user_role', 'personnel'); // Stocker le rôle

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => EmployeeDashboardScreen()),
        );
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
      title: 'Espace Employé',
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Connectez-vous pour voir vos informations', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 24),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'Numéro de téléphone'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Mot de passe'),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : login,
                  child: loading
                      ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Connexion'),
                ),
              ),
              if (message != null)
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    message!,
                    style: TextStyle(color: Colors.red),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
