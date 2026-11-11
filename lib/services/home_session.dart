// lib/services/home_session.dart
//
// La maison actuellement choisie par l'utilisateur.
// Tous les services (appareils, résumé, historique) s'en servent pour
// ne demander au serveur que les données de CETTE maison.
//
//   await HomeSession.instance.ensureLoaded();   // charge la liste (une seule fois)
//   HomeSession.instance.currentId               // maison choisie (null s'il n'y en a pas)
//   HomeSession.instance.changes                 // s'incrémente quand on change de maison

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'home_service.dart';

class HomeSession extends ChangeNotifier {
  HomeSession._();
  static final HomeSession instance = HomeSession._();

  static const _key = 'current_home_id';
  final _storage = const FlutterSecureStorage();

  List<HomeInfo> homes = [];
  int? currentId;
  bool loaded = false;

  /// Les écrans l'écoutent pour se recharger quand la maison change.
  final ValueNotifier<int> changes = ValueNotifier(0);

  Future<void>? _loading;

  HomeInfo? get current {
    for (final h in homes) {
      if (h.id == currentId) return h;
    }
    return null;
  }

  /// Charge la liste des maisons la première fois (les appels suivants attendent le même chargement).
  Future<void> ensureLoaded() => _loading ??= _load();

  /// Recharge la liste (par exemple pour mettre à jour le nombre d'appareils).
  Future<void> reload() {
    _loading = null;
    return ensureLoaded();
  }

  Future<void> _load() async {
    try {
      homes = await HomeService.instance.fetchHomes();
      int? saved = currentId;
      if (saved == null) {
        try {
          saved = int.tryParse(await _storage.read(key: _key) ?? '');
        } catch (_) {}
      }
      currentId = homes.any((h) => h.id == saved)
          ? saved
          : (homes.isNotEmpty ? homes.first.id : null);
      loaded = true;
    } on HomeServiceException {
      _loading = null; // on réessaiera au prochain appel
    }
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      if (currentId == null) {
        await _storage.delete(key: _key);
      } else {
        await _storage.write(key: _key, value: '$currentId');
      }
    } catch (_) {}
  }

  Future<void> select(int id) async {
    if (id == currentId) return;
    currentId = id;
    await _save();
    changes.value++;
    notifyListeners();
  }

  /// Crée une maison et la sélectionne.
  Future<void> add(String name) async {
    final home = await HomeService.instance.createHome(name);
    homes = [...homes, home];
    loaded = true;
    currentId = home.id;
    await _save();
    changes.value++;
    notifyListeners();
  }

  /// À appeler à la déconnexion.
  Future<void> reset() async {
    homes = [];
    currentId = null;
    loaded = false;
    _loading = null;
    await _save();
    changes.value++;
    notifyListeners();
  }
}
