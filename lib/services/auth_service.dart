

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  // Adresse de ton serveur sur la Pi — adapte l'IP si elle change
  // static const String baseUrl = 'http://192.168.43.27:8000';
  static const String baseUrl = 'http://0.0.0.0:8000';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';
  static const _timeout = Duration(seconds: 50);

  /// Vrai si un utilisateur s'est déjà connecté sur ce téléphone.
  Future<bool> isLoggedIn() async => (await _storage.read(key: _kRefresh)) != null;

  /// Retourne null si la connexion réussit, sinon le message d'erreur à afficher.
  Future<String?> login(String email, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/api/token/'),
            headers: {'Content-Type': 'application/json'},
            // L'email sert d'identifiant côté Django
            body: jsonEncode({'username': email, 'password': password}),
          )
          .timeout(_timeout);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        await _storage.write(key: _kAccess, value: data['access']);
        await _storage.write(key: _kRefresh, value: data['refresh']);
        return null;
      }
      if (res.statusCode == 401) return 'Email ou mot de passe incorrect';
      return 'Erreur du serveur (${res.statusCode})';
    } on TimeoutException {
      return 'Le serveur ne répond pas';
    } on SocketException {
      return 'Impossible de joindre le serveur';
    } catch (_) {
      return 'Une erreur est survenue';
    }
  }

  /// Crée le compte puis connecte l'utilisateur. Retourne null si tout va bien.
  Future<String?> register(String name, String email, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/api/auth/register/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'name': name, 'email': email, 'password': password}),
          )
          .timeout(_timeout);

      if (res.statusCode == 201) return login(email, password);
      if (res.statusCode == 400) return _firstError(res.body);
      return 'Erreur du serveur (${res.statusCode})';
    } on TimeoutException {
      return 'Le serveur ne répond pas';
    } on SocketException {
      return 'Impossible de joindre le serveur';
    } catch (_) {
      return 'Une erreur est survenue';
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }

  // ── Requêtes authentifiées (pour tous les autres écrans) ──────────────
  // Exemple : final res = await AuthService.instance.get('/api/summary/');

  Future<http.Response> get(String path) => _send('GET', path);

  Future<http.Response> post(String path, [Map<String, dynamic>? body]) =>
      _send('POST', path, body);

  Future<http.Response> _send(String method, String path, [Map<String, dynamic>? body]) async {
    Future<http.Response> attempt() async {
      final token = await _storage.read(key: _kAccess);
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final uri = Uri.parse('$baseUrl$path');
      return method == 'GET'
          ? http.get(uri, headers: headers).timeout(_timeout)
          : http.post(uri, headers: headers, body: jsonEncode(body ?? {})).timeout(_timeout);
    }

    var res = await attempt();
    if (res.statusCode == 401 && await _refresh()) res = await attempt();
    return res;
  }

  /// Renouvelle le token d'accès quand il a expiré.
  Future<bool> _refresh() async {
    final refresh = await _storage.read(key: _kRefresh);
    if (refresh == null) return false;
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/api/token/refresh/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh': refresh}),
          )
          .timeout(_timeout);
      if (res.statusCode != 200) {
        await logout(); // session expirée : il faudra se reconnecter
        return false;
      }
      await _storage.write(key: _kAccess, value: jsonDecode(res.body)['access']);
      return true;
    } catch (_) {
      return false;
    }
  }

  String _firstError(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final first = data.values.first;
      return first is List ? first.first.toString() : first.toString();
    } catch (_) {
      return 'Données invalides';
    }
  }
}
