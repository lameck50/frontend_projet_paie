import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_scaffold.dart';
import 'login_screen.dart';
import 'personnel_list_screen.dart'; // Chemin relatif correct

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String adminName = '';

  Future<void> loadAdminName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      adminName = prefs.getString('adminName') ?? '';
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // supprime toutes les infos de session
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    loadAdminName();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Accueil',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenue, $adminName',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PersonnelListScreen()),
                );
              },
              icon: Icon(Icons.people),
              label: Text('Gérer le personnel'),
              style: ElevatedButton.styleFrom(minimumSize: Size(200, 50)),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: logout,
              icon: Icon(Icons.logout),
              label: Text('Se déconnecter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(200, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
