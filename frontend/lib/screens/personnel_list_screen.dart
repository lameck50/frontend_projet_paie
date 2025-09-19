import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/app_scaffold.dart';
import '../config.dart';
import 'personnel_form_screen.dart';
import 'payment_screen.dart';

class PersonnelListScreen extends StatefulWidget {
  @override
  _PersonnelListScreenState createState() => _PersonnelListScreenState();
}

class _PersonnelListScreenState extends State<PersonnelListScreen> {
  List personnelList = [];
  bool loading = true;
  String? message;

  Future<void> fetchPersonnel() async {
    setState(() {
      loading = true;
      message = null;
    });

    try {
      final res = await http.get(Uri.parse(backendUrl('personnel')));

      if (res.headers['content-type']?.contains('application/json') != true) {
        setState(() {
          message = "Erreur réseau: réponse inattendue du serveur (HTML reçu)";
        });
        return;
      }

      final data = jsonDecode(res.body);
      if (data['ok'] == true) {
        setState(() => personnelList = data['list']);
      } else {
        setState(() => message = data['error'] ?? "Erreur inconnue");
      }
    } catch (e) {
      setState(() => message = "Erreur fetch personnel: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> deletePersonnel(String id) async {
    setState(() => loading = true);
    try {
      final res = await http.delete(Uri.parse(backendUrl('personnel/$id')));
      final data = jsonDecode(res.body);
      if (data['ok'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Personnel supprimé avec succès")),
        );
        fetchPersonnel();
      } else {
        setState(() => message = data['error'] ?? "Erreur suppression");
      }
    } catch (e) {
      setState(() => message = "Erreur suppression: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPersonnel();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppScaffold(
          title: 'Personnels',
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final addedOrUpdated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PersonnelFormScreen()),
              );
              if (addedOrUpdated == true) {
                fetchPersonnel();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Personnel ajouté/modifié avec succès")),
                );
              }
            },
            child: Icon(Icons.add),
          ),
          child: loading
              ? Center(child: CircularProgressIndicator())
              : message != null
                  ? Center(child: Text(message!))
                  : personnelList.isEmpty
                      ? Center(child: Text("Aucun employé trouvé"))
                      : ListView.builder(
                          itemCount: personnelList.length,
                          itemBuilder: (_, i) {
                            final p = personnelList[i];
                            return Card(
                              child: ListTile(
                                title: Text(p['fullName'] ?? ''),
                                subtitle: Text(
                                    "Salaire: \$${p['salary'] ?? 0} | Airtel: ${p['airtelNumber'] ?? '-'}"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () async {
                                        final updated = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                PersonnelFormScreen(personnelData: p),
                                          ),
                                        );
                                        if (updated == true) {
                                          fetchPersonnel();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    "Personnel modifié avec succès")),
                                          );
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: Text("Confirmer"),
                                            content: Text(
                                                "Voulez-vous supprimer ${p['fullName']} ?"),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text("Annuler")),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    deletePersonnel(p['_id']);
                                                  },
                                                  child: Text("Supprimer")),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.payments),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                PaymentScreen(personnel: p),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
        ),
        // Overlay de chargement global
        if (loading)
          Container(
            color: Colors.black54,
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
