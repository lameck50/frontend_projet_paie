import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(CliniquePaieApp());
}

class CliniquePaieApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clinique Paie',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo).copyWith(secondary: Colors.purple),
        useMaterial3: true,
      ),
      home: LoginScreen(),
    );
  }
}
