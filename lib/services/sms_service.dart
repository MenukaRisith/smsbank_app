import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/parsed_sms.dart';
import '../utils/sms_parsers.dart';

class SmsService {
  final SmsQuery _smsQuery = SmsQuery();

  Future<List<ParsedSMS>> fetchBankMessages() async {
    if (await Permission.sms.request().isGranted) {
      try {
        List<SmsMessage> messages = await _smsQuery.querySms();
        List<ParsedSMS> bankMessages = [];

        for (var message in messages) {
          if (message.body != null) {
            print("Raw SMS: ${message.body}");
            ParsedSMS? parsed = parseSMS(message.body!);
            if (parsed != null) {
              print("Parsed SMS: $parsed");
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
      throw Exception("SMS Permission Denied");
    }
  }
}
