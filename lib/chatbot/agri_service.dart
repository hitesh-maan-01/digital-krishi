// lib/chatbot/agri_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

class AgriService {
  static const String GEMINI_API_KEY =
      "AIzaSyB5apfolj6OEuYnpXWLjkuq76ZBXwxg3AI"; // replace with your key

  /// Helper: robust extractor for common Gemini response shapes.
  String _extractTextFromResponse(Map<String, dynamic> jsonBody) {
    try {
      // shape: { candidates: [ { content: { parts: [ "text" or { "text": ... } ] } } ] }
      final candidates = jsonBody['candidates'];
      if (candidates is List && candidates.isNotEmpty) {
        final first = candidates[0];
        if (first is Map) {
          final content = first['content'];
          if (content is Map) {
            final parts = content['parts'];
            if (parts is List && parts.isNotEmpty) {
              final part = parts[0];
              if (part is String) return part;
              if (part is Map && part.containsKey('text'))
                return part['text'].toString();
              // try other keys
              if (part is Map && part.containsKey('content'))
                return part['content'].toString();
            }
            // sometimes content -> text directly
            if (content is Map && content.containsKey('text'))
              return content['text'].toString();
          }
        }
      }

      // Another common shape: { output: [ { content: "..." } ] }
      if (jsonBody['output'] is List && jsonBody['output'].isNotEmpty) {
        final out0 = jsonBody['output'][0];
        if (out0 is Map && out0['content'] != null)
          return out0['content'].toString();
      }

      // Last resort: if top-level 'text' exists
      if (jsonBody['text'] != null) return jsonBody['text'].toString();

      // fallback: empty but valid
      return "";
    } catch (_) {
      return "";
    }
  }

  /// Main send function (text + optional image + context)
  Future<String> sendMessage(
    String query, {
    File? imageFile,
    List<Map<String, dynamic>>? lastMessages,
  }) async {
    final endpoint =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$GEMINI_API_KEY";

    // Build small context
    String context = "";
    if (lastMessages != null && lastMessages.isNotEmpty) {
      try {
        final take = lastMessages.take(3).toList();
        context = take
            .map(
              (m) =>
                  "${m['from'] == 'user' ? 'Farmer' : 'Assistant'}: ${m['msg']}",
            )
            .join("\n");
      } catch (_) {
        context = "";
      }
    }

    // Image prefix (trim)
    String imagePart = "";
    if (imageFile != null) {
      try {
        final bytes = await imageFile.readAsBytes();
        final b64 = base64Encode(bytes);
        imagePart =
            "\n\n[ImageBase64Prefix]: ${b64.substring(0, b64.length > 800 ? 0 : 0)}"; // keep empty if too large
        // Note: don't paste huge base64 into prompt on mobile; server approach recommended.
      } catch (_) {
        imagePart = "\n\n[Image attached but could not be read]";
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
      final uri = Uri.parse(endpoint);
      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 45));

      // --- debug hints (you can comment out in production)
      // print('AGRI SERVICE status: ${response.statusCode}');
      // print('AGRI SERVICE body: ${response.body}');

      // parse body safely
      Map<String, dynamic>? jsonBody;
      try {
        jsonBody = jsonDecode(response.body) as Map<String, dynamic>?;
      } catch (e) {
        jsonBody = null;
      }

      if (response.statusCode == 200 && jsonBody != null) {
        final extracted = _extractTextFromResponse(jsonBody);
        if (extracted.trim().isEmpty) {
          return "⚠️ API returned unexpected content. Please try again.";
        }
        return extracted;
      } else {
        // If non-200, try to parse an error message
        if (jsonBody != null && jsonBody['error'] != null) {
          final err = jsonBody['error'];
          if (err is Map && err['message'] != null) {
            final msg = err['message'].toString();
            return "⚠️ API ERROR: $msg";
          }
        }
        // fallback: show raw body but trimmed
        final bodyPreview = (response.body.length > 800)
            ? response.body.substring(0, 800) + "..."
            : response.body;
        return "⚠️ API ERROR (status ${response.statusCode}): $bodyPreview";
      }
    } on TimeoutException {
      return "⏳ Server took too long. Please try again.";
    } catch (e) {
      return "⚠️ ERROR: $e";
    }
  }

  /// Translate helper — uses same robust parsing by calling sendMessage with a small translate prompt
  Future<String> translateText(String original, String target) async {
    final prompt =
        "Translate the following agricultural chatbot answer into $target. Only translation:\n$original";
    // Reuse sendMessage but NO context & no image
    final res = await sendMessage(prompt);
    // If the response looks like an API error, return it directly
    return res;
  }
}
