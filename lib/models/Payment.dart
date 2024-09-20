class Payment{
  final String amount;
  final String currency;
  final String date;
  final String transactionId;

  Payment({required this.amount, required this.currency, required this.date, required this.transactionId});

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      amount: json['amount'],
      currency: json['currency'],
      date: json['created_at'],
      transactionId: json['transaction_id'],
    );
  }
}