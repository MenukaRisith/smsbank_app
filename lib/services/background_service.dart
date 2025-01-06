import 'dart:convert';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:http/http.dart' as http;
import '../models/parsed_sms.dart';
import '../services/api_service.dart';
import '../utils/sms_parsers.dart';

/// Initialize the background service
Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onBackgroundServiceStart,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onBackgroundServiceStart,
    ),
  );
  service.startService();
}

/// Background service logic
void onBackgroundServiceStart(ServiceInstance service) async {
  final SmsQuery smsQuery = SmsQuery();
  final ApiService apiService = ApiService();

  // Track processed SMS IDs to avoid duplicates
  Set<String> processedSmsIds = {};

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  while (true) {
    try {
      // Fetch SMS messages
      List<SmsMessage> messages = await smsQuery.querySms(kinds: [SmsQueryKind.inbox]);

      for (var message in messages) {
        if (message.body == null || processedSmsIds.contains(message.id.toString())) {
          continue;
        }

        // Parse the SMS
        ParsedSMS? parsedSms = parseSMS(message.body!);

        if (parsedSms != null) {
          // Send to API
          final response = await http.post(
            Uri.parse('${ApiService.baseUrl}/messages'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(parsedSms.toJson()),
          );

          // Mark SMS as processed if the API call succeeds
          if (response.statusCode == 201) {
            processedSmsIds.add(message.id.toString());
            print("Message processed: ${parsedSms.toJson()}");
          } else {
            print("Failed to send SMS: ${response.statusCode}");
          }
        }
      }
    } catch (e) {
      print("Error in background service: $e");
    }

    // Wait 1 second before the next iteration
    await Future.delayed(Duration(seconds: 1));
  }
}
