// lib/services/profile_service.dart
//
// Données de l'écran Profil : GET /api/me/

import 'dart:convert';
import 'auth_service.dart';

class UserProfile {
  final String name;
  final String email;
  final int devicesTotal;
  final int devicesOnline;

  UserProfile({
    required this.name,
    required this.email,
    required this.devicesTotal,
    required this.devicesOnline,
  });

  factory UserProfile.fromJson(Map<String, dynamic> j) {
    final email = j['email'] as String? ?? '';
    var name = (j['name'] as String? ?? '').trim();
    // Si aucun prénom n'est enregistré, on prend le début de l'email
    if (name.isEmpty) name = email.split('@').first;
    return UserProfile(
      name: name.isEmpty ? 'Utilisateur' : name,
      email: email,
      devicesTotal: j['devices_total'] as int? ?? 0,
      devicesOnline: j['devices_online'] as int? ?? 0,
    );
  }
}

class ProfileServiceException implements Exception {
  final String message;
  ProfileServiceException(this.message);
  @override
  String toString() => message;
}

class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  Future<UserProfile> fetchProfile() async {
    try {
      final res = await AuthService.instance.get('/api/me/');
      if (res.statusCode != 200) {
        throw ProfileServiceException('Erreur du serveur (${res.statusCode})');
      }
      return UserProfile.fromJson(
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
    } on ProfileServiceException {
      rethrow;
    } catch (_) {
      throw ProfileServiceException('Impossible de joindre le serveur');
    }
  }
}