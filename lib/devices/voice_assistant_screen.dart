import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../themes/app_themes.dart';

/// Écran assistant vocal — capture la voix, l'envoie à l'API Django
/// qui interprète la commande et déclenche l'action via MQTT.
///
/// Ajoute dans ton pubspec.yaml :
///   dependencies:
///     speech_to_text: ^7.0.0
///     http: ^1.2.0
///
/// N'oublie pas les permissions micro :
/// Android (android/app/src/main/AndroidManifest.xml) :
///   <uses-permission android:name="android.permission.RECORD_AUDIO"/>
/// iOS (ios/Runner/Info.plist) :
///   <key>NSMicrophoneUsageDescription</key>
///   <string>Utilisé pour les commandes vocales</string>
class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isProcessing = false;
  String _recognizedText = '';
  String _responseMessage = '';
  bool _speechAvailable = false;

  late AnimationController _pulseController;

  // Adresse de ton API Django sur la Pi — adapte l'IP si besoin
  static const String _apiBaseUrl = 'http://192.168.137.35:8000';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _initSpeech();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
      },
    );
    setState(() {});
  }

  void _startListening() async {
    if (!_speechAvailable) return;

    setState(() {
      _isListening = true;
      _recognizedText = '';
      _responseMessage = '';
    });

    await _speech.listen(
      localeId: 'fr_FR', // reconnaissance en français
      onResult: (result) {
        setState(() => _recognizedText = result.recognizedWords);
        if (result.finalResult) {
          _sendCommand(result.recognizedWords);
        }
      },
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _sendCommand(String text) async {
    if (text.trim().isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/assistant/command/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _responseMessage = data['message'] ?? 'Commande exécutée');
      } else {
        setState(() => _responseMessage = 'Commande non reconnue');
      }
    } catch (e) {
      setState(() => _responseMessage = 'Erreur de connexion au serveur');
    }

    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              'Assistant Vocal',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _speechAvailable
                  ? 'Appuyez et parlez'
                  : 'Microphone indisponible',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const Spacer(),

            // Texte reconnu
            if (_recognizedText.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '"$_recognizedText"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            // Réponse du serveur
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              )
            else if (_responseMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.smart_toy_rounded,
                        color: AppColors.primaryBlue, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _responseMessage,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Bouton micro
            GestureDetector(
              onTap: _speechAvailable
                  ? (_isListening ? _stopListening : _startListening)
                  : null,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = _isListening
                      ? 1.0 + (_pulseController.value * 0.15)
                      : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening
                            ? AppColors.primaryBlue
                            : AppColors.surface,
                        boxShadow: _isListening
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryBlue.withOpacity(0.4),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                ),
                              ]
                            : [],
                      ),
                      child: Icon(
                        _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                        color: _isListening ? Colors.white : AppColors.textSecondary,
                        size: 36,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 60),

            // Exemples de commandes
            const Text(
              'Exemples : "allume le salon", "verrouille la porte"',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
