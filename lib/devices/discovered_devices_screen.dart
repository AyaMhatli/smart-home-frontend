import 'dart:async';
import 'package:flutter/material.dart';
import '../services/device_discovery_service.dart';
import '../services/device_service.dart';
import '../services/network_service.dart';
import 'add_device_manual_screen.dart';
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

  // Scan du réseau par le serveur
  List<NetworkHost> _hosts = [];
  bool _scanning = false;
  bool _scanned = false;
  String? _scanError;

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

  Future<void> _scanNetwork() async {
    setState(() {
      _scanning = true;
      _scanError = null;
    });
    try {
      _hosts = await NetworkService.instance.scan();
      _scanned = true;
    } on NetworkServiceException catch (e) {
      _scanError = e.message;
    }
    if (mounted) setState(() => _scanning = false);
  }

  Future<void> _addHost(NetworkHost h) async {
    setState(() => _adding.add(h.ip));
    try {
      await DeviceService.instance.addManual(
        name: h.name.isNotEmpty ? h.name : 'Appareil ${h.ip}',
        type: DeviceService.typeForKind(h.kind),
        integration: h.kind,
        host: h.ip,
      );
      if (mounted) setState(() => _added.add(h.ip));
      _showMessage('Appareil ajouté');
    } on DeviceServiceException catch (e) {
      _showMessage(e.message);
    }
    if (mounted) setState(() => _adding.remove(h.ip));
  }

  Future<void> _openManual() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddDeviceManualScreen()),
    );
    if (added == true) _showMessage('Appareil ajouté');
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
              Expanded(child: _buildContent()),
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

  Widget _buildContent() {
    return ListView(
      children: [
        if (_found.isEmpty)
          SizedBox(height: 90, child: _buildEmpty())
        else
          for (final d in _found) ...[
            _deviceCard(d),
            const SizedBox(height: 10),
          ],
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _openManual,
            icon: const Icon(Icons.add_rounded, color: AppColors.primaryBlue),
            label: const Text(
              'Ajouter manuellement',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primaryBlue),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildNetworkSection(),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Appareil qui s'est annoncé lui-même : on sait le commander.
  Widget _deviceCard(DiscoveredDevice d) {
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
              color: AppColors.primaryBlue.withValues(alpha: 0.15),
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
                const SizedBox(height: 2),
                const Text(
                  'Commandable',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
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
  }

  // ── Autres appareils du réseau (vus par le serveur) ──────────────────

  Widget _buildNetworkSection() {
    final foundIps = _found.map((d) => d.ip).toSet();
    final others = _hosts.where((h) => !foundIps.contains(h.ip)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AUTRES APPAREILS SUR LE RÉSEAU',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Vus par le serveur, mais pas forcément pilotables.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: _scanning ? null : _scanNetwork,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.surfaceLight),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _scanning
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 10),
                      Text('Scan en cours…',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  )
                : Text(
                    _scanned ? 'Scanner à nouveau' : 'Scanner le réseau',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        if (_scanError != null)
          _note(_scanError!)
        else if (_scanned && others.isEmpty)
          _note('Aucun autre appareil trouvé.')
        else
          for (final h in others) ...[
            _hostCard(h),
            const SizedBox(height: 10),
          ],
      ],
    );
  }

  Widget _note(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
    );
  }

  /// Appareil vu sur le réseau. Reconnu (Samsung, WLED) : on peut l'ajouter.
  /// Sinon : détecté seulement.
  Widget _hostCard(NetworkHost h) {
    final title = h.name.isNotEmpty
        ? h.name
        : (h.vendor.isNotEmpty
            ? h.vendor
            : (h.privateMac ? 'Appareil (adresse privée)' : 'Appareil inconnu'));
    final ok = h.controllable;
    final added = _added.contains(h.ip);
    final adding = _adding.contains(h.ip);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ok
                  ? AppColors.primaryBlue.withValues(alpha: 0.15)
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              (h.kind == 'samsung_tv' || h.kind == 'roku')
                  ? Icons.tv_rounded
                  : (ok ? Icons.lightbulb_outline_rounded : Icons.devices_other_rounded),
              color: ok ? AppColors.primaryBlue : AppColors.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  h.ip,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  ok ? 'Commandable' : 'Détecté seulement',
                  style: TextStyle(
                    color: ok ? AppColors.success : AppColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!ok) ...[
                  const SizedBox(height: 2),
                  Text(
                    h.hint,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          if (ok)
            added
                ? const Icon(Icons.check_circle_rounded, color: AppColors.success)
                : ElevatedButton(
                    onPressed: adding ? null : () => _addHost(h),
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
  }
}
