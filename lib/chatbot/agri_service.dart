import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class AgriService {
  static const String GEMINI_API_KEY =
      "AIzaSyAtFGlspzFRli60c-ESXX-jS8fBgyGPu38"; // replace with your key

  Future<String> sendMessage(String query) async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$GEMINI_API_KEY",
    );

    final prompt =
        """
You are a trusted Agricultural Assistant for farmers in Kerala.

Instructions:
1. Use ONLY ICAR, KAU, IMD or Government schemes data.
2. Answer short and practical (2-4 lines).
3. Farmer friendly language (Hindi/English/Malayalam).
4. Add source at the end.
If information not found:
"Please contact Krishi Officer."

Farmer Question:
$query
""";

    final body = {
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
          .timeout(const Duration(seconds: 45)); // timeout added

      final json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return json["candidates"][0]["content"]["parts"][0]["text"];
      } else {
        return "⚠️ API ERROR:\n${response.body}";
      }
    } on TimeoutException {
      return "⏳ Server took too long. Please try again.";
    } catch (e) {
      return "⚠️ ERROR: $e";
    }
  }
}
