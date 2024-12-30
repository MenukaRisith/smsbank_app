import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsService {
  final SmsQuery _smsQuery = SmsQuery();

  // Fetch all SMS messages
  Future<List<SmsMessage>> fetchAllMessages() async {
    // Request SMS permission
    if (await Permission.sms.request().isGranted) {
      return await _smsQuery.querySms(); // Fetch all SMS messages
    } else {
      throw Exception("SMS Permission Denied");
    }
  }
}
