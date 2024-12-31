import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/parsed_sms.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.103.88:3000';

  /// Fetch all messages from the backend.
  Future<List<ParsedSMS>> fetchMessages() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/messages'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => ParsedSMS.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch messages: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("Error fetching messages: $e");
      throw Exception("Error fetching messages from backend");
    }
  }

  /// Post new messages to the backend.
  Future<void> postMessages(List<ParsedSMS> messages) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'messages': messages.map((m) => m.toJson()).toList()}),
      );

      if (response.statusCode == 201) {
        print("Messages posted successfully");
      } else {
        throw Exception('Failed to post messages: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("Error posting messages: $e");
      throw Exception("Error posting messages to backend");
    }
  }
}
