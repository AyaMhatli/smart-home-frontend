// lib/services/device_discovery_service.dart
//
// Détecte automatiquement les appareils SmartHome présents sur le même
// réseau Wi-Fi que le téléphone.
//
// pubspec.yaml :
//   dependencies:
//     nsd: ^4.0.0
//
// Android (android/app/src/main/AndroidManifest.xml) :
//   <uses-permission android:name="android.permission.INTERNET"/>
//   <uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
//   <uses-permission android:name="android.permission.CHANGE_WIFI_MULTICAST_STATE"/>
//
// iOS (ios/Runner/Info.plist) :
//   <key>NSLocalNetworkUsageDescription</key>
//   <string>Détecter les appareils connectés de la maison</string>
//   <key>NSBonjourServices</key>
//   <array><string>_smarthome._tcp</string></array>

import 'dart:async';
import 'dart:convert';
import 'package:nsd/nsd.dart';

class DiscoveredDevice {
  final String id;
  final String name;
  final String type; // light, fan, door, sensor...
  final String ip;

  const DiscoveredDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.ip,
  });
}

class DeviceDiscoveryService {
  Discovery? _discovery;
  final _controller = StreamController<List<DiscoveredDevice>>.broadcast();
  final Map<String, DiscoveredDevice> _devices = {};

  /// Liste mise à jour à chaque appareil trouvé ou perdu.
  Stream<List<DiscoveredDevice>> get devices => _controller.stream;

  String _txt(Service service, String key, String fallback) {
    final raw = service.txt?[key];
    return raw == null ? fallback : utf8.decode(raw);
  }

  /// À appeler à l'ouverture de l'app (ou de l'écran "Appareils").
  Future<void> start() async {
    _discovery = await startDiscovery('_smarthome._tcp');
    _discovery!.addServiceListener((service, status) {
      final id = _txt(service, 'id', service.name ?? 'inconnu');

      if (status == ServiceStatus.found) {
        _devices[id] = DiscoveredDevice(
          id: id,
          name: _txt(service, 'name', service.name ?? 'Appareil'),
          type: _txt(service, 'type', 'unknown'),
          ip: service.host ?? '',
        );
      } else {
        _devices.remove(id); // l'appareil a quitté le réseau
      }
      _controller.add(_devices.values.toList());
    });
  }

  Future<void> stop() async {
    if (_discovery != null) await stopDiscovery(_discovery!);
    _discovery = null;
  }

  void dispose() {
    stop();
    _controller.close();
  }
}

// Exemple d'utilisation dans un écran :
//
//   final _discovery = DeviceDiscoveryService();
//
//   @override
//   void initState() {
//     super.initState();
//     _discovery.start();
//   }
//
//   StreamBuilder<List<DiscoveredDevice>>(
//     stream: _discovery.devices,
//     builder: (context, snapshot) {
//       final found = snapshot.data ?? [];
//       return Column(
//         children: found.map((d) => Text('${d.name} (${d.ip})')).toList(),
//       );
//     },
//   )
//
//   @override
//   void dispose() { _discovery.dispose(); super.dispose(); }
