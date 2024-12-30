import 'package:flutter/material.dart';
import 'services/sms_service.dart';
import 'models/parsed_sms.dart';

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
  List<ParsedSMS> _bankMessages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBankMessages();
  }

  /// Function to fetch bank messages
  Future<void> _loadBankMessages() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });
    try {
      List<ParsedSMS> messages = await _smsService.fetchBankMessages();
      setState(() {
        _bankMessages = messages;
        _isLoading = false; // Stop loading
      });
    } catch (e) {
      print("Error fetching bank messages: $e");
      setState(() {
        _isLoading = false; // Stop loading even on error
      });
    }
  }

  /// Reload function for pull-to-refresh
  Future<void> _reloadMessages() async {
    await _loadBankMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bank SMS Messages"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _reloadMessages, // Add a manual reload button
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _reloadMessages, // Attach the reload function
        child: _bankMessages.isEmpty
            ? Center(child: Text("No bank messages found"))
            : ListView.builder(
          itemCount: _bankMessages.length,
          itemBuilder: (context, index) {
            ParsedSMS message = _bankMessages[index];
            return ListTile(
              title: Text("${message.bankName}: Rs ${message.amount}"),
              subtitle: Text("Account: ${message.accountNumber}"),
              trailing: Text(message.date),
            );
          },
        ),
      ),
    );
  }
}
