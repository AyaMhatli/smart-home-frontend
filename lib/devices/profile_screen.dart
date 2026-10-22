import 'package:flutter/material.dart';
import '../themes/app_themes.dart';
import 'discovered_devices_screen.dart';
import 'auth/sign_in_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Données d'exemple — à remplacer par la réponse de ton API
  static const String _name = 'Aya';
  static const String _email = 'aya@exemple.com';
  static const List<_DeviceItem> _devices = [
    _DeviceItem('Lumière salon', true),
    _DeviceItem('Ventilateur', true),
    _DeviceItem('Capteur DHT22', false),
  ];

  @override
  Widget build(BuildContext context) {
    final online = _devices.where((d) => d.isOnline).length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _buildUserHeader(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _statCard('${_devices.length}', 'Appareils')),
              const SizedBox(width: 12),
              Expanded(child: _statCard('$online', 'En ligne')),
            ],
          ),
          const SizedBox(height: 24),
          _sectionTitle('Mes appareils'),
          const SizedBox(height: 12),
          _buildCard(
            _devices.map((d) => _deviceRow(d)).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DiscoveredDevicesScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                '+ Ajouter un appareil',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
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
            onPressed: () {
              // TODO: supprimer le token stocké (flutter_secure_storage)
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const SignInScreen()),
                (route) => false,
              );
            },
            child: const Text(
              'Se déconnecter',
              style: TextStyle(color: AppColors.danger, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryBlue),
          alignment: Alignment.center,
          child: Text(
            _name[0],
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _name,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2),
            Text(_email, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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
      if (i > 0) children.add(const Divider(height: 1, color: AppColors.surfaceLight));
      children.add(rows[i]);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
      child: Column(children: children),
    );
  }

  Widget _deviceRow(_DeviceItem d) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: d.isOnline ? AppColors.success : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(d.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
          ),
          Text(
            d.isOnline ? 'En ligne' : 'Hors ligne',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
            child: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
          ),
          if (value.isNotEmpty)
            Text('$value  ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
        ],
      ),
    );
  }
}

class _DeviceItem {
  final String name;
  final bool isOnline;
  const _DeviceItem(this.name, this.isOnline);
}