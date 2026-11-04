import 'dart:async';
import 'package:flutter/material.dart';
import '../services/device_discovery_service.dart';
import '../services/device_service.dart';
import '../themes/app_themes.dart';

/// Écran « Appareils détectés » : affiche les appareils trouvés
/// automatiquement sur le même Wi-Fi que le téléphone.
class DiscoveredDevicesScreen extends StatefulWidget {
  const DiscoveredDevicesScreen({super.key});

  @override
  State<DiscoveredDevicesScreen> createState() => _DiscoveredDevicesScreenState();
}

class _DiscoveredDevicesScreenState extends State<DiscoveredDevicesScreen>
    with SingleTickerProviderStateMixin {
  final DeviceDiscoveryService _service = DeviceDiscoveryService();
  late final AnimationController _radar;
  StreamSubscription<List<DiscoveredDevice>>? _sub;
  Timer? _searchTimer;

  List<DiscoveredDevice> _found = [];
  final Set<String> _added = {};
  final Set<String> _adding = {};
  bool _searching = true;

  @override
  void initState() {
    super.initState();
    _radar = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    _startSearch();
  }

  Future<void> _startSearch() async {
    setState(() => _searching = true);
    await _service.stop();
    await _sub?.cancel();
    await _service.start();
    _sub = _service.devices.listen((list) => setState(() => _found = list));
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) setState(() => _searching = false);
    });
  }

  Future<void> _addDevice(DiscoveredDevice d) async {
    setState(() => _adding.add(d.id));
    try {
      await DeviceService.instance
          .addDevice(uid: d.id, name: d.name, type: d.type);
      if (mounted) setState(() => _added.add(d.id));
      _showMessage('${d.name} ajouté');
    } on DeviceServiceException catch (e) {
      _showMessage(e.message);
    }
    if (mounted) setState(() => _adding.remove(d.id));
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _sub?.cancel();
    _service.dispose();
    _radar.dispose();
    super.dispose();
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'light':
        return Icons.lightbulb_outline_rounded;
      case 'fan':
        return Icons.mode_fan_off_rounded;
      case 'door':
        return Icons.sensor_door_outlined;
      case 'servo':
        return Icons.settings_input_component_rounded;
      case 'sensor':
        return Icons.thermostat_rounded;
      default:
        return Icons.devices_other_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Center(child: _buildRadar()),
              const SizedBox(height: 24),
              Text(
                _found.isEmpty
                    ? 'Aucun appareil pour le moment'
                    : '${_found.length} appareil(s) détecté(s)',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(child: _found.isEmpty ? _buildEmpty() : _buildList()),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: _startSearch,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryBlue),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Relancer la recherche',
                    style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
          style: IconButton.styleFrom(backgroundColor: AppColors.surface),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appareils détectés',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Sur le même Wi-Fi que votre téléphone',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRadar() {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_searching)
            AnimatedBuilder(
              animation: _radar,
              builder: (_, __) => Container(
                width: 140 * _radar.value,
                height: 140 * _radar.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryBlue.withOpacity(1 - _radar.value),
                    width: 2,
                  ),
                ),
              ),
            ),
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryBlue),
            child: const Icon(Icons.wifi_rounded, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Text(
        _searching
            ? 'Recherche en cours…'
            : "Vérifiez que l'appareil est allumé et connecté au même Wi-Fi.",
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      itemCount: _found.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final d = _found[i];
        final added = _added.contains(d.id);
        final adding = _adding.contains(d.id);
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_iconFor(d.type), color: AppColors.primaryBlue, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
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
                      d.ip,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              added
                  ? const Icon(Icons.check_circle_rounded, color: AppColors.success)
                  : ElevatedButton(
                      onPressed: adding ? null : () => _addDevice(d),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: adding
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Ajouter', style: TextStyle(color: Colors.white)),
                    ),
            ],
          ),
        );
      },
    );
  }
}