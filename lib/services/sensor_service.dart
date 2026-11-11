// lib/services/sensor_service.dart
//
// Historique des capteurs : GET /api/sensors/history/?period=24h|7j|30j

import 'dart:convert';
import 'auth_service.dart';
import 'home_session.dart';

/// Une mesure envoyée par un capteur (température et/ou humidité).
class SensorPoint {
  final DateTime time;
  final double? temperature;
  final double? humidity;

  SensorPoint(this.time, this.temperature, this.humidity);

  factory SensorPoint.fromJson(Map<String, dynamic> j) => SensorPoint(
        DateTime.parse(j['timestamp'] as String).toLocal(),
        (j['temperature'] as num?)?.toDouble(),
        (j['humidity'] as num?)?.toDouble(),
      );
}

class SensorServiceException implements Exception {
  final String message;
  SensorServiceException(this.message);
  @override
  String toString() => message;
}

class SensorService {
  SensorService._();
  static final SensorService instance = SensorService._();

  /// period : '24h', '7j' ou '30j'
  Future<List<SensorPoint>> fetchHistory(String period) async {
    try {
      await HomeSession.instance.ensureLoaded();
      final home = HomeSession.instance.currentId;
      final res = await AuthService.instance.get(
          '/api/sensors/history/?period=$period${home == null ? '' : '&home=$home'}');
      if (res.statusCode != 200) {
        throw SensorServiceException('Erreur du serveur (${res.statusCode})');
      }
      final list = jsonDecode(utf8.decode(res.bodyBytes)) as List;
      return list
          .map((e) => SensorPoint.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SensorServiceException {
      rethrow;
    } catch (_) {
      throw SensorServiceException('Impossible de joindre le serveur');
    }
  }
}
