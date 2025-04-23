import 'dart:convert';
import 'package:http/http.dart' as http;

// 🔐 Replace these with your actual Azure OpenAI details
const String azureOpenAIEndpoint = 'https://marc-m8wqdemu-eastus2.openai.azure.com/';
const String azureDeploymentId = 'gpt-35-turbo'; // e.g. gpt-35-turbo
const String azureAPIKey = '91R0Sb44u8mRCPkOxiupXnLu4NYJoscloOKq67XQvgLhNFl15CBnJQQJ99BCACHYHv6XJ3w3AAAAACOGAPnH';
const String azureAPIVersion = '2024-05-01-preview';

class GPTService {
  static Future<String> solveMathProblem(String input) async {
    final uri = Uri.parse(
      '$azureOpenAIEndpoint/openai/deployments/$azureDeploymentId/chat/completions?api-version=$azureAPIVersion',
    );

    final headers = {
      'Content-Type': 'application/json',
      'api-key': azureAPIKey,
    };

    final body = jsonEncode({
      'messages': [
        {'role': 'system', 'content': 'You are a helpful math tutor who explains how to solve math problems step by step.'},
        {'role': 'user', 'content': input}
      ],
      'temperature': 0.3,
      'top_p': 1.0,
      'frequency_penalty': 0,
      'presence_penalty': 0,
    });

    try {
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['choices'][0]['message']['content'];
        return result.trim();
      } else {
        throw Exception('Failed to get AI response: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      return '❌ Error contacting AI: $e';
    }
  }
}
