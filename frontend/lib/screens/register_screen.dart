import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/app_scaffold.dart';
import '../config.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool loading = false;
  String? message;

  Future<void> register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if(name.isEmpty || email.isEmpty || password.isEmpty){
      setState(()=>message="Tous les champs sont obligatoires");
      return;
    }
    if(!email.contains('@')){
      setState(()=>message="Email invalide");
      return;
    }
    if(password.length<6){
      setState(()=>message="Mot de passe trop court (min 6 caractères)");
      return;
    }

    setState(()=>{loading=true,message=null});

    try {
      // 🔹 Correction: utilisation de backendUrl() au lieu de $backend
      final resp = await http.post(
        Uri.parse(backendUrl('auth/register')),
        headers: {'Content-Type':'application/json'},
        body: jsonEncode({'name':name,'email':email,'password':password}),
      );

      if(resp.headers['content-type']?.contains('application/json') != true){
        setState(()=>message="Erreur réseau: réponse inattendue du serveur (HTML reçu)");
        return;
      }

      final data = jsonDecode(resp.body);

      if((resp.statusCode==200 || resp.statusCode==201) && data['ok']==true){
        setState(()=>message="Compte créé avec succès !");
        Future.delayed(Duration(seconds:1), (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>LoginScreen()));
        });
      } else {
        setState(()=>message=data['error'] ?? 'Erreur: ${resp.statusCode}');
      }
    } catch(e){
      setState(()=>message="Erreur réseau: $e");
    } finally{
      setState(()=>loading=false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Créer un compte',
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal:24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:[
              TextField(controller:_nameController,decoration:InputDecoration(prefixIcon: Icon(Icons.person),labelText:'Nom complet')),
              SizedBox(height:12),
              TextField(controller:_emailController,keyboardType:TextInputType.emailAddress,decoration:InputDecoration(prefixIcon: Icon(Icons.email),labelText:'Email')),
              SizedBox(height:12),
              TextField(controller:_passwordController,obscureText:true,decoration:InputDecoration(prefixIcon: Icon(Icons.lock),labelText:'Mot de passe')),
              SizedBox(height:20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading?null: register,
                  child: loading ? SizedBox(height:18,width:18,child:CircularProgressIndicator(color:Colors.white,strokeWidth:2)) : Text("S'inscrire"),
                ),
              ),
              if(message!=null)
                Padding(
                  padding: EdgeInsets.only(top:12),
                  child: Text(message!, style: TextStyle(color: message!.startsWith("Erreur") ? Colors.red : Colors.green)),
                )
            ],
          ),
        ),
      ),
    );
  }
}
