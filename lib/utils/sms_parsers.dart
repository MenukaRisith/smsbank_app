import 'package:intl/intl.dart';
import '../models/parsed_sms.dart';

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

ParsedSMS? parseCom(String message) {
  final regex = RegExp(r'Credit for Rs\. (\d+,\d+\.\d+) to (\d+) at (\d{2}:\d{2}) at (.+)');
  final match = regex.firstMatch(message);
  if (match != null) {
    return ParsedSMS(
      bankName: "COM",
      amount: double.parse(match.group(1)!.replaceAll(',', '')),
      accountNumber: match.group(2)!,
      location: match.group(4)!,
      date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
      time: DateFormat('hh:mm a').format(DateFormat('HH:mm').parse(match.group(3)!)),
    );
  }
  return null;
}

ParsedSMS? parseHnb(String message) {
  final regex = RegExp(
      r'A Transaction for LKR ([\d,]+\.\d+) has been credited to Ac No:([X\d]+) on (\d{2}/\d{2}/\d{4}) (\d{2}:\d{2}:\d{2})');
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

ParsedSMS? parsePpl(String message) {
  final regex = RegExp(
      r'Your A\/C (\d+-\d+.*\d+) has been credited by Rs\. (\d+,\d+\.\d+) \(LPAY Tfr @(\d{1,2}:\d{2}) (\d{2}/\d{2}/\d{4})\)');
  final match = regex.firstMatch(message);
  if (match != null) {
    return ParsedSMS(
      bankName: "PPL",
      amount: double.parse(match.group(2)!.replaceAll(',', '')),
      accountNumber: match.group(1)!,
      date: match.group(4)!,
      time: DateFormat('hh:mm a').format(DateFormat('HH:mm').parse(match.group(3)!)),
      location: "PPL",
    );
  }
  return null;
}

ParsedSMS? parseSMS(String message) {
  for (var parser in [parseBoc, parseCom, parseHnb, parsePpl]) {
    ParsedSMS? result = parser(message);
    if (result != null) return result;
  }
  return null;
}
