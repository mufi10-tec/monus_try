import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqService {
  // Groq API Key
  final String apiKey = "YOUR_GROQ_API_KEY_HERE";

  // 1. സാധാരണ ചോദ്യങ്ങൾക്ക് മറുപടി നൽകുന്ന ഫംഗ്ഷൻ
  Future<String?> askGroq(String userPrompt) async {
    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {
              "role": "system",
              "content": "You are a helpful and concise AI assistant."
            },
            {"role": "user", "content": userPrompt}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String reply = data['choices'][0]['message']['content'];
        return reply;
      } else {
        print("Groq Error: ${response.body}");
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      print("Exception: $e");
      return "എന്തോ തകരാർ സംഭവിച്ചു!";
    }
  }

  // 2. വാചകത്തിൽ നിന്ന് Title, Amount വേർതിരിച്ചെടുക്കുന്ന ഫംഗ്ഷൻ
  Future<Map<String, dynamic>?> extractExpense(String userInput) async {
    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

    String systemPrompt = '''
    You are an expense extractor assistant. 
    Extract the title and amount from the user's input.
    Always respond ONLY in a valid JSON format like this:
    {"title": "extracted title", "amount": 0.0}
    Do not add any extra explanation or text outside the JSON.
    ''';

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "response_format": {"type": "json_object"},
          "messages": [
            {"role": "system", "content": systemPrompt},
            {"role": "user", "content": userInput}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String rawJson = data['choices'][0]['message']['content'];
        return jsonDecode(rawJson);
      }
      return null;
    } catch (e) {
      print("Extract Error: $e");
      return null;
    }
  }
}
