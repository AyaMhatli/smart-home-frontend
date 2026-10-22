import 'package:flutter/material.dart';
import '../themes/app_themes.dart';

/// Écran de monitoring environnemental — historique température/humidité
/// depuis tes capteurs DHT22.
///
/// Utilise le package `fl_chart` pour les graphiques.
/// Ajoute dans ton pubspec.yaml :
///   dependencies:
///     fl_chart: ^0.68.0
class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  String _selectedPeriod = '24h';
  final List<String> _periods = ['24h', '7j', '30j'];

  // Données statiques d'exemple — à remplacer par ton API Django
  // (GET /api/sensors/history/?period=24h)
  final List<double> _temperatureData = [22, 22.5, 23, 24, 25, 24.5, 23.5, 23];
  final List<double> _humidityData = [45, 46, 44, 42, 40, 43, 47, 48];
  final List<String> _timeLabels = ['00h', '03h', '06h', '09h', '12h', '15h', '18h', '21h'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _buildHeader(),
          const SizedBox(height: 20),

          _buildPeriodSelector(),
          const SizedBox(height: 24),

          _buildCurrentStatsRow(),
          const SizedBox(height: 24),

          _sectionTitle('Température (°C)'),
          const SizedBox(height: 12),
          _buildChartCard(
            data: _temperatureData,
            color: AppColors.primaryBlue,
            unit: '°C',
          ),
          const SizedBox(height: 24),

          _sectionTitle('Humidité (%)'),
          const SizedBox(height: 12),
          _buildChartCard(
            data: _humidityData,
            color: const Color(0xFF4FC3F7),
            unit: '%',
          ),
          const SizedBox(height: 24),

          _sectionTitle('Capteurs actifs'),
          const SizedBox(height: 12),
          _buildSensorList(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monitoring',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Historique de vos capteurs',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: _periods.map((period) {
        final isSelected = _selectedPeriod == period;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () => setState(() => _selectedPeriod = period),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBlue : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                period,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCurrentStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _liveStatCard(
            icon: Icons.thermostat_rounded,
            value: '${_temperatureData.last}°C',
            label: 'Actuellement',
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _liveStatCard(
            icon: Icons.water_drop_rounded,
            value: '${_humidityData.last.round()}%',
            label: 'Humidité',
            color: const Color(0xFF4FC3F7),
          ),
        ),
      ],
    );
  }

  Widget _liveStatCard({
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
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

  /// Graphique en courbe simple dessiné à la main (CustomPainter),
  /// sans dépendance externe. Si tu préfères fl_chart pour plus
  /// d'options (tooltips, zoom...), remplace ce widget par un LineChart.
  Widget _buildChartCard({
    required List<double> data,
    required Color color,
    required String unit,
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
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CustomPaint(
              painter: _LineChartPainter(data: data, color: color),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _timeLabels
                .map((t) => Text(
                      t,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorList() {
    final sensors = [
      _SensorInfo(name: 'DHT22 - Salon', status: 'En ligne', isOnline: true),
      _SensorInfo(name: 'DHT22 - Chambre', status: 'En ligne', isOnline: true),
      _SensorInfo(name: 'PIR - Entrée', status: 'Hors ligne', isOnline: false),
    ];

    return Column(
      children: sensors
          .map(
            (s) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: s.isOnline ? AppColors.success : AppColors.textSecondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      s.name,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                    ),
                  ),
                  Text(
                    s.status,
                    style: TextStyle(
                      color: s.isOnline ? AppColors.success : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SensorInfo {
  final String name;
  final String status;
  final bool isOnline;
  _SensorInfo({required this.name, required this.status, required this.isOnline});
}

/// Dessine une courbe simple à partir d'une liste de valeurs.
/// Léger, sans dépendance — suffisant pour un premier rendu visuel.
class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _LineChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final range = (maxVal - minVal).abs() < 0.001 ? 1 : maxVal - minVal;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.25), color.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = stepX * i;
      final normalized = (data[i] - minVal) / range;
      final y = size.height - (normalized * size.height * 0.85) - size.height * 0.1;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      // Point sur la courbe
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = color);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.color != color;
  }
}

