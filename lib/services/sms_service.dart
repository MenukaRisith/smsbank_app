import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/parsed_sms.dart';
import '../utils/sms_parsers.dart';

class SmsService {
  final SmsQuery _smsQuery = SmsQuery();

  Future<List<ParsedSMS>> fetchBankMessages() async {
    // Check SMS permission
    if (await Permission.sms.request().isGranted) {
      try {
        // Fetch SMS messages from the inbox
        List<SmsMessage> messages = await _smsQuery.querySms();
        List<ParsedSMS> bankMessages = [];

        for (var message in messages) {
          if (message.body != null) {
            print("Raw SMS: ${message.body}"); // Debug raw SMS content

            // Use the unified parser to handle SMS parsing
            ParsedSMS? parsed = parseSMS(message.body!);

            if (parsed != null) {
              print("Parsed SMS: $parsed"); // Debug parsed content
              bankMessages.add(parsed);
            } else {
              print("Message not parsed: ${message.body}");
            }
          }
        }

        return bankMessages;
      } catch (e) {
        print("Error fetching or parsing SMS messages: $e");
        throw Exception("Failed to fetch or parse SMS messages");
      }
    } else {
      // Throw an error if permission is denied
      throw Exception("SMS Permission Denied");
    }
  }
}
