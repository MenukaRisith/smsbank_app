import 'package:intl/intl.dart';
import '../models/parsed_sms.dart';

// Parser for ATM Cash Deposits (e.g., BOC)
ParsedSMS? parseAtmDeposit(String message) {
  final regex = RegExp(
      r'ATM Cash Deposit Rs (\d+\.\d+) To A\/C No ([\wX]+)\. Balance available Rs (\d+\.\d+)');
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

// Parser for Bank Credit Transactions (e.g., COM)
ParsedSMS? parseCreditTransaction(String message) {
  final regex = RegExp(
      r'Credit for Rs\. ([\d,]+\.\d+) to ([\dX]+) at (\d{2}:\d{2}) at (.+)');
  final match = regex.firstMatch(message);
  if (match != null) {
    return ParsedSMS(
      bankName: "COM",
      amount: double.parse(match.group(1)!.replaceAll(',', '')),
      accountNumber: match.group(2)!,
      location: match.group(4)!.trim(),
      date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
      time: DateFormat('hh:mm a').format(DateFormat('HH:mm').parse(match.group(3)!)),
    );
  }
  return null;
}

// Parser for Bank Debit Transactions
ParsedSMS? parseDebitTransaction(String message) {
  final regex = RegExp(
      r'Debit for Rs\. ([\d,]+\.\d+) from ([\dX]+) at (\d{2}:\d{2}) at (.+)');
  final match = regex.firstMatch(message);
  if (match != null) {
    return ParsedSMS(
      bankName: "Debit Transaction",
      amount: double.parse(match.group(1)!.replaceAll(',', '')),
      accountNumber: match.group(2)!,
      location: match.group(4)!.trim(),
      date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
      time: DateFormat('hh:mm a').format(DateFormat('HH:mm').parse(match.group(3)!)),
    );
  }
  return null;
}

// Parser for HNB Transactions
ParsedSMS? parseHnbTransaction(String message) {
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

// Parser for Utility Bill Payments
ParsedSMS? parseUtilityBillPayment(String message) {
  final regex = RegExp(
      r'Payment of Rs\. (\d+\.\d+) made from A\/C ([\dX]+) for utility bill on (\d{2}/\d{2}/\d{4}) at (\d{1,2}:\d{2} (?:AM|PM))');
  final match = regex.firstMatch(message);
  if (match != null) {
    return ParsedSMS(
      bankName: "Utility Payment",
      amount: double.parse(match.group(1)!),
      accountNumber: match.group(2)!,
      location: "Utility Bill Payment",
      date: match.group(3)!,
      time: match.group(4)!,
    );
  }
  return null;
}

// Parser for PPL (e.g., LPAY Tfr)
ParsedSMS? parsePplTransaction(String message) {
  final regex = RegExp(
      r'Your A\/C ([\d-]+) has been credited by Rs\. ([\d,]+\.\d+) \(LPAY Tfr @(\d{2}:\d{2}) (\d{2}/\d{2}/\d{4})\)');
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

// Parser for Balance Inquiries
ParsedSMS? parseBalanceInquiry(String message) {
  final regex = RegExp(r'Your account balance is Rs ([\d,]+\.\d+)\.');
  final match = regex.firstMatch(message);
  if (match != null) {
    return ParsedSMS(
      bankName: "Balance Inquiry",
      amount: double.parse(match.group(1)!.replaceAll(',', '')),
      accountNumber: "N/A",
      location: "N/A",
      date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
      time: DateFormat('hh:mm a').format(DateTime.now()),
    );
  }
  return null;
}

// Unified SMS Parser
ParsedSMS? parseSMS(String message) {
  for (var parser in [
    parseAtmDeposit,
    parseCreditTransaction,
    parseDebitTransaction,
    parseHnbTransaction,
    parseUtilityBillPayment,
    parsePplTransaction,
    parseBalanceInquiry
  ]) {
    final result = parser(message);
    if (result != null) return result;
  }
}
