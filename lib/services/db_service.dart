import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/parsed_sms.dart';

class DatabaseService {
  /// Get the path to the application's documents directory.
  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/bank_messages.json";
  }

  /// Save a parsed SMS message to a JSON file.
  Future<void> saveMessageToJson(ParsedSMS message) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/bank_messages.json';
      print('Saving JSON to: $filePath'); // Print the file path
      final file = File(filePath);

      // Load existing messages
      List<dynamic> existingMessages = [];
      if (await file.exists()) {
        final contents = await file.readAsString();
        existingMessages = jsonDecode(contents);
      }

      // Add new message
      existingMessages.add({
        'bankName': message.bankName,
        'amount': message.amount,
        'accountNumber': message.accountNumber,
        'location': message.location,
        'date': message.date,
        'time': message.time,
      });

      // Save the updated messages
      await file.writeAsString(jsonEncode(existingMessages));
      print('Message saved to JSON file: $message');
    } catch (e) {
      print('Error saving message to JSON file: $e');
    }
  }

  /// Read all messages from the JSON file.
  Future<List<ParsedSMS>> getMessagesFromJson() async {
    try {
      final filePath = await _getFilePath();
      final messages = await _readMessagesFromJson(filePath);
      return messages.map((json) => ParsedSMS.fromJson(json)).toList();
    } catch (e) {
      print("Error reading messages from JSON file: $e");
      return [];
    }
  }

  /// Private helper function to read messages from the JSON file.
  Future<List<dynamic>> _readMessagesFromJson(String filePath) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        await file.create();
        await file.writeAsString("[]"); // Initialize with an empty list
      }

      final contents = await file.readAsString();
      return jsonDecode(contents) as List<dynamic>;
    } catch (e) {
      print("Error reading JSON file: $e");
      return [];
    }
  }
}
