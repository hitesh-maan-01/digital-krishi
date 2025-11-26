// lib/services/speech_service.dart
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  Future<bool> initSTT() async {
    try {
      return await _speech.initialize();
    } catch (e) {
      return false;
    }
  }

  /// start listening; call onResult with transcribed text
  void listen(Function(String) onResult) async {
    final available = await _speech.initialize();
    if (!available) return;
    _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords ?? "");
      },
    );
  }

  /// Stop listening
  void stopListening() async {
    try {
      await _speech.stop();
    } catch (_) {}
  }

  /// Speak text. langCode example: "en-IN" or "hi-IN" or "ml-IN"
  Future<void> speak(String text, {String langCode = "en-IN"}) async {
    try {
      await _tts.setLanguage(langCode);
      await _tts.speak(text);
    } catch (_) {}
  }

  /// Stop speaking
  Future<void> stopSpeak() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
