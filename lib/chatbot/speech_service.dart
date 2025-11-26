import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  Future<bool> initSTT() async => await _speech.initialize();

  void listen(Function(String) onResult) async {
    await _speech.listen(
      onResult: (result) => onResult(result.recognizedWords),
    );
  }

  void stopListening() async => await _speech.stop();

  Future<void> speak(String text, String langCode) async {
    await _tts.setLanguage(langCode);
    await _tts.speak(text);
  }
}
