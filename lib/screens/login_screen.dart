import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_scaffold.dart';
import '../config.dart';
import 'home_screen.dart';
import 'employee_dashboard_screen.dart';
import 'register_screen.dart';

enum LoginType { admin, employee }

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginType _selectedLogin = LoginType.admin;

  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool loading = false;
  String? message;

  Future<void> submit() async {
    if (_selectedLogin == LoginType.admin) {
      await _adminLogin();
    } else {
      await _personnelLogin();
    }
  }

  Future<void> _adminLogin() async {
    final email = _identifierController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      setState(() => message = "Email et mot de passe obligatoires");
      return;
    }

    setState(() { loading = true; message = null; });

    try {
      final resp = await http.post(
        Uri.parse(backendUrl('auth/login')),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = jsonDecode(resp.body);

      if (data['ok'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user_role', 'admin');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
      } else {
        setState(() => message = data['error'] ?? 'Erreur: ${resp.statusCode}');
      }
    } catch (e) {
      setState(() => message = "Erreur réseau: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _personnelLogin() async {
    final phone = _identifierController.text.trim();
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
        body: jsonEncode({'phone': phone, 'password': password}),
      );
      final data = jsonDecode(res.body);

      if (data['ok'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user_role', 'personnel');
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
      title: 'Authentification',
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Connectez-vous à votre compte',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                _buildLoginTypeSelector(),
                SizedBox(height: 24),
                _buildIdentifierField(),
                SizedBox(height: 12),
                _buildPasswordField(),
                SizedBox(height: 20),
                if (message != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(message!, style: TextStyle(color: Colors.red, fontSize: 14)),
                  ),
                _buildSubmitButton(),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                  child: Text("Vous n'avez pas de compte ? S'inscrire"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _selectedLogin = LoginType.admin),
            child: Text('ADMIN'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedLogin == LoginType.admin ? Colors.green : Colors.grey[300],
              foregroundColor: _selectedLogin == LoginType.admin ? Colors.white : Colors.black54,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _selectedLogin = LoginType.employee),
            child: Text('EMPLOYE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedLogin == LoginType.employee ? Colors.blue : Colors.grey[300],
              foregroundColor: _selectedLogin == LoginType.employee ? Colors.white : Colors.black54,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIdentifierField() {
    bool isAdmin = _selectedLogin == LoginType.admin;
    return TextField(
      controller: _identifierController,
      keyboardType: isAdmin ? TextInputType.emailAddress : TextInputType.phone,
      decoration: InputDecoration(
        labelText: isAdmin ? 'Email' : 'Numéro de téléphone',
        prefixIcon: Icon(isAdmin ? Icons.email : Icons.phone),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Mot de passe',
        prefixIcon: Icon(Icons.lock),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : submit,
        child: loading
            ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
            : Text("SE CONNECTER", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}