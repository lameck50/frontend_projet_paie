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
  List _personnelList = [];
  List _filteredPersonnelList = [];
  bool _loading = true;
  String? _message;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPersonnel();
    _searchController.addListener(_filterPersonnel);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchPersonnel() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final res = await http.get(Uri.parse(backendUrl('personnel')));
      final data = jsonDecode(res.body);
      if (data['ok'] == true) {
        setState(() {
          _personnelList = data['list'];
          _filterPersonnel(); // Appliquer le filtre après le fetch
        });
      } else {
        setState(() => _message = data['error'] ?? "Erreur inconnue");
      }
    } catch (e) {
      setState(() => _message = "Erreur de connexion: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _filterPersonnel() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPersonnelList = _personnelList.where((p) {
        final name = p['fullName']?.toLowerCase() ?? '';
        return name.contains(query);
      }).toList();
    });
  }

  Future<void> _deletePersonnel(String id) async {
    setState(() => _loading = true);
    try {
      final res = await http.delete(Uri.parse(backendUrl('personnel/$id')));
      final data = jsonDecode(res.body);
      if (data['ok'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Personnel supprimé avec succès"), backgroundColor: Colors.green),
        );
        await fetchPersonnel(); // Rafraîchir la liste
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? "Erreur de suppression"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showDeleteDialog(Map p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Confirmer la suppression"),
        content: Text("Voulez-vous vraiment supprimer ${p['fullName']} ? Cette action est irréversible."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePersonnel(p['_id']);
            },
            child: Text("Supprimer"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _navigateToAddForm() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => PersonnelFormScreen()));
    if (result == true) fetchPersonnel();
  }

  void _navigateToEditForm(Map personnel) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => PersonnelFormScreen(personnelData: personnel)));
    if (result == true) fetchPersonnel();
  }

  void _navigateToPayment(Map personnel) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen(personnel: personnel)));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Gestion du Personnel',
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddForm,
        child: Icon(Icons.add),
        tooltip: 'Ajouter un employé',
      ),
      child: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Rechercher un employé',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading && _personnelList.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    if (_message != null) {
      return Center(child: Text(_message!, style: TextStyle(color: Colors.red)));
    }
    if (_filteredPersonnelList.isEmpty) {
      return Center(child: Text("Aucun employé trouvé."));
    }
    return RefreshIndicator(
      onRefresh: fetchPersonnel,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 8),
        itemCount: _filteredPersonnelList.length,
        itemBuilder: (_, i) => _buildPersonnelCard(_filteredPersonnelList[i]),
      ),
    );
  }

  Widget _buildPersonnelCard(Map p) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // On ajoute un peu d'espace pour ne pas être sous le bouton supprimer
                Padding(
                  padding: const EdgeInsets.only(right: 30.0),
                  child: Text(p['fullName'] ?? 'N/A', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 4),
                Text(p['jobTitle'] ?? 'Poste non défini', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
                Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      icon: Icon(Icons.edit, size: 18),
                      label: Text('Modifier'),
                      onPressed: () => _navigateToEditForm(p),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: Icon(Icons.payments, size: 18),
                      label: Text('Payer'),
                      onPressed: () => _navigateToPayment(p),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ],
                )
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.grey[600]),
              tooltip: 'Supprimer',
              onPressed: () => _showDeleteDialog(p),
            ),
          ),
        ],
      ),
    );
  }
}
