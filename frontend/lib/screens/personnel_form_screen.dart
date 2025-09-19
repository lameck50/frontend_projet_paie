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
  final _salaryController = TextEditingController();
  final _airtelController = TextEditingController();
  bool loading = false;
  String? message;

  @override
  void initState() {
    super.initState();
    if (widget.personnelData != null) {
      _nameController.text = widget.personnelData!['fullName'] ?? '';
      _salaryController.text = widget.personnelData!['salary']?.toString() ?? '';
      _airtelController.text = widget.personnelData!['airtelNumber'] ?? '';
    }
  }

  Future<void> submit() async {
    final name = _nameController.text.trim();
    final salary = _salaryController.text.trim();
    final airtel = _airtelController.text.trim();

    // ✅ Vérification complète des champs obligatoires
    if (name.isEmpty || salary.isEmpty || airtel.isEmpty) {
      setState(() => message = "Nom complet, salaire et numéro de téléphone sont obligatoires");
      return;
    }

    setState(() => {loading = true, message = null});

    try {
      final url = widget.personnelData != null
          ? backendUrl('personnel/${widget.personnelData!['_id']}')
          : backendUrl('personnel');

      final res = await (widget.personnelData != null
          ? http.put(Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'fullName': name, 'salary': salary, 'airtelNumber': airtel}))
          : http.post(Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'fullName': name, 'salary': salary, 'airtelNumber': airtel})));

      final data = jsonDecode(res.body);

      if (data['ok'] == true) {
        // ✅ SnackBar de confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.personnelData != null ? 'Personnel modifié avec succès' : 'Personnel ajouté avec succès')),
        );
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
              // ✅ Bouton retour
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Nom complet')),
              SizedBox(height: 12),
              TextField(controller: _salaryController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Salaire')),
              SizedBox(height: 12),
              TextField(controller: _airtelController, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: 'Numéro Airtel')),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : submit,
                  child: loading
                      ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(widget.personnelData != null ? 'Modifier' : 'Ajouter'),
                ),
              ),
              if (message != null)
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(message!, style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
