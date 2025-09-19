import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config.dart';
import '../widgets/app_scaffold.dart';
import 'personnel_login_screen.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  @override
  _EmployeeDashboardScreenState createState() => _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  bool loading = true;
  String? message;
  Map? personnelData;
  List payments = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => loading = true);
    await fetchPersonnelData();
    await fetchPayments();
    setState(() => loading = false);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchPersonnelData() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token non trouvé');

      final res = await http.get(
        Uri.parse(backendUrl('personnel/me')),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(res.body);
      if (data['ok'] == true) {
        setState(() => personnelData = data['personnel']);
      } else {
        throw Exception(data['error'] ?? 'Erreur serveur');
      }
    } catch (e) {
      setState(() => message = "Erreur profil: $e");
    }
  }

  Future<void> fetchPayments() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Token non trouvé');

      final res = await http.get(
        Uri.parse(backendUrl('payment/mine')),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(res.body);
      if (data['ok'] == true) {
        setState(() => payments = data['list']);
      } else {
        throw Exception(data['error'] ?? 'Erreur serveur');
      }
    } catch (e) {
      setState(() => message = "Erreur paiements: $e");
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => PersonnelLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Mon Tableau de Bord',
      actions: [
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: logout,
          tooltip: 'Déconnexion',
        )
      ],
      child: loading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchData,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  if (message != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(message!, style: TextStyle(color: Colors.red)),
                    ),
                  if (personnelData != null)
                    _buildProfileCard(),
                  SizedBox(height: 24),
                  Text('Historique des Transactions', style: Theme.of(context).textTheme.headlineSmall),
                  SizedBox(height: 12),
                  _buildPaymentList(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileCard() {
    final name = personnelData!['fullName'] ?? 'N/A';
    final phone = personnelData!['phone'] ?? 'N/A';
    final email = personnelData!['email'] ?? 'N/A';

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 12),
            ListTile(leading: Icon(Icons.phone), title: Text(phone)),
            if (email.isNotEmpty) ListTile(leading: Icon(Icons.email), title: Text(email)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentList() {
    if (payments.isEmpty) {
      return Center(child: Text('Aucune transaction trouvée.'));
    }

    final double totalBalance = payments.fold(0.0, (sum, item) => sum + (item['amount'] ?? 0));

    return Column(
      children: [
        Card(
          color: Colors.green[100],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Solde Total Reçu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${totalBalance.toStringAsFixed(2)} \$', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800])),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        ...payments.map((payment) {
          return Card(
            margin: EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text(payment['description'] ?? 'Paiement reçu'),
              subtitle: Text('Réf: ${payment['providerReference']}'),
              trailing: Text('${payment['amount']} \$', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          );
        }).toList(),
      ],
    );
  }
}