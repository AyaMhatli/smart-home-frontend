

// import 'package:flutter/material.dart';
// import 'package:app_pfe/themes/app_themes.dart';

// /// Modèle pour un item de navigation (icône + label).
// class NavItem {
//   final IconData icon;
//   final String label;
//   const NavItem({required this.icon, required this.label});
// }

// /// Barre de navigation mobile réutilisable, style "pilule flottante".
// /// Peut être utilisée dans n'importe quel écran qui a besoin
// /// d'une navigation par onglets (pas seulement MainNavigation).
// ///
// /// Exemple d'utilisation :
// /// ```dart
// /// BottomNavBar(
// ///   items: const [
// ///     NavItem(icon: Icons.home_rounded, label: 'Accueil'),
// ///     NavItem(icon: Icons.tune_rounded, label: 'Contrôle'),
// ///   ],
// ///   currentIndex: _currentIndex,
// ///   onTap: (index) => setState(() => _currentIndex = index),
// /// )
// /// ```
// class BottomNavBar extends StatelessWidget {
//   final List<NavItem> items;
//   final int currentIndex;
//   final ValueChanged<int> onTap;

//   const BottomNavBar({
//     super.key,
//     required this.items,
//     required this.currentIndex,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: List.generate(items.length, (index) {
//           final isSelected = currentIndex == index;
//           final item = items[index];

//           return GestureDetector(
//             behavior: HitTestBehavior.opaque,
//             onTap: () => onTap(index),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               padding: EdgeInsets.symmetric(
//                 horizontal: isSelected ? 16 : 12,
//                 vertical: 10,
//               ),
//               decoration: BoxDecoration(
//                 color: isSelected
//                     ? AppColors.primaryBlue.withOpacity(0.15)
//                     : Colors.transparent,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     item.icon,
//                     size: 22,
//                     color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
//                   ),
//                   if (isSelected) ...[
//                     const SizedBox(width: 8),
//                     Text(
//                       item.label,
//                       style: const TextStyle(
//                         color: AppColors.primaryBlue,
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../themes/app_themes.dart';

/// Modèle pour un item de navigation (icône + label).
class NavItem {
  final IconData icon;
  final String label;
  const NavItem({required this.icon, required this.label});
}

/// Barre de navigation mobile réutilisable, style "pilule flottante".
/// Peut être utilisée dans n'importe quel écran qui a besoin
/// d'une navigation par onglets (pas seulement MainNavigation).
///
/// Exemple d'utilisation :
/// ```dart
/// BottomNavBar(
///   items: const [
///     NavItem(icon: Icons.home_rounded, label: 'Accueil'),
///     NavItem(icon: Icons.tune_rounded, label: 'Contrôle'),
///   ],
///   currentIndex: _currentIndex,
///   onTap: (index) => setState(() => _currentIndex = index),
/// )
/// ```
class BottomNavBar extends StatelessWidget {
  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = currentIndex == index;
          final item = items[index];

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 16 : 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryBlue.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: 22,
                    color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    Text(
                      item.label,
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
