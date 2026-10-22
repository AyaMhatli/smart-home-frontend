import 'package:flutter/material.dart';

/// Palette de couleurs centralisée du projet Smart Home.
/// Équivalent d'un fichier `global.scss` / `variables.css` en Next.js :
/// toutes les couleurs de l'app sont déclarées ici une seule fois.
class AppColors {
  AppColors._(); // empêche l'instanciation, comme un namespace

  static const Color primaryBlue = Color(0xFF2D7EF8);
  static const Color background = Color(0xFF0F1115);
  static const Color surface = Color(0xFF1B1E24);
  static const Color surfaceLight = Color(0xFF252932);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9096A2);

  // Couleurs d'état, utiles pour les cartes de device (porte, alertes, etc.)
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color danger = Color(0xFFE53935);
}

/// Tu peux aussi centraliser d'autres "design tokens" ici,
/// comme les rayons de bordure ou les espacements —
/// exactement comme tu ferais avec des variables SCSS/CSS.
class AppRadius {
  AppRadius._();

  static const double sm = 12;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 20;
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// Optionnel : un ThemeData global que tu peux passer directement
/// à ton MaterialApp (theme: AppTheme.dark) pour que Flutter applique
/// certains styles par défaut automatiquement (boutons, inputs, etc.)
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryBlue,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryBlue,
        surface: AppColors.surface,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primaryBlue
              : AppColors.textSecondary,
        ),
      ),
      fontFamily: 'Inter', // ou la police que tu utilises déjà
    );
  }
}