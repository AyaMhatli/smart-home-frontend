import 'package:flutter/material.dart';
import 'package:app_pfe/devices/auth/sign_up_screen.dart';
void main() {
  runApp(const AuthApp());
}

class AuthApp extends StatelessWidget {
  const AuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E1A),
        fontFamily: 'Roboto',
      ),
      home: const SignInScreen(),
    );
  }
}

// ─────────────────────────────────────────────
//  COLORS
// ─────────────────────────────────────────────
class XColors {
  static const bg       = Color(0xFF0A0E1A);
  static const surface  = Color(0xFF111827);
  static const card     = Color(0xFF141C2E);
  static const blue     = Color(0xFF2D7EF8);
  static const blueLight= Color(0xFF5B9BFF);
  static const blueDim  = Color(0xFF1A3A6B);
  static const border   = Color(0xFF1E2D4A);
  static const textPri  = Colors.white;
  static const textSec  = Color(0xFF8A9BBE);
  static const textHint = Color(0xFF3D5070);
}

// ─────────────────────────────────────────────
//  SIGN IN SCREEN
// ─────────────────────────────────────────────
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<Animation<double>> _anims;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _anims = List.generate(
      6,
      (i) => CurvedAnimation(
        parent: _ctrl,
        curve: Interval(i * 0.08, 0.6 + i * 0.06, curve: Curves.easeOut),
      ),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _fade(int i, Widget child) => FadeTransition(
        opacity: _anims[i],
        child: SlideTransition(
          position: Tween<Offset>(
                  begin: const Offset(0, 0.06), end: Offset.zero)
              .animate(_anims[i]),
          child: child,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: XColors.bg,
      body: Stack(children: [
        // Blob top-right
        Positioned(
          top: -100, right: -80,
          child: _GlowBlob(color: XColors.blue, size: 300, opacity: 0.10),
        ),
        // Blob bottom-left
        Positioned(
          bottom: 60, left: -60,
          child: _GlowBlob(color: XColors.blueLight, size: 200, opacity: 0.07),
        ),

        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // ── Top bar
                _fade(0, Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // _MiLogo(color: XColors.blue),
                    _OutlineBtn(
                      label: 'Sign Up',
                      onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen())),
                    ),
                  ],
                )),

                const SizedBox(height: 48),

                // ── Title
                _fade(1, Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome', style: _h1),
                    const SizedBox(height: 4),
                    RichText(text: TextSpan(children: [
                      TextSpan(text: 'Back ', style: _h1),
                      TextSpan(
                        text: '👋',
                        style: _h1.copyWith(fontSize: 30),
                      ),
                    ])),
                    const SizedBox(height: 10),
                    Text(
                      'Sign in to control your smart home',
                      style: TextStyle(
                        color: XColors.textSec, fontSize: 15, height: 1.5),
                    ),
                  ],
                )),

                const SizedBox(height: 40),

                // ── Email field
                _fade(2, _Label('Email address')),
                const SizedBox(height: 8),
                _fade(2, _TextField(
                  hint: 'you@example.com',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                )),

                const SizedBox(height: 20),

                // ── Password field
                _fade(3, _Label('Password')),
                const SizedBox(height: 8),
                _fade(3, _TextField(
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscure,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: XColors.textSec, size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                )),

                const SizedBox(height: 12),

                // ── Forgot password
                _fade(3, Align(
                  alignment: Alignment.centerRight,
                  child: Text('Forgot password?',
                    style: TextStyle(
                      color: XColors.blueLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    )),
                )),

                const SizedBox(height: 36),

                // ── Sign In button
                _fade(4, _PrimaryBtn(label: 'Sign In', onTap: () {})),

                const SizedBox(height: 28),

                // ── Divider
                _fade(4, _OrDivider()),

                const SizedBox(height: 28),

                // ── Social buttons
                _fade(5, Row(children: [
                  Expanded(child: _SocialBtn(
                    label: 'Google',
                    icon: Icons.g_mobiledata_rounded,
                    onTap: () {},
                  )),
                  const SizedBox(width: 14),
                  Expanded(child: _SocialBtn(
                    label: 'Apple',
                    icon: Icons.apple_rounded,
                    onTap: () {},
                  )),
                ])),

                const SizedBox(height: 36),

                // ── Sign up link
                _fade(5, Center(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen())),
                    child: RichText(text: TextSpan(children: [
                      TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: XColors.textSec, fontSize: 14),
                      ),
                      TextSpan(
                        text: 'Sign Up',
                        style: TextStyle(
                          color: XColors.blueLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ])),
                  ),
                )),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}


// ─────────────────────────────────────────────
//  SHARED WIDGETS
// ─────────────────────────────────────────────

final _h1 = const TextStyle(
  color: XColors.textPri,
  fontSize: 36,
  fontWeight: FontWeight.w800,
  height: 1.1,
  letterSpacing: -1.0,
);

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;
  const _GlowBlob(
      {required this.color, required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
      ),
    );
  }
}

// class _MiLogo extends StatelessWidget {
//   final Color color;
//   const _MiLogo({required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return Row(children: [
//       Container(
//         width: 30, height: 30,
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: const Center(
//           child: Text('Mi',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 11,
//               fontWeight: FontWeight.w800,
//               letterSpacing: -0.3,
//             )),
//         ),
//       ),
//       const SizedBox(width: 8),
//       // const Text('',
//       //   style: TextStyle(
//       //     color: XColors.textPri,
//       //     fontSize: 17,
//       //     fontWeight: FontWeight.w600,
//       //     letterSpacing: -0.2,
//       //   )),
//     ]);
//   }
// }

class _OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: XColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: XColors.border),
        ),
        child: Text(label,
          style: const TextStyle(
            color: XColors.textPri,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          )),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
      style: const TextStyle(
        color: XColors.textSec,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ));
  }
}

class _TextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboardType;
  final Widget? suffixIcon;

  const _TextField({
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: XColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: XColors.border),
      ),
      child: TextFormField(
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(color: XColors.textPri, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: XColors.textHint, fontSize: 15),
          prefixIcon: Icon(icon, color: XColors.textSec, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: XColors.blue,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: XColors.blue.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              )),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Container(height: 1, color: XColors.border)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('or continue with',
          style: const TextStyle(
            color: XColors.textSec, fontSize: 13)),
      ),
      Expanded(child: Container(height: 1, color: XColors.border)),
    ]);
  }
}

class _SocialBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _SocialBtn(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: XColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: XColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: XColors.textSec, size: 22),
            const SizedBox(width: 8),
            Text(label,
              style: const TextStyle(
                color: XColors.textPri,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              )),
          ],
        ),
      ),
    );
  }
}