import 'package:flutter/foundation.dart';

const String backendBase = kIsWeb
    ? 'http://localhost:4000/api' // Flutter Web
    : 'http://10.0.2.2:4000/api';     // Android Emulator

// Fonction utilitaire pour générer l'URL complète
String backendUrl(String path) {
  if (path.startsWith('/')) {
    return '$backendBase$path';
  }
  return '$backendBase/$path';
}
