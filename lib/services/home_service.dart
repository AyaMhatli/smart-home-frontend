// lib/services/home_service.dart
//
// Les maisons de l'utilisateur :
//   GET    /api/homes/       → fetchHomes()
//   POST   /api/homes/       → createHome()

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class HomeInfo {
  final int id;
  final String name;
  final int devicesCount;

  HomeInfo(this.id, this.name, this.devicesCount);

  factory HomeInfo.fromJson(Map<String, dynamic> j) => HomeInfo(
        j['id'] as int,
        j['name'] as String? ?? 'Maison',
        j['devices_count'] as int? ?? 0,
      );
}

class HomeServiceException implements Exception {
  final String message;
  HomeServiceException(this.message);

  @override
  String toString() => message;
}

class HomeService {
  HomeService._();
  static final HomeService instance = HomeService._();

  Future<List<HomeInfo>> fetchHomes() async {
    try {
      final res = await AuthService.instance.get('/api/homes/');
      if (res.statusCode != 200) {
        throw HomeServiceException('Erreur du serveur (${res.statusCode})');
      }
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      final list = data is Map ? (data['results'] as List? ?? []) : data as List;
      return list
          .map((e) => HomeInfo.fromJson(e as Map<String, dynamic>))
          .toList();
    } on HomeServiceException {
      rethrow;
    } catch (_) {
      throw HomeServiceException('Impossible de joindre le serveur');
    }
  }

  Future<HomeInfo> createHome(String name) async {
    try {
      final res = await AuthService.instance.post('/api/homes/', {'name': name});
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw HomeServiceException(_errorFrom(res, 'Ajout refusé (${res.statusCode})'));
      }
      return HomeInfo.fromJson(
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
    } on HomeServiceException {
      rethrow;
    } catch (_) {
      throw HomeServiceException('Impossible de joindre le serveur');
    }
  }

  String _errorFrom(http.Response res, String fallback) {
    try {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      if (data is Map) {
        for (final v in data.values) {
          if (v is List && v.isNotEmpty) return v.first.toString();
          if (v is String) return v;
        }
      }
    } catch (_) {}
    return fallback;
  }
}
