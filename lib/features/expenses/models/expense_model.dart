class ExpenseModel {
  final String id;
  final double amount;
  final String category;
  final String ledger;
  final String paymentMode;
  final DateTime date;
  final String notes;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.ledger,
    required this.paymentMode,
    required this.date,
    required this.notes,
  });
}