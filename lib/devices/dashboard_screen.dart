import 'package:flutter/material.dart';
import 'package:smart_home/services/device_service.dart';
import '../services/summary_service.dart';
import '../services/home_session.dart';
import '../themes/app_themes.dart';
import '../widgets/home_switcher.dart';

/// Écran « Accueil » : résumé de la maison.
/// Données : services/summary_service.dart et services/device_service.dart.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}


class _DashboardScreenState extends State<DashboardScreen> {
  HomeSummary? _summary;
  List<Device> _devices = [];
  bool _loading = true;
  String? _error;

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
  Future<void> _confirmDelete(Device d) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cet appareil ?'),
        content: Text('« ${d.name} » sera retiré de votre maison.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    try {
      await DeviceService.instance.deleteDevice(d.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('« ${d.name} » supprimé')));
      _load();
    } on DeviceServiceException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        SummaryService.instance.fetchSummary(),
        DeviceService.instance.fetchDevices(),
      ]);
      _summary = results[0] as HomeSummary;
      _devices = results[1] as List<Device>;
    } on SummaryServiceException catch (e) {
      _error = e.message;
    } on DeviceServiceException catch (e) {
      _error = e.message;
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            ..._buildBody(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBody() {
    if (_loading && _summary == null) {
      return const [
        Padding(
          padding: EdgeInsets.only(top: 60),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    final session = HomeSession.instance;
    if (session.loaded && session.homes.isEmpty) {
      return const [NoHomeCard()];
    }
    if (_error != null || _summary == null) {
      return [
        _info(_error ?? 'Aucune donnée'),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: _load, child: const Text('Réessayer')),
      ];
    }
    final s = _summary!;
    return [
      _buildWeatherCard(s),
      const SizedBox(height: 24),
      _sectionTitle('Aperçu rapide'),
      const SizedBox(height: 12),
      _buildQuickStatsRow(s),
      const SizedBox(height: 24),
      _sectionTitle('Appareils'),
      const SizedBox(height: 12),
      _buildDeviceGrid(),
    ];
  }

  // ── En-tête ───────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final s = _summary;
    final subtitle = s == null
        ? 'Chargement…'
        : '${s.devicesOnline}/${s.devicesTotal} appareils en ligne';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeSwitcher(),
            const SizedBox(height: 12),
            const Text(
              'Bonjour 👋',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14),
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

  // ── Température ───────────────────────────────────────────────────────

  Widget _buildWeatherCard(HomeSummary s) {
    final temp =
        s.temperature == null ? '--' : '${s.temperature!.toStringAsFixed(1)}°C';
    final hum = s.humidity == null
        ? 'Humidité --'
        : 'Humidité ${s.humidity!.round()}%';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue.withValues(alpha: 0.9),
            AppColors.primaryBlue.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Intérieur',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              Text(
                temp,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(hum,
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.thermostat_rounded,
                color: Colors.white, size: 36),
          ),
        ],
      ),
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

  // ── Aperçu rapide ─────────────────────────────────────────────────────

  Widget _buildQuickStatsRow(HomeSummary s) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.lightbulb_outline_rounded,
            value: '${s.lightsOn}/${s.lightsTotal}',
            label: 'Lumières allumées',
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: s.doorsLocked
                ? Icons.lock_outline_rounded
                : Icons.lock_open_rounded,
            value: s.doorsLocked ? 'OK' : 'Ouverte',
            label: s.doorsLocked ? 'Portes verrouillées' : 'Porte déverrouillée',
            color: s.doorsLocked ? AppColors.success : AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── Appareils ─────────────────────────────────────────────────────────

  IconData _iconFor(Device d) {
    switch (d.type) {
      case 'light':
        return Icons.lightbulb_rounded;
      case 'fan':
        return Icons.mode_fan_off_rounded;
      case 'door':
        return Icons.sensor_door_rounded;
      case 'servo':
        return Icons.settings_input_component_rounded;
      case 'tv':
        return Icons.tv_rounded;
      default:
        return Icons.sensors_rounded;
    }
  }

  // Widget _buildDeviceGrid() {
  //   if (_devices.isEmpty) {
  //     return _info("Aucun appareil. Ajoutez-en depuis l'onglet Profil.");
  //   }
  //   return GridView.builder(
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: 4,
  //       mainAxisSpacing: 10,
  //       crossAxisSpacing: 10,
  //       childAspectRatio: 1.4,
  //     ),
  //     itemCount: _devices.length,
  //     itemBuilder: (context, index) {
  //       final d = _devices[index];
  //       final active = d.online && (d.type == 'door' ? d.isLocked : d.isOn);
  //       return Container(
  //         padding: const EdgeInsets.all(14),
  //         decoration: BoxDecoration(
  //           color: AppColors.surface,
  //           borderRadius: BorderRadius.circular(18),
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Container(
  //                   padding: const EdgeInsets.all(8),
  //                   decoration: BoxDecoration(
  //                     color: active
  //                         ? AppColors.primaryBlue.withValues(alpha: 0.15)
  //                         : AppColors.surfaceLight,
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //                   child: Icon(
  //                     _iconFor(d),
  //                     color: active
  //                         ? AppColors.primaryBlue
  //                         : AppColors.textSecondary,
  //                     size: 18,
  //                   ),
  //                 ),
  //                 // Point vert = appareil en ligne
  //                 Container(
  //                   width: 4,
  //                   height: 4,
  //                   decoration: BoxDecoration(
  //                     color: d.online
  //                         ? AppColors.success
  //                         : AppColors.textSecondary,
  //                     shape: BoxShape.circle,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             Text(
  //               d.name,
  //               maxLines: 1,
  //               overflow: TextOverflow.ellipsis,
  //               style: const TextStyle(
  //                 color: AppColors.textPrimary,
  //                 fontSize: 14,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
    Widget _buildDeviceGrid() {
    if (_devices.isEmpty) {
      return _info("Aucun appareil. Ajoutez-en depuis l'onglet Profil.");
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.6,
      ),
      itemCount: _devices.length,
      itemBuilder: (context, index) {
        final d = _devices[index];
        final active = d.online && (d.type == 'door' ? d.isLocked : d.isOn);
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primaryBlue.withValues(alpha: 0.15)
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _iconFor(d),
                      color: active
                          ? AppColors.primaryBlue
                          : AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                  Row(
                    children: [
                      // Point vert = appareil en ligne
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: d.online
                              ? AppColors.success
                              : AppColors.textSecondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Poubelle : supprimer l'appareil
                      InkWell(
                        onTap: () => _confirmDelete(d),
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.delete_outline_rounded,
                              color: Colors.redAccent, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                d.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
