import 'package:flutter/material.dart';
import '../services/device_service.dart';
import '../themes/app_themes.dart';

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

  @override
  void initState() {
    super.initState();
    _load();
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

  Future<void> _send(Device d, String action, [num? value]) async {
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

    section('Éclairage', lights, _lightCard);
    section('Ventilation', fans, _fanCard);
    section('Sécurité', doors, _doorCard);
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
