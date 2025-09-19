import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_scaffold.dart';
import '../config.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool loading = false;
  String? message;

  Future<void> login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => message = "Tous les champs sont obligatoires");
      return;
    }

    setState(() => {loading = true, message = null});

    try {
      // 🔹 Correction: utilisation de backendUrl() au lieu de $backend
      final resp = await http.post(
        Uri.parse(backendUrl('auth/login')),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (resp.headers['content-type']?.contains('application/json') != true) {
        setState(() =>
            message = "Erreur réseau: réponse inattendue du serveur (HTML reçu)");
        return;
      }

      final data = jsonDecode(resp.body);

      if ((resp.statusCode == 200 || resp.statusCode == 201) && data['ok'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('adminName', data['user']?['name'] ?? '');

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomeScreen()));
      } else {
        setState(() => message = data['error'] ?? 'Erreur: ${resp.statusCode}');
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
      title: 'Connexion',
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email), labelText: 'Email')),
              SizedBox(height: 12),
              TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock), labelText: 'Mot de passe')),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : login,
                  child: loading
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text("Se connecter"),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => RegisterScreen())),
                child: Text("Créer un compte"),
              ),
              if (message != null)
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(message!,
                      style: TextStyle(
                          color:
                              message!.startsWith("Erreur") ? Colors.red : Colors.green)),
                )
            ],
          ),
        ),
      ),
    );
  }
}
