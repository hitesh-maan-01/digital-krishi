// lib/chatbot/agri_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

class AgriService {
  static const String GEMINI_API_KEY =
      "AIzaSyAtFGlspzFRli60c-ESXX-jS8fBgyGPu38"; // replace with your key

  /// ------------------------------------
  /// SEND MAIN AGRI QUERY + IMAGE + CONTEXT
  /// ------------------------------------
  Future<String> sendMessage(
    String query, {
    File? imageFile,
    List<Map<String, dynamic>>? lastMessages,
  }) async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$GEMINI_API_KEY",
    );

    // Prepare context (last 3 messages)
    String context = "";
    if (lastMessages != null && lastMessages.isNotEmpty) {
      final ctxList = lastMessages.take(3).toList();
      context = ctxList
          .map(
            (m) =>
                "${m["from"] == "user" ? "Farmer" : "Assistant"}: ${m["msg"]}",
          )
          .join("\n");
    }

    // Encode image safely
    String imagePart = "";
    if (imageFile != null) {
      try {
        final bytes = await imageFile.readAsBytes();
        final b64 = base64Encode(bytes);
        imagePart = "\n\n[ImageBase64Prefix]: ${b64.substring(0, 800)} ...";
      } catch (_) {
        imagePart = "\n\n[Image attached but couldn't be read]";
      }
    }

    final prompt =
        """
You are a trusted Agricultural Assistant for farmers in Kerala.

Instructions:
1. Use ONLY ICAR, KAU, IMD, govt bulletins & verified agri data.
2. Answer short (2–4 lines) in simple farmer language.
3. Add source at end.
4. If image attached → analyze and diagnose.
5. If unsure → say "Please contact Krishi Officer."
6. Use helpful emojis.
7. Use previous chat context for better relevance.

Conversation Context:
$context

Farmer Query:
$query
$imagePart
""";

    final body = {
      "model": "gemini-2.5-flash",
      "contents": [
        {
          "parts": [
            {"text": prompt},
          ],
        },
      ],
    };

    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 45));

      final json = jsonDecode(response.body);

      return json["candidates"][0]["content"]["parts"][0]["text"];
    } catch (e) {
      return "⚠️ ERROR: $e";
    }
  }

  /// ------------------------------------
  /// TRANSLATION FEATURE
  /// ------------------------------------
  Future<String> translateText(String original, String target) async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$GEMINI_API_KEY",
    );

    final prompt =
        """
Translate the following agricultural chatbot answer into **$target**.
Keep tone simple & helpful for farmers.
Do NOT change meaning.
Text:
$original
""";

    final body = {
      "model": "gemini-2.5-flash",
      "contents": [
        {
          "parts": [
            {"text": prompt},
          ],
        },
      ],
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    final jsonBody = jsonDecode(response.body);
    return jsonBody["candidates"][0]["content"]["parts"][0]["text"];
  }
}
