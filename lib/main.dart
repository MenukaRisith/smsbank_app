import 'package:flutter/material.dart';
import 'services/sms_service.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SmsListScreen(),
    );
  }
}

class SmsListScreen extends StatefulWidget {
  @override
  _SmsListScreenState createState() => _SmsListScreenState();
}

class _SmsListScreenState extends State<SmsListScreen> {
  final SmsService _smsService = SmsService();
  List<SmsMessage> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      List<SmsMessage> messages = await _smsService.fetchAllMessages();
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching SMS: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SMS Messages"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _messages.isEmpty
          ? Center(child: Text("No messages found"))
          : ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          SmsMessage message = _messages[index];
          return ListTile(
            title: Text(message.body ?? "No content"),
            subtitle: Text(message.address ?? "Unknown sender"),
          );
        },
      ),
    );
  }
}
