// // lib/services/device_service.dart
// //
// // Tout ce qui parle au serveur pour les appareils est ici.
// // Les écrans n'ont plus qu'à appeler ces fonctions et afficher le résultat.
// //
// //   GET  /api/devices/               → fetchDevices()
// //   POST /api/devices/<id>/command/  → sendCommand()

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'auth_service.dart';
// import 'home_session.dart';

// /// Un appareil de la maison, tel que le serveur le décrit.
// class Device {
//   final int id;
//   final String name;
//   final String type; // light, fan, door, servo, sensor
//   final bool online;
//   final Map<String, dynamic> state;
//   final String uid; // identifiant annoncé par l'appareil (ex: esp32-a1b2)
//   final String integration; // '' (MQTT) ou 'samsung_tv', 'wled', 'shelly'...
//   final String host; // adresse IP des appareils du commerce

//   Device(this.id, this.name, this.type, this.online, this.state,
//       {this.uid = '', this.integration = '', this.host = ''});

//   factory Device.fromJson(Map<String, dynamic> j) => Device(
//         j['id'] as int,
//         j['name'] as String,
//         j['device_type'] as String,
//         j['is_online'] as bool? ?? false,
//         Map<String, dynamic>.from(j['state'] as Map? ?? {}),
//         uid: j['uid'] as String? ?? '',
//         integration: j['integration'] as String? ?? '',
//         host: j['host'] as String? ?? '',
//       );

//   bool get isOn => state['on'] == true;
//   bool get isLocked => state['locked'] != false; // verrouillée par défaut
//   double get value => (state['value'] as num?)?.toDouble() ?? 0;
// }

// /// Résultat de la reconnaissance d'un appareil à une adresse IP.
// class ProbeResult {
//   final bool found;
//   final String kind; // 'samsung_tv', 'wled', 'shelly', 'tasmota', 'roku', 'wiz' ou ''
//   final String name;

//   ProbeResult(this.found, this.kind, this.name);
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
//       await HomeSession.instance.ensureLoaded();
//       final home = HomeSession.instance.currentId;
//       final res = await AuthService.instance
//           .get(home == null ? '/api/devices/' : '/api/devices/?home=$home');
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
//         throw DeviceServiceException(
//             _errorFrom(res, 'Commande refusée (${res.statusCode})'));
//       }
//       return Device.fromJson(
//           jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
//     } on DeviceServiceException {
//       rethrow;
//     } catch (_) {
//       throw DeviceServiceException('Erreur de connexion au serveur');
//     }
//   }

//   /// Enregistre un appareil détecté sur le Wi-Fi dans la maison de l'utilisateur.
//   /// Si l'appareil est déjà enregistré, on retourne l'existant (pas de doublon).
//   Future<Device> addDevice({
//     required String uid,
//     required String name,
//     required String type,
//   }) async {
//     try {
//       final homeId = await _requireHome();
//       final existing = await fetchDevices();
//       for (final d in existing) {
//         if (d.uid == uid) return d;
//       }

//       final body = <String, dynamic>{
//         'uid': uid,
//         'name': name,
//         'device_type': type,
//         'mqtt_topic': 'home/$uid/cmd',
//       };
//       body['home'] = homeId;

//       final res = await AuthService.instance.post('/api/devices/', body);
//       if (res.statusCode != 200 && res.statusCode != 201) {
//         throw DeviceServiceException(
//             _errorFrom(res, 'Ajout refusé (${res.statusCode})'));
//       }
//       return Device.fromJson(
//           jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
//     } on DeviceServiceException {
//       rethrow;
//     } catch (_) {
//       throw DeviceServiceException('Erreur de connexion au serveur');
//     }
//   }

//   /// Maison choisie dans l'app (erreur claire s'il n'y en a pas encore).
//   Future<int> _requireHome() async {
//     await HomeSession.instance.ensureLoaded();
//     final id = HomeSession.instance.currentId;
//     if (id == null) {
//       throw DeviceServiceException("Ajoutez d'abord une maison (onglet Accueil)");
//     }
//     return id;
//   }

//   /// Ajout manuel. Pour un appareil MQTT : nom + type (l'identifiant est
//   /// créé par le serveur si [uid] est vide). Pour une télé ou une bande LED :
//   /// [integration] et [host] (adresse IP) sont obligatoires.
//   Future<Device> addManual({
//     required String name,
//     required String type,
//     String uid = '',
//     String integration = '',
//     String host = '',
//   }) async {
//     try {
//       final homeId = await _requireHome();
//       final body = <String, dynamic>{'name': name, 'device_type': type, 'home': homeId};
//       if (uid.isNotEmpty) body['uid'] = uid;
//       if (integration.isNotEmpty) {
//         body['integration'] = integration;
//         body['host'] = host;
//       }
//       final res = await AuthService.instance.post('/api/devices/', body);
//       if (res.statusCode != 200 && res.statusCode != 201) {
//         throw DeviceServiceException(
//             _errorFrom(res, 'Ajout refusé (${res.statusCode})'));
//       }
//       return Device.fromJson(
//           jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
//     } on DeviceServiceException {
//       rethrow;
//     } catch (_) {
//       throw DeviceServiceException('Erreur de connexion au serveur');
//     }
//   }

//   /// Demande au serveur de reconnaître l'appareil situé à cette adresse IP.
//   Future<ProbeResult> probe(String host) async {
//     try {
//       final res =
//           await AuthService.instance.post('/api/devices/probe/', {'host': host});
//       if (res.statusCode != 200) {
//         throw DeviceServiceException(
//             _errorFrom(res, 'Recherche impossible (${res.statusCode})'));
//       }
//       final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
//       return ProbeResult(
//         data['found'] == true,
//         data['kind'] as String? ?? '',
//         data['name'] as String? ?? '',
//       );
//     } on DeviceServiceException {
//       rethrow;
//     } catch (_) {
//       throw DeviceServiceException('Erreur de connexion au serveur');
//     }
//   }

//   /// Type d'appareil à enregistrer pour une intégration reconnue.
//   static String typeForKind(String kind) =>
//       (kind == 'samsung_tv' || kind == 'roku') ? 'tv' : 'light';

//   /// Nom lisible d'une famille d'appareils reconnue.
//   static String kindLabel(String kind) => const {
//         'samsung_tv': 'Télé Samsung',
//         'wled': 'Bande LED WLED',
//         'shelly': 'Prise Shelly',
//         'tasmota': 'Appareil Tasmota',
//         'roku': 'Roku',
//         'wiz': 'Ampoule WiZ',
//       }[kind] ?? kind;

//   /// Message d'erreur renvoyé par le serveur (sinon [fallback]).
//   String _errorFrom(http.Response res, String fallback) {
//     try {
//       final data = jsonDecode(utf8.decode(res.bodyBytes));
//       if (data is Map) {
//         if (data['error'] is String) return data['error'] as String;
//         for (final v in data.values) {
//           if (v is List && v.isNotEmpty) return v.first.toString();
//           if (v is String) return v;
//         }
//       }
//     } catch (_) {}
//     return fallback;
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
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'home_session.dart';

/// Un appareil de la maison, tel que le serveur le décrit.
class Device {
  final int id;
  final String name;
  final String type; // light, fan, door, servo, sensor
  final bool online;
  final Map<String, dynamic> state;
  final String uid; // identifiant annoncé par l'appareil (ex: esp32-a1b2)
  final String integration; // '' (MQTT) ou 'samsung_tv', 'wled', 'shelly'...
  final String host; // adresse IP des appareils du commerce

  Device(this.id, this.name, this.type, this.online, this.state,
      {this.uid = '', this.integration = '', this.host = ''});

  factory Device.fromJson(Map<String, dynamic> j) => Device(
        j['id'] as int,
        j['name'] as String,
        j['device_type'] as String,
        j['is_online'] as bool? ?? false,
        Map<String, dynamic>.from(j['state'] as Map? ?? {}),
        uid: j['uid'] as String? ?? '',
        integration: j['integration'] as String? ?? '',
        host: j['host'] as String? ?? '',
      );

  /// Bande LED ou ampoule : luminosité + couleur.
  bool get supportsColor => integration == 'wled' || integration == 'wiz';
  String? get colorHex => state['color'] as String?;

  bool get isOn => state['on'] == true;
  bool get isLocked => state['locked'] != false; // verrouillée par défaut
  double get value => (state['value'] as num?)?.toDouble() ?? 0;
}

/// Résultat de la reconnaissance d'un appareil à une adresse IP.
class ProbeResult {
  final bool found;
  final String kind; // 'samsung_tv', 'wled', 'shelly', 'tasmota', 'roku', 'wiz' ou ''
  final String name;

  ProbeResult(this.found, this.kind, this.name);
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
      await HomeSession.instance.ensureLoaded();
      final home = HomeSession.instance.currentId;
      final res = await AuthService.instance
          .get(home == null ? '/api/devices/' : '/api/devices/?home=$home');
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
  Future<Device> sendCommand(int deviceId, String action, [Object? value]) async {
    try {
      final body = <String, dynamic>{'action': action};
      if (value != null) body['value'] = value;
      final res = await AuthService.instance
          .post('/api/devices/$deviceId/command/', body);

      if (res.statusCode == 503) {
        throw DeviceServiceException('Le serveur MQTT est injoignable');
      }
      if (res.statusCode != 200) {
        throw DeviceServiceException(
            _errorFrom(res, 'Commande refusée (${res.statusCode})'));
      }
      return Device.fromJson(
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
    } on DeviceServiceException {
      rethrow;
    } catch (_) {
      throw DeviceServiceException('Erreur de connexion au serveur');
    }
  }
  Future<void> deleteDevice(int deviceId) async {
    try {
      final res = await AuthService.instance.delete('/api/devices/$deviceId/');
      if (res.statusCode != 204 && res.statusCode != 200) {
        throw DeviceServiceException(
            res.statusCode == 404 ? 'Appareil introuvable' : 'Suppression refusée (${res.statusCode})');
      }
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
      final homeId = await _requireHome();
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
      body['home'] = homeId;

      final res = await AuthService.instance.post('/api/devices/', body);
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw DeviceServiceException(
            _errorFrom(res, 'Ajout refusé (${res.statusCode})'));
      }
      return Device.fromJson(
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
    } on DeviceServiceException {
      rethrow;
    } catch (_) {
      throw DeviceServiceException('Erreur de connexion au serveur');
    }
  }

  /// Maison choisie dans l'app (erreur claire s'il n'y en a pas encore).
  Future<int> _requireHome() async {
    await HomeSession.instance.ensureLoaded();
    final id = HomeSession.instance.currentId;
    if (id == null) {
      throw DeviceServiceException("Ajoutez d'abord une maison (onglet Accueil)");
    }
    return id;
  }

  /// Ajout manuel. Pour un appareil MQTT : nom + type (l'identifiant est
  /// créé par le serveur si [uid] est vide). Pour une télé ou une bande LED :
  /// [integration] et [host] (adresse IP) sont obligatoires.
  Future<Device> addManual({
    required String name,
    required String type,
    String uid = '',
    String integration = '',
    String host = '',
  }) async {
    try {
      final homeId = await _requireHome();
      final body = <String, dynamic>{'name': name, 'device_type': type, 'home': homeId};
      if (uid.isNotEmpty) body['uid'] = uid;
      if (integration.isNotEmpty) {
        body['integration'] = integration;
        body['host'] = host;
      }
      final res = await AuthService.instance.post('/api/devices/', body);
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw DeviceServiceException(
            _errorFrom(res, 'Ajout refusé (${res.statusCode})'));
      }
      return Device.fromJson(
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
    } on DeviceServiceException {
      rethrow;
    } catch (_) {
      throw DeviceServiceException('Erreur de connexion au serveur');
    }
  }

  /// Demande au serveur de reconnaître l'appareil situé à cette adresse IP.
  Future<ProbeResult> probe(String host) async {
    try {
      final res =
          await AuthService.instance.post('/api/devices/probe/', {'host': host});
      if (res.statusCode != 200) {
        throw DeviceServiceException(
            _errorFrom(res, 'Recherche impossible (${res.statusCode})'));
      }
      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      return ProbeResult(
        data['found'] == true,
        data['kind'] as String? ?? '',
        data['name'] as String? ?? '',
      );
    } on DeviceServiceException {
      rethrow;
    } catch (_) {
      throw DeviceServiceException('Erreur de connexion au serveur');
    }
  }

  /// Type d'appareil à enregistrer pour une intégration reconnue.
  static String typeForKind(String kind) =>
      (kind == 'samsung_tv' || kind == 'roku') ? 'tv' : 'light';

  /// Nom lisible d'une famille d'appareils reconnue.
  static String kindLabel(String kind) => const {
        'samsung_tv': 'Télé Samsung',
        'wled': 'Bande LED WLED',
        'shelly': 'Prise Shelly',
        'tasmota': 'Appareil Tasmota',
        'roku': 'Roku',
        'wiz': 'Ampoule WiZ',
      }[kind] ?? kind;

  /// Message d'erreur renvoyé par le serveur (sinon [fallback]).
  String _errorFrom(http.Response res, String fallback) {
    try {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      if (data is Map) {
        if (data['error'] is String) return data['error'] as String;
        for (final v in data.values) {
          if (v is List && v.isNotEmpty) return v.first.toString();
          if (v is String) return v;
        }
      }
    } catch (_) {}
    return fallback;
  }
}
  /// Supprime un appareil (seulement s'il appartient à l'utilisateur).
