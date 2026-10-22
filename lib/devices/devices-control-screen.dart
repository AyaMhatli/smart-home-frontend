import 'package:flutter/material.dart';
import 'package:app_pfe/themes/app_themes.dart'; // pour réutiliser AppColors

class DeviceControlScreen extends StatefulWidget {
  const DeviceControlScreen({super.key});

  @override
  State<DeviceControlScreen> createState() => _DeviceControlScreenState();
}

class _DeviceControlScreenState extends State<DeviceControlScreen> {
  bool _lightLivingRoom = true;
  bool _lightBedroom = false;
  bool _fanOn = false;
  double _fanSpeed = 40;
  bool _doorLocked = true;
  double _servoAngle = 90;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            _buildHeader(context),
            const SizedBox(height: 28),

            _sectionTitle('Éclairage'),
            const SizedBox(height: 12),
            _buildToggleCard(
              icon: Icons.lightbulb_outline_rounded,
              title: 'Salon',
              subtitle: _lightLivingRoom ? 'Allumé' : 'Éteint',
              value: _lightLivingRoom,
              onChanged: (v) => setState(() => _lightLivingRoom = v),
            ),
            const SizedBox(height: 12),
            _buildToggleCard(
              icon: Icons.lightbulb_outline_rounded,
              title: 'Chambre',
              subtitle: _lightBedroom ? 'Allumé' : 'Éteint',
              value: _lightBedroom,
              onChanged: (v) => setState(() => _lightBedroom = v),
            ),

            const SizedBox(height: 28),
            _sectionTitle('Ventilation'),
            const SizedBox(height: 12),
            _buildSliderCard(
              icon: Icons.mode_fan_off_rounded,
              title: 'Ventilateur',
              subtitle: _fanOn ? '${_fanSpeed.round()}%' : 'Éteint',
              isOn: _fanOn,
              onToggle: (v) => setState(() => _fanOn = v),
              value: _fanSpeed,
              onChanged: (v) => setState(() => _fanSpeed = v),
            ),

            const SizedBox(height: 28),
            _sectionTitle('Sécurité'),
            const SizedBox(height: 12),
            _buildDoorCard(),

            const SizedBox(height: 28),
            _sectionTitle('Servo (angle)'),
            const SizedBox(height: 12),
            _buildServoCard(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
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
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.wifi_rounded, color: AppColors.primaryBlue, size: 20),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildToggleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: value
                  ? AppColors.primaryBlue.withOpacity(0.15)
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: value ? AppColors.primaryBlue : AppColors.textSecondary,
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
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryBlue,
            inactiveTrackColor: AppColors.surfaceLight,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isOn,
    required ValueChanged<bool> onToggle,
    required double value,
    required ValueChanged<double> onChanged,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isOn
                      ? AppColors.primaryBlue.withOpacity(0.15)
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isOn ? AppColors.primaryBlue : AppColors.textSecondary,
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
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isOn,
                onChanged: onToggle,
                activeColor: AppColors.primaryBlue,
                inactiveTrackColor: AppColors.surfaceLight,
              ),
            ],
          ),
          if (isOn) ...[
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primaryBlue,
                inactiveTrackColor: AppColors.surfaceLight,
                thumbColor: AppColors.primaryBlue,
                overlayColor: AppColors.primaryBlue.withOpacity(0.2),
                trackHeight: 4,
              ),
              child: Slider(
                value: value,
                min: 0,
                max: 100,
                onChanged: onChanged,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDoorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _doorLocked
                  ? AppColors.primaryBlue.withOpacity(0.15)
                  : Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _doorLocked ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
              color: _doorLocked ? AppColors.primaryBlue : Colors.orange,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Porte principale',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _doorLocked ? 'Verrouillée' : 'Déverrouillée',
                  style: TextStyle(
                    color: _doorLocked ? AppColors.textSecondary : Colors.orange,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => setState(() => _doorLocked = !_doorLocked),
            style: ElevatedButton.styleFrom(
              backgroundColor: _doorLocked ? AppColors.surfaceLight : AppColors.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              _doorLocked ? 'Déverrouiller' : 'Verrouiller',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.settings_input_component_rounded,
                      color: AppColors.primaryBlue, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'SG90 - Volet',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '${_servoAngle.round()}°',
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primaryBlue,
              inactiveTrackColor: AppColors.surfaceLight,
              thumbColor: AppColors.primaryBlue,
              overlayColor: AppColors.primaryBlue.withOpacity(0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: _servoAngle,
              min: 0,
              max: 180,
              onChanged: (v) => setState(() => _servoAngle = v),
            ),
          ),
        ],
      ),
    );
  }
}