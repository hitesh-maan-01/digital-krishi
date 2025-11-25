// lib/controllers/chatbot_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../chatbot/chatbot_service.dart';
import '../chatbot/message_model.dart';
import '../chatbot/speech_service.dart'; // Assuming speech_service is available

class ChatbotController extends ChangeNotifier {
  final ChatbotService _service = ChatbotService();
  final SpeechService _speechService = SpeechService();
  static const String _historyKey = 'chat_history_krishi';

  List<Message> messages = [];
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ChatbotController() {
    _loadHistory();
  }

  // --- History Management (Simplified from previous example) ---
  Future<void> _loadHistory() async {
    // Implementation here to load messages and restore chat history
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? historyJson = prefs.getString(_historyKey);

    if (historyJson != null) {
      final List<dynamic> decodedList = jsonDecode(historyJson);
      messages = decodedList.map((item) => Message.fromJson(item)).toList();

      List<Content> geminiHistory = messages
          .where((msg) => msg.content != null)
          .map((msg) => msg.content!)
          .toList();

      _service.restoreChat(geminiHistory);
      notifyListeners();
    }
  }

  Future<void> _saveHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final historyToSave = messages
        .where((msg) => !msg.isTyping)
        .map((msg) => msg.toJson())
        .toList();

    String historyJson = jsonEncode(historyToSave);
    await prefs.setString(_historyKey, historyJson);
  }

  // --- Message Sending Logic ---
  Future<void> sendMessage({required String prompt, String? imagePath}) async {
    if (prompt.trim().isEmpty && imagePath == null) return;
    _setLoading(true);

    // 1. Add User Message
    messages.add(Message(text: prompt, isUser: true, imagePath: imagePath));

    // 2. Add AI Typing Indicator
    messages.add(Message(text: '...', isUser: false, isTyping: true));
    notifyListeners();

    // 3. Stream Response
    StringBuffer fullResponse = StringBuffer();
    String? error;

    try {
      await for (final chunk in _service.sendMessageStream(
        prompt: prompt,
        imagePath: imagePath,
      )) {
        if (chunk.startsWith('Error')) {
          error = chunk;
          break;
        }
        fullResponse.write(chunk);

        // Update the UI with streamed text (stream implementation)
        messages.last = Message(
          text: fullResponse.toString(),
          isUser: false,
          isTyping: true,
        );
        notifyListeners();
      }
    } catch (e) {
      error = "Failed to communicate with the AI model: $e";
    }

    // 4. Finalize Response
    messages.removeLast(); // Remove the streaming/typing message

    if (error != null) {
      messages.add(Message(text: error, isUser: false, isError: true));
    } else {
      List<Content> history = _service.getHistory();
      Content? botContent = history.isNotEmpty ? history.last : null;

      messages.add(
        Message(
          text: fullResponse.toString().trim(),
          isUser: false,
          content: botContent, // Store the API's Content object
        ),
      );
    }

    _setLoading(false);
    _saveHistory();
  }

  // Placeholder for language in old design
  String getCurrentLanguage() => 'en-US';

  // UI Interactions (Like/Dislike, Clear)
  void setLikeDislike(int index, bool? isLiked) {
    /* ... */
  }
  Future<void> clearHistory() async {
    /* ... */
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
