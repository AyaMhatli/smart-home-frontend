// // lib/services/device_service.dart
// //
// // Tout ce qui parle au serveur pour les appareils est ici.
// // Les écrans n'ont plus qu'à appeler ces fonctions et afficher le résultat.
// //
// //   GET  /api/devices/               → fetchDevices()
// //   POST /api/devices/<id>/command/  → sendCommand()

// import 'dart:convert';
// import 'auth_service.dart';

// /// Un appareil de la maison, tel que le serveur le décrit.
// class Device {
//   final int id;
//   final String name;
//   final String type; // light, fan, door, servo, sensor
//   final bool online;
//   final Map<String, dynamic> state;

//   Device(this.id, this.name, this.type, this.online, this.state);

//   factory Device.fromJson(Map<String, dynamic> j) => Device(
//         j['id'] as int,
//         j['name'] as String,
//         j['device_type'] as String,
//         j['is_online'] as bool? ?? false,
//         Map<String, dynamic>.from(j['state'] as Map? ?? {}),
//       );

//   bool get isOn => state['on'] == true;
//   bool get isLocked => state['locked'] != false; // verrouillée par défaut
//   double get value => (state['value'] as num?)?.toDouble() ?? 0;
// }

// /// Erreur avec un message prêt à afficher à l'utilisateur.
// class DeviceServiceException implements Exception {
//   final String message;
//   DeviceServiceException(this.message);

//   @override
//   String toString() => message;
// }

// class DeviceService {
//   DeviceService._();
//   static final DeviceService instance = DeviceService._();

//   /// Liste des appareils de l'utilisateur connecté.
//   Future<List<Device>> fetchDevices() async {
//     try {
//       final res = await AuthService.instance.get('/api/devices/');
//       if (res.statusCode != 200) {
//         throw DeviceServiceException('Erreur du serveur (${res.statusCode})');
//       }
//       final list = jsonDecode(utf8.decode(res.bodyBytes)) as List;
//       return list
//           .map((e) => Device.fromJson(e as Map<String, dynamic>))
//           .toList();
//     } on DeviceServiceException {
//       rethrow;
//     } catch (_) {
//       throw DeviceServiceException('Impossible de joindre le serveur');
//     }
//   }

//   /// Envoie un ordre à un appareil et retourne son état mis à jour.
//   /// Exemples : sendCommand(1, 'on'), sendCommand(2, 'set_speed', 40)
//   Future<Device> sendCommand(int deviceId, String action, [num? value]) async {
//     try {
//       final body = <String, dynamic>{'action': action};
//       if (value != null) body['value'] = value;
//       final res = await AuthService.instance
//           .post('/api/devices/$deviceId/command/', body);

//       if (res.statusCode == 503) {
//         throw DeviceServiceException('Le serveur MQTT est injoignable');
//       }
//       if (res.statusCode != 200) {
//         throw DeviceServiceException('Commande refusée (${res.statusCode})');
//       }
//       return Device.fromJson(
//           jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
//     } on DeviceServiceException {
//       rethrow;
//     } catch (_) {
//       throw DeviceServiceException('Erreur de connexion au serveur');
//     }
//   }
// }
// lib/services/device_service.dart
//
// Tout ce qui parle au serveur pour les appareils est ici.
// Les écrans n'ont plus qu'à appeler ces fonctions et afficher le résultat.
//
//   GET  /api/devices/               → fetchDevices()
//   POST /api/devices/<id>/command/  → sendCommand()

import 'dart:convert';
import 'auth_service.dart';

/// Un appareil de la maison, tel que le serveur le décrit.
class Device {
  final int id;
  final String name;
  final String type; // light, fan, door, servo, sensor
  final bool online;
  final Map<String, dynamic> state;
  final String uid; // identifiant annoncé par l'appareil (ex: esp32-a1b2)

  Device(this.id, this.name, this.type, this.online, this.state,
      {this.uid = ''});

  factory Device.fromJson(Map<String, dynamic> j) => Device(
        j['id'] as int,
        j['name'] as String,
        j['device_type'] as String,
        j['is_online'] as bool? ?? false,
        Map<String, dynamic>.from(j['state'] as Map? ?? {}),
        uid: j['uid'] as String? ?? '',
      );

  bool get isOn => state['on'] == true;
  bool get isLocked => state['locked'] != false; // verrouillée par défaut
  double get value => (state['value'] as num?)?.toDouble() ?? 0;
}

/// Erreur avec un message prêt à afficher à l'utilisateur.
class DeviceServiceException implements Exception {
  final String message;
  DeviceServiceException(this.message);

  @override
  String toString() => message;
}

class DeviceService {
  DeviceService._();
  static final DeviceService instance = DeviceService._();

  /// Liste des appareils de l'utilisateur connecté.
  Future<List<Device>> fetchDevices() async {
    try {
      final res = await AuthService.instance.get('/api/devices/');
      if (res.statusCode != 200) {
        throw DeviceServiceException('Erreur du serveur (${res.statusCode})');
      }
      final list = jsonDecode(utf8.decode(res.bodyBytes)) as List;
      return list
          .map((e) => Device.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DeviceServiceException {
      rethrow;
    } catch (_) {
      throw DeviceServiceException('Impossible de joindre le serveur');
    }
  }

  /// Envoie un ordre à un appareil et retourne son état mis à jour.
  /// Exemples : sendCommand(1, 'on'), sendCommand(2, 'set_speed', 40)
  Future<Device> sendCommand(int deviceId, String action, [num? value]) async {
    try {
      final body = <String, dynamic>{'action': action};
      if (value != null) body['value'] = value;
      final res = await AuthService.instance
          .post('/api/devices/$deviceId/command/', body);

      if (res.statusCode == 503) {
        throw DeviceServiceException('Le serveur MQTT est injoignable');
      }
      if (res.statusCode != 200) {
        throw DeviceServiceException('Commande refusée (${res.statusCode})');
      }
      return Device.fromJson(
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
    } on DeviceServiceException {
      rethrow;
    } catch (_) {
      throw DeviceServiceException('Erreur de connexion au serveur');
    }
  }

  /// Enregistre un appareil détecté sur le Wi-Fi dans la maison de l'utilisateur.
  /// Si l'appareil est déjà enregistré, on retourne l'existant (pas de doublon).
  Future<Device> addDevice({
    required String uid,
    required String name,
    required String type,
  }) async {
    try {
      final existing = await fetchDevices();
      for (final d in existing) {
        if (d.uid == uid) return d;
      }

      final body = <String, dynamic>{
        'uid': uid,
        'name': name,
        'device_type': type,
        'mqtt_topic': 'home/$uid/cmd',
      };
      final homeId = await _firstHomeId();
      if (homeId != null) body['home'] = homeId;

      final res = await AuthService.instance.post('/api/devices/', body);
      if (res.statusCode == 400) {
        throw DeviceServiceException('Type ou nom d\'appareil non valide');
      }
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw DeviceServiceException('Ajout refusé (${res.statusCode})');
      }
      return Device.fromJson(
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
    } on DeviceServiceException {
      rethrow;
    } catch (_) {
      throw DeviceServiceException('Erreur de connexion au serveur');
    }
  }

  /// Première maison de l'utilisateur (null s'il n'en a pas encore).
  Future<int?> _firstHomeId() async {
    try {
      final res = await AuthService.instance.get('/api/homes/');
      if (res.statusCode != 200) return null;
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      final list = data is Map ? (data['results'] as List? ?? []) : data as List;
      if (list.isEmpty) return null;
      return (list.first as Map)['id'] as int?;
    } catch (_) {
      return null;
    }
  }
}