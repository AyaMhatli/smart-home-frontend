import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/device_service.dart';
import '../services/profile_service.dart';
import '../services/home_session.dart';
import '../themes/app_themes.dart';
import '../widgets/home_switcher.dart';
import 'discovered_devices_screen.dart';
import '../devices/auth/sign_in_screen.dart';

/// Écran « Profil » : compte, liste des appareils, déconnexion.
/// Données : services/profile_service.dart et services/device_service.dart.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
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

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ProfileService.instance.fetchProfile(),
        DeviceService.instance.fetchDevices(),
      ]);
      _profile = results[0] as UserProfile;
      _devices = results[1] as List<Device>;
    } on ProfileServiceException catch (e) {
      _error = e.message;
    } on DeviceServiceException catch (e) {
      _error = e.message;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _addDevice() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DiscoveredDevicesScreen()),
    );
    // Au retour, on recharge la liste (un appareil a peut-être été ajouté)
    if (mounted) _load();
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    await HomeSession.instance.reset();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );
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
            ..._buildTop(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _addDevice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  '+ Ajouter un appareil',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle('Paramètres'),
            const SizedBox(height: 12),
            _buildCard([
              _settingRow('Notifications', ''),
              _settingRow('Assistant vocal', 'Français'),
              _settingRow('Réseau et MQTT', ''),
            ]),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _logout,
              child: const Text(
                'Se déconnecter',
                style: TextStyle(
                    color: AppColors.danger,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// En-tête + statistiques + liste des appareils (selon l'état du chargement)
  List<Widget> _buildTop() {
    if (_loading && _profile == null) {
      return const [
        Padding(
          padding: EdgeInsets.only(top: 60),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (_error != null || _profile == null) {
      return [
        _info(_error ?? 'Aucune donnée'),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: _load, child: const Text('Réessayer')),
      ];
    }
    final p = _profile!;
    return [
      _buildUserHeader(p),
      const SizedBox(height: 16),
      const Align(alignment: Alignment.centerLeft, child: HomeSwitcher()),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(child: _statCard('${_devices.length}', 'Appareils')),
          const SizedBox(width: 12),
          Expanded(
              child: _statCard(
                  '${_devices.where((d) => d.online).length}', 'En ligne')),
        ],
      ),
      const SizedBox(height: 24),
      _sectionTitle('Mes appareils'),
      const SizedBox(height: 12),
      _devices.isEmpty
          ? _info("Aucun appareil. Appuyez sur « Ajouter un appareil ».")
          : _buildCard(_devices.map(_deviceRow).toList()),
    ];
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

  Widget _buildUserHeader(UserProfile p) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
              shape: BoxShape.circle, color: AppColors.primaryBlue),
          alignment: Alignment.center,
          child: Text(
            p.name[0].toUpperCase(),
            style: const TextStyle(
                color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                p.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildCard(List<Widget> rows) {
    final children = <Widget>[];
    for (int i = 0; i < rows.length; i++) {
      if (i > 0) {
        children.add(const Divider(height: 1, color: AppColors.surfaceLight));
      }
      children.add(rows[i]);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
      child: Column(children: children),
    );
  }

  Widget _deviceRow(Device d) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: d.online ? AppColors.success : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(d.name,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14)),
          ),
          Text(
            d.online ? 'En ligne' : 'Hors ligne',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _settingRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14)),
          ),
          if (value.isNotEmpty)
            Text('$value  ',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textSecondary, size: 20),
        ],
      ),
    );
  }
}
