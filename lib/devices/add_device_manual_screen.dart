import 'package:flutter/material.dart';
import '../services/device_service.dart';
import '../themes/app_themes.dart';

/// Écran « Ajouter manuellement » : deux cas.
///  - Appareil ESP32 (MQTT) : nom + catégorie
///  - Appareil Wi-Fi du commerce : adresse IP, le serveur reconnaît la marque
///    (télé Samsung, Roku, WLED, Shelly, Tasmota, WiZ...)
/// Données : services/device_service.dart
class AddDeviceManualScreen extends StatefulWidget {
  const AddDeviceManualScreen({super.key});

  @override
  State<AddDeviceManualScreen> createState() => _AddDeviceManualScreenState();
}

class _AddDeviceManualScreenState extends State<AddDeviceManualScreen> {
  // 'mqtt' (ESP32) ou 'ip' (appareil Wi-Fi reconnu par son adresse)
  String _kind = 'mqtt';
  String _foundKind = ''; // famille reconnue par le serveur ('shelly', 'roku'...)
  String _mqttType = 'light';
  final _nameCtrl = TextEditingController();
  final _hostCtrl = TextEditingController();

  bool _probing = false;
  bool _saving = false;
  String? _message;
  bool _messageIsError = false;
  bool _recognized = false;

  static const _mqttTypes = <String, String>{
    'light': 'Lumière',
    'fan': 'Ventilateur',
    'door': 'Porte',
    'servo': 'Servo',
    'sensor': 'Capteur',
  };

  @override
  void dispose() {
    _nameCtrl.dispose();
    _hostCtrl.dispose();
    super.dispose();
  }

  bool get _isMqtt => _kind == 'mqtt';

  void _setMessage(String? text, {bool error = false}) {
    setState(() {
      _message = text;
      _messageIsError = error;
    });
  }

  void _pickKind(String kind) {
    setState(() {
      _kind = kind;
      _message = null;
      _recognized = false;
      _foundKind = '';
    });
  }

  Future<void> _probe() async {
    final host = _hostCtrl.text.trim();
    if (host.isEmpty) {
      _setMessage("Entrez l'adresse IP de l'appareil", error: true);
      return;
    }
    setState(() => _probing = true);
    try {
      final r = await DeviceService.instance.probe(host);
      if (!mounted) return;
      if (r.found) {
        if (_nameCtrl.text.trim().isEmpty && r.name.isNotEmpty) {
          _nameCtrl.text = r.name;
        }
        _recognized = true;
        _foundKind = r.kind;
        _setMessage('Reconnu : ${DeviceService.kindLabel(r.kind)}', error: false);
      } else {
        _recognized = false;
        _foundKind = '';
        _setMessage(
            "Aucun appareil reconnu à cette adresse. Vérifiez l'IP et que l'appareil est allumé.",
            error: true);
      }
    } on DeviceServiceException catch (e) {
      _recognized = false;
      _foundKind = '';
      _setMessage(e.message, error: true);
    }
    if (mounted) setState(() => _probing = false);
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final host = _hostCtrl.text.trim();
    if (name.isEmpty) {
      _setMessage("Donnez un nom à l'appareil (ou appuyez sur Reconnaître)", error: true);
      return;
    }
    if (!_isMqtt && host.isEmpty) {
      _setMessage("Entrez l'adresse IP de l'appareil", error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      var kind = _foundKind;
      if (!_isMqtt && kind.isEmpty) {
        // Pas encore reconnu : on demande au serveur avant d'enregistrer
        final r = await DeviceService.instance.probe(host);
        if (!r.found) {
          _setMessage(
              "Aucun appareil reconnu à cette adresse. Vérifiez l'IP et que l'appareil est allumé.",
              error: true);
          if (mounted) setState(() => _saving = false);
          return;
        }
        kind = r.kind;
      }
      await DeviceService.instance.addManual(
        name: name,
        type: _isMqtt ? _mqttType : DeviceService.typeForKind(kind),
        integration: _isMqtt ? '' : kind,
        host: _isMqtt ? '' : host,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
      return;
    } on DeviceServiceException catch (e) {
      _setMessage(e.message, error: true);
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Ajouter manuellement',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            _label('Type d\'appareil'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _kindChip('mqtt', 'Appareil ESP32'),
                _kindChip('ip', 'Appareil Wi-Fi (par IP)'),
              ],
            ),
            const SizedBox(height: 20),
            if (_isMqtt) ...[
              _label('Catégorie'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final e in _mqttTypes.entries) _typeChip(e.key, e.value),
                ],
              ),
              const SizedBox(height: 20),
            ] else ...[
              _label("Adresse IP de l'appareil"),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      _hostCtrl,
                      '192.168.1.45',
                      keyboard: TextInputType.number,
                      onChanged: (_) {
                        if (_recognized) {
                          setState(() {
                            _recognized = false;
                            _foundKind = '';
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _probing ? null : _probe,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryBlue),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _probing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Reconnaître',
                              style: TextStyle(color: AppColors.primaryBlue)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                "Télé Samsung ou Roku, bande WLED, prise Shelly ou Tasmota, ampoule WiZ. "
                "Le serveur et l'appareil doivent être sur le même Wi-Fi.",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 20),
            ],
            _label("Nom de l'appareil"),
            _field(_nameCtrl, _isMqtt ? 'Lampe du salon' : 'Nom (rempli après reconnaissance)'),
            if (_message != null) ...[
              const SizedBox(height: 14),
              Text(
                _message!,
                style: TextStyle(
                  color: _messageIsError ? AppColors.danger : AppColors.success,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Ajouter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String hint, {
    TextInputType? keyboard,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _kindChip(String kind, String label) =>
      _chip(label, _kind == kind, () => _pickKind(kind));

  Widget _typeChip(String type, String label) =>
      _chip(label, _mqttType == type, () => setState(() => _mqttType = type));

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primaryBlue,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textPrimary,
        fontSize: 13,
      ),
      side: BorderSide.none,
    );
  }
}
