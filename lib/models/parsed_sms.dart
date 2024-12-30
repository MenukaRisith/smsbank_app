class ParsedSMS {
  final String bankName;
  final double amount;
  final String accountNumber;
  final String location;
  final String date;
  final String time;

  ParsedSMS({
    required this.bankName,
    required this.amount,
    required this.accountNumber,
    required this.location,
    required this.date,
    required this.time,
  });

  @override
  String toString() {
    return 'ParsedSMS{bankName: $bankName, amount: $amount, accountNumber: $accountNumber, location: $location, date: $date, time: $time}';
  }
}
