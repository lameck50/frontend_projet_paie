import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  AppScaffold({required this.title, required this.child, this.floatingActionButton, this.actions});

  @override
  Widget build(BuildContext context) {
    final gradTop = Color(0xFF5F9EA0);
    final gradBottom = Color(0xFF9AC0C1);
    return Scaffold(
      backgroundColor: gradTop,
      floatingActionButton: floatingActionButton,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradTop, gradBottom],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    if (Navigator.canPop(context)) // 🔹 bouton retour
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                    Icon(Icons.account_balance_wallet, size: 28),
                    SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    Spacer(),
                    if (actions != null) ...actions!,
                  ],
                ),
              ),
              Expanded(child: child),
              // Footer
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                child: Text(
                  'Copyright 2025 Africano',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
