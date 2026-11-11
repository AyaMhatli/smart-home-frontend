// lib/services/network_service.dart
//
// Appareils présents sur le réseau du serveur : GET /api/network/scan/
// (le scan dure quelques secondes)

import 'dart:convert';
import '../services/auth_service.dart';

class NetworkHost {
  final String ip;
  final String mac;
  final String vendor; // marque devinée d'après l'adresse MAC (peut être vide)
  final bool privateMac; // adresse aléatoire : souvent un téléphone
  final List<String> ports; // ex: web, mqtt, tuya
  final String kind; // 'samsung_tv', 'wled' ou '' (non reconnu)
  final String name; // nom donné par l'appareil reconnu

  NetworkHost({
    required this.ip,
    required this.mac,
    required this.vendor,
    required this.privateMac,
    required this.ports,
    this.kind = '',
    this.name = '',
  });

  factory NetworkHost.fromJson(Map<String, dynamic> j) => NetworkHost(
        ip: j['ip'] as String? ?? '',
        mac: j['mac'] as String? ?? '',
        vendor: j['vendor'] as String? ?? '',
        privateMac: j['private_mac'] as bool? ?? false,
        ports: ((j['ports'] as List?) ?? []).map((e) => e.toString()).toList(),
        kind: j['kind'] as String? ?? '',
        name: j['name'] as String? ?? '',
      );

  bool get controllable => kind.isNotEmpty;

  /// Indice sur la possibilité de piloter l'appareil.
  String get hint {
    if (kind == 'samsung_tv') return 'Télé Samsung : commandable';
    if (kind == 'wled') return 'Bande LED WLED : commandable';
    if (ports.contains('mqtt') || ports.contains('mqtts')) {
      return 'Parle MQTT : pilotage possible';
    }
    if (vendor.toLowerCase().contains('espressif')) {
      return 'Puce ESP : pilotable si elle est programmée pour votre système';
    }
    if (ports.contains('tuya')) {
      return 'Appareil Tuya : passe en général par le cloud de la marque';
    }
    if (privateMac && vendor.isEmpty) {
      return 'Probablement un téléphone ou une tablette';
    }
    if (ports.contains('web')) {
      return 'Page web locale : à vérifier dans la notice';
    }
    return 'Probablement fermé (cloud de la marque)';
  }
}

class NetworkServiceException implements Exception {
  final String message;
  NetworkServiceException(this.message);
  @override
  String toString() => message;
}

class NetworkService {
  NetworkService._();
  static final NetworkService instance = NetworkService._();

  Future<List<NetworkHost>> scan() async {
    try {
      final res = await AuthService.instance.get('/api/network/scan/');
      if (res.statusCode == 404) {
        throw NetworkServiceException(
            "Le scan n'est pas installé sur le serveur");
      }
      if (res.statusCode == 503) {
        throw NetworkServiceException(
            'Le serveur ne trouve pas son réseau');
      }
      if (res.statusCode != 200) {
        throw NetworkServiceException('Erreur du serveur (${res.statusCode})');
      }
      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      return ((data['devices'] as List?) ?? [])
          .map((e) => NetworkHost.fromJson(e as Map<String, dynamic>))
          .toList();
    } on NetworkServiceException {
      rethrow;
    } catch (_) {
      throw NetworkServiceException('Impossible de joindre le serveur');
    }
  }
}
