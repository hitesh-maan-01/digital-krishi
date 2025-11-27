// ignore_for_file: constant_identifier_names, unnecessary_type_check, depend_on_referenced_packages, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

class AgriService {
  static const String GEMINI_API_KEY =
      "AIzaSyDr2T0sA3xBFpboXwjdSregXHr2FRsskOU"; // replace

  String _extractTextFromResponse(Map<String, dynamic> jsonBody) {
    try {
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
              if (part is Map && part.containsKey('text')) {
                return part['text'].toString();
              }
              if (part is Map && part.containsKey('content')) {
                return part['content'].toString();
              }
            }
            if (content is Map && content.containsKey('text')) {
              return content['text'].toString();
            }
          }
        }
      }

      if (jsonBody['output'] is List && jsonBody['output'].isNotEmpty) {
        final out0 = jsonBody['output'][0];
        if (out0 is Map && out0['content'] != null) {
          return out0['content'].toString();
        }
      }

      if (jsonBody['text'] != null) return jsonBody['text'].toString();

      return "";
    } catch (_) {
      return "";
    }
  }

  Future<String> sendMessage(
    String query, {
    File? imageFile,
    List<Map<String, dynamic>>? lastMessages,
  }) async {
    final endpoint =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$GEMINI_API_KEY";

    // Build context (last 3)
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
        final prefix = b64.length > 800 ? b64.substring(0, 800) : b64;
        imagePart = "\n\n[ImageBase64Prefix]: $prefix ... (truncated)";
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
4. If image attached → analyze and diagnose, prevention.
5. If unsure → say "Please contact Krishi Officer."
6. Use helpful emojis.
7. Use previous chat context for better relevance.
8. Response in same language in which query is send.
9. If new query is related to previous query response based on previous query, otherwise new response.

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

      Map<String, dynamic>? jsonBody;
      try {
        jsonBody = jsonDecode(response.body) as Map<String, dynamic>?;
      } catch (_) {
        jsonBody = null;
      }

      if (response.statusCode == 200 && jsonBody != null) {
        final extracted = _extractTextFromResponse(jsonBody);
        if (extracted.trim().isEmpty) {
          return "⚠️ API returned unexpected content. Please try again.";
        }
        return extracted;
      } else {
        if (jsonBody != null && jsonBody['error'] != null) {
          final err = jsonBody['error'];
          if (err is Map && err['message'] != null) {
            final msg = err['message'].toString();
            return "⚠️ API ERROR: $msg";
          }
        }
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

  Future<String> translateText(String original, String target) async {
    final prompt =
        "Translate the following agricultural chatbot answer into $target. Only translate, no extra text:\n$original";
    // re-use sendMessage but with prompt as the query and no image or context
    final res = await sendMessage(prompt, imageFile: null, lastMessages: null);
    return res;
  }
}
