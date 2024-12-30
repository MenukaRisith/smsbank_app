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

  /// Convert ParsedSMS to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'bankName': bankName,
      'amount': amount,
      'accountNumber': accountNumber,
      'location': location,
      'date': date,
      'time': time,
    };
  }

  /// Create ParsedSMS from a JSON map.
  factory ParsedSMS.fromJson(Map<String, dynamic> json) {
    return ParsedSMS(
      bankName: json['bankName'],
      amount: (json['amount'] as num).toDouble(),
      accountNumber: json['accountNumber'],
      location: json['location'],
      date: json['date'],
      time: json['time'],
    );
  }

  @override
  String toString() {
    return 'ParsedSMS{bankName: $bankName, amount: $amount, accountNumber: $accountNumber, location: $location, date: $date, time: $time}';
  }
}
