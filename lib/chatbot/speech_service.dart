// lib/services/speech_service.dart
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  bool get isListening => _speechToText.isListening;
  bool get isInitialized => _isInitialized;

  Future<bool> initSTT() async {
    if (_isInitialized) return true;

    // Check for availability and request permission
    bool available = await _speechToText.initialize(
      onError: (val) => print('STT Error: ${val.errorMsg}'),
      onStatus: (val) => print('STT Status: $val'),
    );
    _isInitialized = available;
    return available;
  }

  void listen(Function(String text) onResult) {
    if (!_isInitialized || isListening) return;

    _speechToText.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
      localeId: 'en_IN', // Example locale
    );
  }

  void stopListening() {
    if (isListening) {
      _speechToText.stop();
    }
  }

  void dispose() {
    _speechToText.stop();
  }
}
