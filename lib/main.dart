import 'package:flutter/material.dart';
import 'devices/main_navigation.dart';
import 'devices/auth/sign_in_screen.dart';
import 'services/auth_service.dart';
import 'themes/app_themes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Home',
      theme: AppTheme.dark,
      home: const AuthGate(),
    );
  }
}

/// Au démarrage : si l'utilisateur est déjà connecté, on va directement
/// à l'application, sinon on affiche l'écran de connexion.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.instance.isLoggedIn(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
          );
        }
        return snapshot.data! ? const MainNavigation() : const SignInScreen();
      },
    );
  }
}
