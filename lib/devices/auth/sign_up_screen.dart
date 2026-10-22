
 import 'package:app_pfe/devices/auth/sign_in_screen.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
void main() {
  runApp(const SignUpScreen());
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}
 
class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<Animation<double>> _anims;
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _agree = false;
 
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _anims = List.generate(
      7,
      (i) => CurvedAnimation(
        parent: _ctrl,
        curve: Interval(i * 0.07, 0.55 + i * 0.06, curve: Curves.easeOut),
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
        Positioned(
          top: -80, left: -80,
          child: _GlowBlob(color: XColors.blue, size: 280, opacity: 0.10),
        ),
        Positioned(
          bottom: 80, right: -60,
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
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: XColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: XColors.border),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: XColors.textSec, size: 16),
                      ),
                    ),
                    // _MiLogo(color: XColors.blue),
                  ],
                )),
 
                const SizedBox(height: 44),
 
                // ── Title
                _fade(1, Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create', style: _h1),
                    const SizedBox(height: 4),
                    Row(children: [
                      Text('Account ', style: _h1),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: XColors.blueDim,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: XColors.blue.withOpacity(0.4)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.bolt_rounded,
                              color: XColors.blueLight, size: 14),
                          const SizedBox(width: 4),
                          Text('Free',
                            style: TextStyle(
                              color: XColors.blueLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            )),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Text(
                      'Join millions managing their smart home',
                      style: TextStyle(
                        color: XColors.textSec, fontSize: 15, height: 1.5),
                    ),
                  ],
                )),
 
                const SizedBox(height: 36),
 
                // ── Full name
                _fade(2, _Label('Full name')),
                const SizedBox(height: 8),
                _fade(2, _TextField(
                  hint: 'John Doe',
                  icon: Icons.person_outline_rounded,
                )),
 
                const SizedBox(height: 18),
 
                // ── Email
                _fade(3, _Label('Email address')),
                const SizedBox(height: 8),
                _fade(3, _TextField(
                  hint: 'you@example.com',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                )),
 
                const SizedBox(height: 18),
 
                // ── Password
                _fade(4, _Label('Password')),
                const SizedBox(height: 8),
                _fade(4, _TextField(
                  hint: 'Min. 8 characters',
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
 
                const SizedBox(height: 18),
 
                // ── Confirm password
                _fade(4, _Label('Confirm password')),
                const SizedBox(height: 8),
                _fade(4, _TextField(
                  hint: 'Re-enter password',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscureConfirm,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: XColors.textSec, size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                )),
 
                const SizedBox(height: 22),
 
                // ── Terms checkbox
                _fade(5, GestureDetector(
                  onTap: () => setState(() => _agree = !_agree),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          color: _agree ? XColors.blue : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _agree ? XColors.blue : XColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: _agree
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 14)
                          : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(text: TextSpan(children: [
                          TextSpan(
                            text: 'I agree to the ',
                            style: TextStyle(
                              color: XColors.textSec, fontSize: 13, height: 1.5),
                          ),
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              color: XColors.blueLight,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: ' and ',
                            style: TextStyle(
                              color: XColors.textSec, fontSize: 13),
                          ),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: XColors.blueLight,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ])),
                      ),
                    ],
                  ),
                )),
 
                const SizedBox(height: 32),
 
                // ── Create account button
                _fade(6, _PrimaryBtn(label: 'Create Account', onTap: () {})),
 
                const SizedBox(height: 28),
 
                _fade(6, _OrDivider()),
                const SizedBox(height: 28),
 
                _fade(6, Row(children: [
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
 
                const SizedBox(height: 32),
 
                _fade(6, Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: RichText(text: TextSpan(children: [
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(
                          color: XColors.textSec, fontSize: 14),
                      ),
                      TextSpan(
                        text: 'Sign In',
                        style: TextStyle(
                          color: XColors.blueLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ])),
                  ),
                )),
 
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
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
//       const Text('Xiaomi',
//         style: TextStyle(
//           color: XColors.textPri,
//           fontSize: 17,
//           fontWeight: FontWeight.w600,
//           letterSpacing: -0.2,
//         )),
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