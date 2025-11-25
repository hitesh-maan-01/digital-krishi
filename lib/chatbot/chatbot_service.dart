// lib/services/chatbot_service.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';

// NOTE: Replace 'YOUR_API_KEY' with your actual key
const String _apiKey = String.fromEnvironment(
  "AIzaSyCRi8lMd2DNpSqXshst0svJWvKS6sjEuh0",
  defaultValue: "YOUR_API_KEY",
);

class ChatbotService {
  late GenerativeModel _model;
 
  late ChatSession _chat;

  static const String _systemInstruction =
      "You are 'Digital Krishi', an expert agriculture and farming assistant chatbot. "
      "Your sole purpose is to provide highly detailed, accurate, and helpful information "
      "only related to agriculture, crop science, soil health, farming techniques, "
      "pest control, and livestock management. You must politely refuse to answer "
      "questions on any other topic. Always format your responses using markdown.";

  ChatbotService() {
    if (_apiKey.isEmpty || _apiKey == "YOUR_API_KEY") {
      throw Exception("Gemini API Key not set. Please set the GEMINI_API_KEY.");
    }
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      // FIX 2 & 3: Renamed config to generationConfig and GenerateContentConfig to GenerationConfig
      generationConfig: GenerationConfig(systemInstruction: _systemInstruction),
    );
    _chat = _model.startChat();
  }

  void restoreChat(List<Content> history) {
    _chat = _model.startChat(history: history);
  }

  Stream<String> sendMessageStream({
    required String prompt,
    String? imagePath,
  }) async* {
    List<Part> parts = [TextPart(prompt)];

    if (imagePath != null) {
      try {
        final File imageFile = File(imagePath);
        final Uint8List imageBytes = await imageFile.readAsBytes();
        parts.insert(0, DataPart('image/jpeg', imageBytes));
      } catch (e) {
        yield 'Error processing image: $e';
        return;
      }
    }

    try {
      final responseStream = _chat.sendMessageStream(Content.parts(parts));

      await for (final chunk in responseStream) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } on Exception catch (e) {
      yield "An API error occurred. Error: $e";
      return;
    }
  }

  // FIX 5: getHistory is a method on ChatSession
  List<Content> getHistory() {
    return _chat.getHistory().toList();
  }
}
