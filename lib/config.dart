import 'package:flutter/foundation.dart';

const String backendBase = 'https://backend-projet-paie-2.onrender.com/api';

// Fonction utilitaire pour générer l'URL complète
String backendUrl(String path) {
  if (path.startsWith('/')) {
    return '$backendBase$path';
  }
  return '$backendBase/$path';
}
