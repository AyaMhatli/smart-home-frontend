import 'package:flutter/material.dart';
import '../services/device_service.dart';
import '../services/sensor_service.dart';
import '../themes/app_themes.dart';

/// Écran « Monitoring » : courbes température / humidité.
/// Données : services/sensor_service.dart et services/device_service.dart.
class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  static const _humidityColor = Color(0xFF4FC3F7);

  String _selectedPeriod = '24h';
  final List<String> _periods = ['24h', '7j', '30j'];

  List<SensorPoint> _temps = []; // points qui ont une température
  List<SensorPoint> _hums = []; // points qui ont une humidité
  List<Device> _sensors = [];
  bool _loading = true;
  String? _error;

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
      final results = await Future.wait([
        SensorService.instance.fetchHistory(_selectedPeriod),
        DeviceService.instance.fetchDevices(),
      ]);
      final points = results[0] as List<SensorPoint>;
      _temps = points.where((p) => p.temperature != null).toList();
      _hums = points.where((p) => p.humidity != null).toList();
      _sensors =
          (results[1] as List<Device>).where((d) => d.type == 'sensor').toList();
    } on SensorServiceException catch (e) {
      _error = e.message;
    } on DeviceServiceException catch (e) {
      _error = e.message;
    }
    if (mounted) setState(() => _loading = false);
  }

  void _selectPeriod(String p) {
    if (p == _selectedPeriod) return;
    setState(() => _selectedPeriod = p);
    _load();
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
            const SizedBox(height: 20),
            _buildPeriodSelector(),
            const SizedBox(height: 24),
            ..._buildBody(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBody() {
    if (_loading) {
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
    return [
      _buildCurrentStatsRow(),
      const SizedBox(height: 24),
      _sectionTitle('Température (°C)'),
      const SizedBox(height: 12),
      _buildChartCard(
        points: _temps,
        value: (p) => p.temperature!,
        color: AppColors.primaryBlue,
      ),
      const SizedBox(height: 24),
      _sectionTitle('Humidité (%)'),
      const SizedBox(height: 12),
      _buildChartCard(
        points: _hums,
        value: (p) => p.humidity!,
        color: _humidityColor,
      ),
      const SizedBox(height: 24),
      _sectionTitle('Capteurs'),
      const SizedBox(height: 12),
      _buildSensorList(),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
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

  Widget _buildPeriodSelector() {
    return Row(
      children: _periods.map((period) {
        final isSelected = _selectedPeriod == period;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () => _selectPeriod(period),
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

  // ── Valeurs actuelles ─────────────────────────────────────────────────

  Widget _buildCurrentStatsRow() {
    final t = _temps.isEmpty ? '--' : '${_temps.last.temperature!.toStringAsFixed(1)}°C';
    final h = _hums.isEmpty ? '--' : '${_hums.last.humidity!.round()}%';
    return Row(
      children: [
        Expanded(
          child: _liveStatCard(
            icon: Icons.thermostat_rounded,
            value: t,
            label: 'Dernière température',
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _liveStatCard(
            icon: Icons.water_drop_rounded,
            value: h,
            label: 'Dernière humidité',
            color: _humidityColor,
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
              color: color.withValues(alpha: 0.15),
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
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11),
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
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  // ── Graphiques ────────────────────────────────────────────────────────

  String _label(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return _selectedPeriod == '24h'
        ? '${two(t.hour)}h${two(t.minute)}'
        : '${two(t.day)}/${two(t.month)}';
  }

  Widget _buildChartCard({
    required List<SensorPoint> points,
    required double Function(SensorPoint) value,
    required Color color,
  }) {
    if (points.isEmpty) {
      return _info('Aucune mesure sur cette période.');
    }

    // 5 repères de temps répartis du premier au dernier point
    final labels = <String>[];
    for (var i = 0; i < 5; i++) {
      final idx = ((points.length - 1) * i / 4).round();
      labels.add(_label(points[idx].time));
    }

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
              painter: _LineChartPainter(
                data: points.map(value).toList(),
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels
                .map((t) => Text(
                      t,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 10),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── Liste des capteurs ────────────────────────────────────────────────

  Widget _buildSensorList() {
    if (_sensors.isEmpty) {
      return _info('Aucun capteur enregistré pour le moment.');
    }
    return Column(
      children: _sensors
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
                      color: s.online
                          ? AppColors.success
                          : AppColors.textSecondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      s.name,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 13),
                    ),
                  ),
                  Text(
                    s.online ? 'En ligne' : 'Hors ligne',
                    style: TextStyle(
                      color: s.online
                          ? AppColors.success
                          : AppColors.textSecondary,
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

/// Dessine une courbe simple à partir d'une liste de valeurs.
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
        colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Un seul point : on le met au milieu (évite une division par zéro)
    final stepX = data.length > 1 ? size.width / (data.length - 1) : 0.0;
    final showDots = data.length <= 30;

    double xOf(int i) => data.length > 1 ? stepX * i : size.width / 2;
    double yOf(int i) {
      final normalized = (data[i] - minVal) / range;
      return size.height - (normalized * size.height * 0.85) - size.height * 0.1;
    }

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = xOf(i);
      final y = yOf(i);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
      if (showDots) canvas.drawCircle(Offset(x, y), 3, Paint()..color = color);
    }

    fillPath.lineTo(xOf(data.length - 1), size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.color != color;
  }
}