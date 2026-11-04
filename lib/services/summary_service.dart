// lib/services/summary_service.dart
//
// Données de l'écran Accueil : GET /api/summary/

import 'dart:convert';
import 'auth_service.dart';

class HomeSummary {
  final double? temperature;
  final double? humidity;
  final int lightsOn;
  final int lightsTotal;
  final bool doorsLocked;
  final int devicesTotal;
  final int devicesOnline;

  HomeSummary({
    this.temperature,
    this.humidity,
    required this.lightsOn,
    required this.lightsTotal,
    required this.doorsLocked,
    required this.devicesTotal,
    required this.devicesOnline,
  });

  factory HomeSummary.fromJson(Map<String, dynamic> j) => HomeSummary(
        temperature: (j['temperature'] as num?)?.toDouble(),
        humidity: (j['humidity'] as num?)?.toDouble(),
        lightsOn: j['lights_on'] as int? ?? 0,
        lightsTotal: j['lights_total'] as int? ?? 0,
        doorsLocked: j['doors_locked'] as bool? ?? true,
        devicesTotal: j['devices_total'] as int? ?? 0,
        devicesOnline: j['devices_online'] as int? ?? 0,
      );
}

class SummaryServiceException implements Exception {
  final String message;
  SummaryServiceException(this.message);
  @override
  String toString() => message;
}

class SummaryService {
  SummaryService._();
  static final SummaryService instance = SummaryService._();

  Future<HomeSummary> fetchSummary() async {
    try {
      final res = await AuthService.instance.get('/api/summary/');
      if (res.statusCode != 200) {
        throw SummaryServiceException('Erreur du serveur (${res.statusCode})');
      }
      return HomeSummary.fromJson(
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
    } on SummaryServiceException {
      rethrow;
    } catch (_) {
      throw SummaryServiceException('Impossible de joindre le serveur');
    }
  }
}