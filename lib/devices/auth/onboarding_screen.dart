
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const onBoarding());
}

class onBoarding extends StatelessWidget {
  const onBoarding({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Smart Home',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        fontFamily: 'Roboto',
      ),
      home: const SmartHomeScreen(),
    );
  }
}

class SmartHomeScreen extends StatefulWidget {
  const SmartHomeScreen({super.key});

  @override
  State<SmartHomeScreen> createState() => _SmartHomeScreenState();
}

class _SmartHomeScreenState extends State<SmartHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Stack(
        children: [
          // Background gradient blobs
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:  const Color.fromARGB(255, 29, 94, 185).withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(255, 29, 94, 185).withOpacity(0.07),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                         
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 29, 94, 185),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Center(
                              child: Text(
                                'Mi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'MyHome',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _DotMenu(),
                          const SizedBox(width: 12),
                          ScaleTransition(
                            scale: _pulseAnim,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 29, 94, 185),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.circle,
                                color: Colors.white,
                                size: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 1),

                // Hero text
                FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Full Control',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 38,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                  letterSpacing: -1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'For Your ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 38,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                  letterSpacing: -1.2,
                                ),
                              ),
                              // Inline room image badge
                              Container(
                                width: 52,
                                height: 38,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color(0xFF1A2A1F),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF1DB97A,
                                    ).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.home_outlined,
                                  color: Color.fromARGB(255, 29, 94, 185),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Power toggle
                              Container(
                                width: 48,
                                height: 28,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: const Color.fromARGB(255, 29, 94, 185),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 24),
                                    Container(
                                      width: 22,
                                      height: 22,
                                      margin: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.power_settings_new,
                                        color: Color.fromARGB(255, 29, 94, 185),
                                        size: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Smart Home',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              letterSpacing: -1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Isometric room illustration
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Center(child: _IsometricRoom()),
                ),

                const Spacer(flex: 2),

                // Bottom navigation bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF161D22),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        // Back button
                        _NavCircleBtn(
                          icon: Icons.chevron_left_rounded,
                          color: const Color(0xFF252D33),
                          iconColor: Colors.white70,
                        ),
                        const SizedBox(width: 8),
                        // Lock icon
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color.fromARGB(255, 29, 94, 185).withOpacity(0.15),
                            border: Border.all(
                              color: const Color(
                                0xFF1DB97A,
                              ).withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.lock_outline_rounded,
                            color: Color.fromARGB(255, 29, 94, 185),
                            size: 18,
                          ),
                        ),
                        // Get Started label
                        Expanded(
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Get Started',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '>>>',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 29, 94, 185),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Forward button
                        _NavCircleBtn(
                          icon: Icons.chevron_right_rounded,
                          color: const Color.fromARGB(255, 29, 94, 185),
                          iconColor: Colors.white,
                          
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DotMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (i) => Container(
          width: 5,
          height: 5,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                i == 2
                    ? Colors.white
                    : Colors.white.withOpacity(0.35),
          ),
        ),
      ),
    );
  }
}

class _NavCircleBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;

  const _NavCircleBtn({
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }
}

/// Custom painter for isometric room illustration
class _IsometricRoom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 240,
      child: CustomPaint(painter: _RoomPainter()),
    );
  }
}

class _RoomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 10;

    // Floor
    final floorPath = Path();
    floorPath.moveTo(cx, cy + 80);
    floorPath.lineTo(cx + 130, cy + 20);
    floorPath.lineTo(cx, cy - 40);
    floorPath.lineTo(cx - 130, cy + 20);
    floorPath.close();
    canvas.drawPath(
      floorPath,
      Paint()..color = const Color(0xFF1A2520),
    );

    // Left wall
    final leftWall = Path();
    leftWall.moveTo(cx - 130, cy + 20);
    leftWall.lineTo(cx, cy - 40);
    leftWall.lineTo(cx, cy - 160);
    leftWall.lineTo(cx - 130, cy - 100);
    leftWall.close();
    canvas.drawPath(
      leftWall,
      Paint()..color = const Color(0xFF111A15),
    );

    // Right wall
    final rightWall = Path();
    rightWall.moveTo(cx, cy - 40);
    rightWall.lineTo(cx + 130, cy + 20);
    rightWall.lineTo(cx + 130, cy - 100);
    rightWall.lineTo(cx, cy - 160);
    rightWall.close();
    canvas.drawPath(
      rightWall,
      Paint()..color = const Color(0xFF0E1612),
    );

    // Ceiling strip light (green glow on left wall top)
    final lightPaint =
        Paint()
          ..color = const Color.fromARGB(255, 29, 94, 185).withOpacity(0.6)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(cx - 130, cy - 100),
      Offset(cx, cy - 160),
      lightPaint,
    );

    // Monitor desk area on left wall
    _drawDesk(canvas, cx - 80, cy - 20);

    // Bed on right side
    _drawBed(canvas, cx + 40, cy + 10);

    // Window on right wall
    _drawWindow(canvas, cx + 65, cy - 70);

    // Green screen glow effect
    final glowPaint =
        Paint()
          ..color = const Color.fromARGB(255, 29, 94, 185).withOpacity(0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(Offset(cx - 60, cy - 50), 45, glowPaint);
  }

  void _drawDesk(Canvas canvas, double x, double y) {
    final deskColor = const Color(0xFF0F1F18);
    final screenColor = const Color.fromARGB(255, 29, 94, 185);

    // Desk surface
    final desk = Path();
    desk.moveTo(x - 40, y);
    desk.lineTo(x + 10, y - 25);
    desk.lineTo(x + 10, y - 15);
    desk.lineTo(x - 40, y + 10);
    desk.close();
    canvas.drawPath(desk, Paint()..color = const Color(0xFF162212));

    // Monitor screen
    final screen = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x - 20, y - 30), width: 36, height: 24),
      const Radius.circular(2),
    );
    canvas.drawRRect(screen, Paint()..color = screenColor.withOpacity(0.8));

    // Screen glow line
    canvas.drawLine(
      Offset(x - 35, y - 30),
      Offset(x - 5, y - 30),
      Paint()
        ..color = screenColor.withOpacity(0.4)
        ..strokeWidth = 1,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Mi',
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 7,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - 25, y - 37));

    // Chair
    final chairPaint = Paint()..color = const Color(0xFF0D1A14);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x - 15, y + 15), width: 28, height: 14),
      chairPaint,
    );
  }

  void _drawBed(Canvas canvas, double x, double y) {
    // Bed base
    final bedPath = Path();
    bedPath.moveTo(x - 20, y + 30);
    bedPath.lineTo(x + 60, y - 10);
    bedPath.lineTo(x + 60, y + 10);
    bedPath.lineTo(x - 20, y + 50);
    bedPath.close();
    canvas.drawPath(bedPath, Paint()..color = const Color(0xFF0D1A14));

    // Pillow
    final pillow = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x + 40, y + 2), width: 28, height: 14),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      pillow,
      Paint()..color = const Color(0xFF1A2A1F),
    );

    // Blanket fold
    final blanket = Path();
    blanket.moveTo(x - 18, y + 32);
    blanket.lineTo(x + 30, y + 10);
    blanket.lineTo(x + 30, y + 22);
    blanket.lineTo(x - 18, y + 44);
    blanket.close();
    canvas.drawPath(
      blanket,
      Paint()..color = const Color(0xFF162918),
    );
  }

  void _drawWindow(Canvas canvas, double x, double y) {
    // Window frame
    final winPaint = Paint()..color = const Color(0xFF1A2A20);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(x, y), width: 36, height: 28),
      winPaint,
    );
    // Window cross bars
    final barPaint =
        Paint()
          ..color = const Color(0xFF0D1612)
          ..strokeWidth = 2;
    canvas.drawLine(Offset(x, y - 14), Offset(x, y + 14), barPaint);
    canvas.drawLine(Offset(x - 18, y), Offset(x + 18, y), barPaint);

    // Window glow
    final glowPaint = Paint()..color = const Color.fromARGB(255, 29, 94, 185).withOpacity(0.1);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(x - 9, y - 7), width: 16, height: 12),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(_RoomPainter oldDelegate) => false;
}