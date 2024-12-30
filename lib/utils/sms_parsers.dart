import 'package:intl/intl.dart';
import '../models/parsed_sms.dart';

// Parser for BOC messages
ParsedSMS? parseBoc(String message) {
  final regex = RegExp(r'ATM Cash Deposit Rs (\d+\.\d+) To A\/C No (\w+)\. Balance available Rs (\d+\.\d+)');
  final match = regex.firstMatch(message);

  if (match != null) {
    return ParsedSMS(
      bankName: "BOC",
      amount: double.parse(match.group(1)!),
      accountNumber: match.group(2)!,
      location: "ATM",
      date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
      time: DateFormat('hh:mm a').format(DateTime.now()),
    );
  }
  return null;
}

// Parser for COM messages
ParsedSMS? parseCom(String message) {
  final regex = RegExp(
    r'Credit for Rs\. (\d+,\d+\.\d+) to (\d+) at (\d{2}:\d{2}) at (.+)',
    caseSensitive: false,
  );
  final match = regex.firstMatch(message);

  if (match != null) {
    String time = DateFormat('h:mm a').format(DateFormat('HH:mm').parse(match.group(3)!));
    return ParsedSMS(
      bankName: "COM",
      amount: double.parse(match.group(1)!.replaceAll(',', '')),
      accountNumber: match.group(2)!,
      location: match.group(4)!.trim(),
      date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
      time: time,
    );
  }
  return null;
}

// Parser for HNB messages
ParsedSMS? parseHnb(String message) {
  final regex = RegExp(
    r'A Transaction for LKR ([\d,]+\.\d+) has been credited to Ac No:([X\d]+) on (\d{2}/\d{2}/\d{4}) (\d{2}:\d{2}:\d{2})',
    caseSensitive: false,
  );
  final match = regex.firstMatch(message);

  if (match != null) {
    return ParsedSMS(
      bankName: "HNB",
      amount: double.parse(match.group(1)!.replaceAll(',', '')),
      accountNumber: match.group(2)!,
      date: match.group(3)!,
      time: DateFormat('hh:mm a').format(DateFormat('HH:mm:ss').parse(match.group(4)!)),
      location: "HNB",
    );
  }
  return null;
}

// Parser for PPL messages
ParsedSMS? parsePpl(String message) {
  final regex = RegExp(
    r'Your A\/C (\d+-\d+.*\d+) has been credited by Rs\. (\d+,\d+\.\d+) \(LPAY Tfr @(\d{1,2}:\d{2}) (\d{2}/\d{2}/\d{4})\)',
    caseSensitive: false,
  );
  final match = regex.firstMatch(message);

  if (match != null) {
    final accountNumber = match.group(1) ?? "";
    final amountString = match.group(2)?.replaceAll(',', '') ?? "0.0";
    final timeString = match.group(3) ?? "";
    final dateString = match.group(4) ?? "";

    final amount = double.parse(amountString);
    final time = DateFormat("h:mm a").format(DateFormat("HH:mm").parse(timeString));
    final date = DateFormat("dd/MM/yyyy").format(DateFormat("dd/MM/yyyy").parse(dateString));

    return ParsedSMS(
      bankName: "PPL",
      amount: amount,
      accountNumber: accountNumber,
      date: date,
      time: time,
      location: "PPL",
    );
  }
  return null;
}

// Unified parser function
ParsedSMS? parseSMS(String message) {
  message = message.trim();

  List<ParsedSMS? Function(String)> parsers = [
    parseBoc,
    parseCom,
    parseHnb,
    parsePpl,
    // Add more parsers here
  ];

  for (var parser in parsers) {
    ParsedSMS? result = parser(message);
    if (result != null) {
      print("Message parsed successfully with ${result.bankName} parser.");
      return result;
    }
  }

  print("No parser matched the message.");
  return null;
}
