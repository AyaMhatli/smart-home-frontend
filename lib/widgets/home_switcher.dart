// lib/widgets/home_switcher.dart
//
// Bouton « nom de la maison ▾ » : ouvre la liste des maisons pour en choisir
// une ou en ajouter. Aussi : la carte « première maison » et
// la boîte de dialogue d'ajout.

import 'package:flutter/material.dart';
import '../services/home_service.dart';
import '../services/home_session.dart';
import '../themes/app_themes.dart';

class HomeSwitcher extends StatelessWidget {
  const HomeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: HomeSession.instance,
      builder: (context, _) {
        final s = HomeSession.instance;
        final label = s.current?.name ?? (s.loaded ? 'Ajouter une maison' : 'Chargement…');
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => showHomeSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.home_rounded, color: AppColors.primaryBlue, size: 18),
                const SizedBox(width: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Carte affichée quand l'utilisateur n'a encore aucune maison.
class NoHomeCard extends StatelessWidget {
  const NoHomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.home_work_rounded, color: AppColors.primaryBlue, size: 40),
          const SizedBox(height: 12),
          const Text(
            'Bienvenue !',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ajoutez votre première maison, puis vos appareils.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => showAddHomeDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Ajouter ma maison',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showHomeSheet(BuildContext context) {
  HomeSession.instance.reload(); // met à jour les nombres d'appareils
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: ListenableBuilder(
          listenable: HomeSession.instance,
          builder: (_, __) {
            final s = HomeSession.instance;
            return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'MES MAISONS',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                for (final h in s.homes) _homeTile(sheetContext, h, h.id == s.currentId),
                ListTile(
                  leading: const Icon(Icons.add_circle_outline_rounded,
                      color: AppColors.primaryBlue),
                  title: const Text('Ajouter une maison',
                      style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    showAddHomeDialog(context);
                  },
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

Widget _homeTile(BuildContext sheetContext, HomeInfo h, bool selected) {
  return ListTile(
    leading: Icon(
      selected ? Icons.check_circle_rounded : Icons.circle_outlined,
      color: selected ? AppColors.primaryBlue : AppColors.textSecondary,
    ),
    title: Text(h.name,
        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
    subtitle: Text(
      '${h.devicesCount} appareil${h.devicesCount > 1 ? 's' : ''}',
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
    ),
    onTap: () async {
      await HomeSession.instance.select(h.id);
      if (sheetContext.mounted) Navigator.pop(sheetContext);
    },
  );
}

Future<void> showAddHomeDialog(BuildContext context) {
  return showDialog<void>(context: context, builder: (_) => const _AddHomeDialog());
}

class _AddHomeDialog extends StatefulWidget {
  const _AddHomeDialog();

  @override
  State<_AddHomeDialog> createState() => _AddHomeDialogState();
}

class _AddHomeDialogState extends State<_AddHomeDialog> {
  final _ctrl = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Donnez un nom à la maison');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await HomeSession.instance.add(name);
      if (mounted) Navigator.pop(context);
    } on HomeServiceException catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Nouvelle maison',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 17)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _ctrl,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Ex : Maison, Appartement, Bureau',
              hintStyle: TextStyle(color: AppColors.textSecondary),
            ),
            onSubmitted: (_) => _save(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Ajouter'),
        ),
      ],
    );
  }
}
