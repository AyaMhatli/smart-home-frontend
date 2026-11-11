// import 'package:flutter/material.dart';
// import '../services/device_service.dart';
// import '../services/home_session.dart';
// import '../themes/app_themes.dart';
// import '../widgets/home_switcher.dart';

// /// Écran « Contrôle » : il affiche les appareils et réagit aux gestes.
// /// Les échanges avec le serveur sont dans services/device_service.dart.
// class DeviceControlScreen extends StatefulWidget {
//   const DeviceControlScreen({super.key});

//   @override
//   State<DeviceControlScreen> createState() => _DeviceControlScreenState();
// }

// class _DeviceControlScreenState extends State<DeviceControlScreen> {
//   List<Device> _devices = [];
//   bool _loading = true;
//   String? _error;
//   final Set<int> _busy = {};

//   @override
//   void initState() {
//     super.initState();
//     HomeSession.instance.changes.addListener(_load);
//     _load();
//   }

//   @override
//   void dispose() {
//     HomeSession.instance.changes.removeListener(_load);
//     super.dispose();
//   }

//   Future<void> _load() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     try {
//       _devices = await DeviceService.instance.fetchDevices();
//     } on DeviceServiceException catch (e) {
//       _error = e.message;
//     }
//     if (mounted) setState(() => _loading = false);
//   }

//   Future<void> _send(Device d, String action, [num? value]) async {
//     setState(() => _busy.add(d.id));
//     try {
//       final updated = await DeviceService.instance.sendCommand(d.id, action, value);
//       final i = _devices.indexWhere((x) => x.id == d.id);
//       if (i != -1) _devices[i] = updated;
//     } on DeviceServiceException catch (e) {
//       _message(e.message);
//     }
//     if (mounted) setState(() => _busy.remove(d.id));
//   }

//   void _message(String text) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SafeArea(
//         child: RefreshIndicator(
//           onRefresh: _load,
//           child: ListView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//             children: [
//               _buildHeader(),
//               const SizedBox(height: 28),
//               ..._buildBody(),
//               const SizedBox(height: 40),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildBody() {
//     if (_loading && _devices.isEmpty) {
//       return const [
//         Padding(
//           padding: EdgeInsets.only(top: 60),
//           child: Center(child: CircularProgressIndicator()),
//         ),
//       ];
//     }
//     if (_error != null) {
//       return [
//         _info(_error!),
//         const SizedBox(height: 12),
//         OutlinedButton(onPressed: _load, child: const Text('Réessayer')),
//       ];
//     }
//     if (_devices.isEmpty) {
//       return [
//         _info("Aucun appareil pour le moment. Ajoutez-en depuis l'onglet Profil."),
//       ];
//     }

//     final lights = _devices.where((d) => d.type == 'light').toList();
//     final fans = _devices.where((d) => d.type == 'fan').toList();
//     final doors = _devices.where((d) => d.type == 'door').toList();
//     final servos = _devices.where((d) => d.type == 'servo').toList();
//     final tvs = _devices.where((d) => d.type == 'tv').toList();

//     final widgets = <Widget>[];
//     void section(String title, List<Device> items, Widget Function(Device) card) {
//       if (items.isEmpty) return;
//       if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 28));
//       widgets.add(_sectionTitle(title));
//       widgets.add(const SizedBox(height: 12));
//       for (var i = 0; i < items.length; i++) {
//         if (i > 0) widgets.add(const SizedBox(height: 12));
//         widgets.add(card(items[i]));
//       }
//     }

//     section('Éclairage', lights, _lightCard);
//     section('Ventilation', fans, _fanCard);
//     section('Sécurité', doors, _doorCard);
//     section('Télévision', tvs, _tvCard);
//     section('Servo (angle)', servos, _servoCard);

//     if (widgets.isEmpty) {
//       widgets.add(_info('Aucun appareil commandable pour le moment.'));
//     }
//     return widgets;
//   }

//   Widget _info(String text) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(18),
//       ),
//       child: Text(
//         text,
//         style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         const Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             HomeSwitcher(),
//             SizedBox(height: 10),
//             Text(
//               'Contrôle',
//               style: TextStyle(
//                 color: AppColors.textPrimary,
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 4),
//             Text(
//               'Gérez vos appareils en direct',
//               style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
//             ),
//           ],
//         ),
//         IconButton(
//           onPressed: _load,
//           icon: const Icon(Icons.refresh_rounded,
//               color: AppColors.primaryBlue, size: 20),
//           style: IconButton.styleFrom(backgroundColor: AppColors.surface),
//         ),
//       ],
//     );
//   }

//   Widget _sectionTitle(String text) {
//     return Text(
//       text.toUpperCase(),
//       style: const TextStyle(
//         color: AppColors.textSecondary,
//         fontSize: 13,
//         fontWeight: FontWeight.w600,
//         letterSpacing: 0.5,
//       ),
//     );
//   }

//   // ── Cartes ────────────────────────────────────────────────────────────

//   Widget _card({required Widget child}) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(18),
//       ),
//       child: child,
//     );
//   }

//   Widget _iconBox(IconData icon, bool active) {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: active
//             ? AppColors.primaryBlue.withValues(alpha: 0.15)
//             : AppColors.surfaceLight,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Icon(
//         icon,
//         color: active ? AppColors.primaryBlue : AppColors.textSecondary,
//         size: 22,
//       ),
//     );
//   }

//   Widget _titleBlock(Device d, String subtitle) {
//     return Expanded(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             d.name,
//             style: const TextStyle(
//               color: AppColors.textPrimary,
//               fontSize: 15,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 2),
//           Text(
//             d.online ? subtitle : '$subtitle · hors ligne',
//             style: TextStyle(
//               color: d.online ? AppColors.textSecondary : AppColors.warning,
//               fontSize: 13,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _lightCard(Device d) {
//     return _card(
//       child: Row(
//         children: [
//           _iconBox(Icons.lightbulb_outline_rounded, d.isOn),
//           const SizedBox(width: 14),
//           _titleBlock(d, d.isOn ? 'Allumé' : 'Éteint'),
//           Switch(
//             value: d.isOn,
//             onChanged: _busy.contains(d.id)
//                 ? null
//                 : (v) => _send(d, v ? 'on' : 'off'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _fanCard(Device d) {
//     return _card(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               _iconBox(Icons.mode_fan_off_rounded, d.isOn),
//               const SizedBox(width: 14),
//               _titleBlock(d, d.isOn ? '${d.value.round()}%' : 'Éteint'),
//               Switch(
//                 value: d.isOn,
//                 onChanged: _busy.contains(d.id)
//                     ? null
//                     : (v) => _send(d, v ? 'on' : 'off'),
//               ),
//             ],
//           ),
//           if (d.isOn) ...[
//             const SizedBox(height: 8),
//             _slider(
//               value: d.value,
//               max: 100,
//               onChanged: (v) => setState(() => d.state['value'] = v),
//               onChangeEnd: (v) => _send(d, 'set_speed', v.round()),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _doorCard(Device d) {
//     final locked = d.isLocked;
//     return _card(
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: (locked ? AppColors.primaryBlue : AppColors.warning)
//                   .withValues(alpha: 0.15),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               locked ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
//               color: locked ? AppColors.primaryBlue : AppColors.warning,
//               size: 22,
//             ),
//           ),
//           const SizedBox(width: 14),
//           _titleBlock(d, locked ? 'Verrouillée' : 'Déverrouillée'),
//           ElevatedButton(
//             onPressed: _busy.contains(d.id)
//                 ? null
//                 : () => _send(d, locked ? 'unlock' : 'lock'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor:
//                   locked ? AppColors.surfaceLight : AppColors.primaryBlue,
//               shape:
//                   RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               elevation: 0,
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             ),
//             child: Text(
//               locked ? 'Déverrouiller' : 'Verrouiller',
//               style: const TextStyle(
//                   color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _tvCard(Device d) {
//     final busy = _busy.contains(d.id);
//     Widget btn(IconData icon, String label, String action) =>
//         _remoteKey(icon, label, busy ? null : () => _send(d, action));
//     return _card(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               _iconBox(Icons.tv_rounded, d.online),
//               const SizedBox(width: 14),
//               _titleBlock(d, 'Télécommande'),
//             ],
//           ),
//           const SizedBox(height: 14),
//           Wrap(
//             spacing: 10,
//             runSpacing: 10,
//             children: [
//               btn(Icons.power_settings_new_rounded, 'Marche', 'power'),
//               btn(Icons.volume_down_rounded, 'Vol -', 'volume_down'),
//               btn(Icons.volume_up_rounded, 'Vol +', 'volume_up'),
//               btn(Icons.volume_off_rounded, 'Muet', 'mute'),
//               btn(Icons.keyboard_arrow_down_rounded, 'Chaîne -', 'channel_down'),
//               btn(Icons.keyboard_arrow_up_rounded, 'Chaîne +', 'channel_up'),
//               btn(Icons.home_rounded, 'Accueil', 'home'),
//               btn(Icons.input_rounded, 'Source', 'source'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _remoteKey(IconData icon, String label, VoidCallback? onTap) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(14),
//       child: Container(
//         width: 76,
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         decoration: BoxDecoration(
//           color: AppColors.surfaceLight,
//           borderRadius: BorderRadius.circular(14),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               color: onTap == null ? AppColors.textSecondary : AppColors.primaryBlue,
//               size: 22,
//             ),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _servoCard(Device d) {
//     return _card(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               _iconBox(Icons.settings_input_component_rounded, true),
//               const SizedBox(width: 14),
//               _titleBlock(d, 'Angle'),
//               Text(
//                 '${d.value.round()}°',
//                 style: const TextStyle(
//                   color: AppColors.primaryBlue,
//                   fontSize: 15,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           _slider(
//             value: d.value,
//             max: 180,
//             onChanged: (v) => setState(() => d.state['value'] = v),
//             onChangeEnd: (v) => _send(d, 'set_angle', v.round()),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _slider({
//     required double value,
//     required double max,
//     required ValueChanged<double> onChanged,
//     required ValueChanged<double> onChangeEnd,
//   }) {
//     return SliderTheme(
//       data: SliderTheme.of(context).copyWith(
//         activeTrackColor: AppColors.primaryBlue,
//         inactiveTrackColor: AppColors.surfaceLight,
//         thumbColor: AppColors.primaryBlue,
//         overlayColor: AppColors.primaryBlue.withValues(alpha: 0.2),
//         trackHeight: 4,
//       ),
//       child: Slider(
//         value: value.clamp(0, max).toDouble(),
//         min: 0,
//         max: max,
//         onChanged: onChanged,
//         onChangeEnd: onChangeEnd,
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../services/device_service.dart';
import '../services/home_session.dart';
import '../themes/app_themes.dart';
import '../widgets/home_switcher.dart';

/// Écran « Contrôle » : il affiche les appareils et réagit aux gestes.
/// Les échanges avec le serveur sont dans services/device_service.dart.
class DeviceControlScreen extends StatefulWidget {
  const DeviceControlScreen({super.key});

  @override
  State<DeviceControlScreen> createState() => _DeviceControlScreenState();
}

class _DeviceControlScreenState extends State<DeviceControlScreen> {
  List<Device> _devices = [];
  bool _loading = true;
  String? _error;
  final Set<int> _busy = {};
  final Map<int, double> _hue = {}; // teinte en cours de réglage (0-360)

  @override
  void initState() {
    super.initState();
    HomeSession.instance.changes.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    HomeSession.instance.changes.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _devices = await DeviceService.instance.fetchDevices();
    } on DeviceServiceException catch (e) {
      _error = e.message;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _send(Device d, String action, [Object? value]) async {
    setState(() => _busy.add(d.id));
    try {
      final updated = await DeviceService.instance.sendCommand(d.id, action, value);
      final i = _devices.indexWhere((x) => x.id == d.id);
      if (i != -1) _devices[i] = updated;
    } on DeviceServiceException catch (e) {
      _message(e.message);
    }
    if (mounted) setState(() => _busy.remove(d.id));
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              _buildHeader(),
              const SizedBox(height: 28),
              ..._buildBody(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBody() {
    if (_loading && _devices.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.only(top: 60),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (_error != null) {
      return [
        _info(_error!),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: _load, child: const Text('Réessayer')),
      ];
    }
    if (_devices.isEmpty) {
      return [
        _info("Aucun appareil pour le moment. Ajoutez-en depuis l'onglet Profil."),
      ];
    }

    final lights = _devices.where((d) => d.type == 'light').toList();
    final fans = _devices.where((d) => d.type == 'fan').toList();
    final doors = _devices.where((d) => d.type == 'door').toList();
    final servos = _devices.where((d) => d.type == 'servo').toList();
    final tvs = _devices.where((d) => d.type == 'tv').toList();

    final widgets = <Widget>[];
    void section(String title, List<Device> items, Widget Function(Device) card) {
      if (items.isEmpty) return;
      if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 28));
      widgets.add(_sectionTitle(title));
      widgets.add(const SizedBox(height: 12));
      for (var i = 0; i < items.length; i++) {
        if (i > 0) widgets.add(const SizedBox(height: 12));
        widgets.add(card(items[i]));
      }
    }

    section('Éclairage', lights, (d) => d.supportsColor ? _ledCard(d) : _lightCard(d));
    section('Ventilation', fans, _fanCard);
    section('Sécurité', doors, _doorCard);
    section('Télévision', tvs, _tvCard);
    section('Servo (angle)', servos, _servoCard);

    if (widgets.isEmpty) {
      widgets.add(_info('Aucun appareil commandable pour le moment.'));
    }
    return widgets;
  }

  Widget _info(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeSwitcher(),
            SizedBox(height: 10),
            Text(
              'Contrôle',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Gérez vos appareils en direct',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
        IconButton(
          onPressed: _load,
          icon: const Icon(Icons.refresh_rounded,
              color: AppColors.primaryBlue, size: 20),
          style: IconButton.styleFrom(backgroundColor: AppColors.surface),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  // ── Cartes ────────────────────────────────────────────────────────────

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }

  Widget _iconBox(IconData icon, bool active) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primaryBlue.withValues(alpha: 0.15)
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: active ? AppColors.primaryBlue : AppColors.textSecondary,
        size: 22,
      ),
    );
  }

  Widget _titleBlock(Device d, String subtitle) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            d.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            d.online ? subtitle : '$subtitle · hors ligne',
            style: TextStyle(
              color: d.online ? AppColors.textSecondary : AppColors.warning,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _lightCard(Device d) {
    return _card(
      child: Row(
        children: [
          _iconBox(Icons.lightbulb_outline_rounded, d.isOn),
          const SizedBox(width: 14),
          _titleBlock(d, d.isOn ? 'Allumé' : 'Éteint'),
          Switch(
            value: d.isOn,
            onChanged: _busy.contains(d.id)
                ? null
                : (v) => _send(d, v ? 'on' : 'off'),
          ),
        ],
      ),
    );
  }

  // ── Bande LED / ampoule colorée : luminosité + couleur ────────────────

  static const _presets = <String>[
    '#FFFFFF', '#FFC58F', '#FF0000', '#FF8000', '#FFFF00',
    '#00FF00', '#00FFFF', '#0000FF', '#8000FF', '#FF00AA',
  ];

  Color _fromHex(String hex) =>
      Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));

  String _toHex(Color c) {
    String two(double v) =>
        (v * 255).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
    return '#${two(c.r)}${two(c.g)}${two(c.b)}'.toUpperCase();
  }

  Widget _ledCard(Device d) {
    final hex = d.colorHex;
    final current = hex == null ? null : _fromHex(hex);
    final hue = _hue[d.id] ??
        (current == null ? 0.0 : HSVColor.fromColor(current).hue);
    final tint = (d.isOn && current != null) ? current : null;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (tint ?? AppColors.primaryBlue)
                      .withValues(alpha: d.isOn ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.lightbulb_rounded,
                  color: d.isOn ? (tint ?? AppColors.primaryBlue) : AppColors.textSecondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              _titleBlock(d, d.isOn ? 'Allumé · ${d.value.round()}%' : 'Éteint'),
              Switch(
                value: d.isOn,
                onChanged: _busy.contains(d.id)
                    ? null
                    : (v) => _send(d, v ? 'on' : 'off'),
              ),
            ],
          ),
          if (d.isOn) ...[
            const SizedBox(height: 12),
            _smallLabel('Luminosité'),
            Row(
              children: [
                const Icon(Icons.brightness_low_rounded,
                    color: AppColors.textSecondary, size: 18),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primaryBlue,
                      inactiveTrackColor: AppColors.surfaceLight,
                      thumbColor: AppColors.primaryBlue,
                      overlayColor: AppColors.primaryBlue.withValues(alpha: 0.2),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: d.value.clamp(1, 100).toDouble(),
                      min: 1,
                      max: 100,
                      onChanged: (v) => setState(() => d.state['value'] = v),
                      onChangeEnd: (v) => _send(d, 'set_brightness', v.round()),
                    ),
                  ),
                ),
                const Icon(Icons.brightness_high_rounded,
                    color: AppColors.textSecondary, size: 18),
              ],
            ),
            const SizedBox(height: 4),
            _smallLabel('Couleur'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final p in _presets) _colorDot(d, p, hex),
              ],
            ),
            const SizedBox(height: 12),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: LinearGradient(colors: [
                      for (var i = 0; i <= 6; i++)
                        HSVColor.fromAHSV(1, i * 60.0, 1, 1).toColor(),
                    ]),
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 10,
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                    thumbColor: Colors.white,
                    overlayColor: Colors.white.withValues(alpha: 0.2),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                  ),
                  child: Slider(
                    value: hue.clamp(0, 360).toDouble(),
                    min: 0,
                    max: 360,
                    onChanged: (v) => setState(() => _hue[d.id] = v),
                    onChangeEnd: (v) {
                      final c = HSVColor.fromAHSV(1, v, 1, 1).toColor();
                      _send(d, 'set_color', _toHex(c));
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _smallLabel(String text) {
    return Text(
      text,
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
    );
  }

  Widget _colorDot(Device d, String hex, String? currentHex) {
    final selected = currentHex != null && currentHex.toUpperCase() == hex;
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: _busy.contains(d.id)
          ? null
          : () {
              _hue.remove(d.id);
              _send(d, 'set_color', hex);
            },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: _fromHex(hex),
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.primaryBlue : AppColors.surfaceLight,
            width: selected ? 3 : 1,
          ),
        ),
      ),
    );
  }

  Widget _fanCard(Device d) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(Icons.mode_fan_off_rounded, d.isOn),
              const SizedBox(width: 14),
              _titleBlock(d, d.isOn ? '${d.value.round()}%' : 'Éteint'),
              Switch(
                value: d.isOn,
                onChanged: _busy.contains(d.id)
                    ? null
                    : (v) => _send(d, v ? 'on' : 'off'),
              ),
            ],
          ),
          if (d.isOn) ...[
            const SizedBox(height: 8),
            _slider(
              value: d.value,
              max: 100,
              onChanged: (v) => setState(() => d.state['value'] = v),
              onChangeEnd: (v) => _send(d, 'set_speed', v.round()),
            ),
          ],
        ],
      ),
    );
  }

  Widget _doorCard(Device d) {
    final locked = d.isLocked;
    return _card(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (locked ? AppColors.primaryBlue : AppColors.warning)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              locked ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
              color: locked ? AppColors.primaryBlue : AppColors.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          _titleBlock(d, locked ? 'Verrouillée' : 'Déverrouillée'),
          ElevatedButton(
            onPressed: _busy.contains(d.id)
                ? null
                : () => _send(d, locked ? 'unlock' : 'lock'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  locked ? AppColors.surfaceLight : AppColors.primaryBlue,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              locked ? 'Déverrouiller' : 'Verrouiller',
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tvCard(Device d) {
    final busy = _busy.contains(d.id);
    Widget btn(IconData icon, String label, String action) =>
        _remoteKey(icon, label, busy ? null : () => _send(d, action));
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(Icons.tv_rounded, d.online),
              const SizedBox(width: 14),
              _titleBlock(d, 'Télécommande'),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              btn(Icons.power_settings_new_rounded, 'Marche', 'power'),
              btn(Icons.volume_down_rounded, 'Vol -', 'volume_down'),
              btn(Icons.volume_up_rounded, 'Vol +', 'volume_up'),
              btn(Icons.volume_off_rounded, 'Muet', 'mute'),
              btn(Icons.keyboard_arrow_down_rounded, 'Chaîne -', 'channel_down'),
              btn(Icons.keyboard_arrow_up_rounded, 'Chaîne +', 'channel_up'),
              btn(Icons.home_rounded, 'Accueil', 'home'),
              btn(Icons.input_rounded, 'Source', 'source'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _remoteKey(IconData icon, String label, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: onTap == null ? AppColors.textSecondary : AppColors.primaryBlue,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _servoCard(Device d) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(Icons.settings_input_component_rounded, true),
              const SizedBox(width: 14),
              _titleBlock(d, 'Angle'),
              Text(
                '${d.value.round()}°',
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          _slider(
            value: d.value,
            max: 180,
            onChanged: (v) => setState(() => d.state['value'] = v),
            onChangeEnd: (v) => _send(d, 'set_angle', v.round()),
          ),
        ],
      ),
    );
  }

  Widget _slider({
    required double value,
    required double max,
    required ValueChanged<double> onChanged,
    required ValueChanged<double> onChangeEnd,
  }) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: AppColors.primaryBlue,
        inactiveTrackColor: AppColors.surfaceLight,
        thumbColor: AppColors.primaryBlue,
        overlayColor: AppColors.primaryBlue.withValues(alpha: 0.2),
        trackHeight: 4,
      ),
      child: Slider(
        value: value.clamp(0, max).toDouble(),
        min: 0,
        max: max,
        onChanged: onChanged,
        onChangeEnd: onChangeEnd,
      ),
    );
  }
}