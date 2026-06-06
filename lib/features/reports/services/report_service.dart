import '../../expenses/models/expense_model.dart';

class ReportService {
  static Map<String, double> categoryTotals(List<ExpenseModel> expenses) {
    final Map<String, double> totals = {};

    for (final expense in expenses) {
      totals.update(
        expense.category,
            (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    return totals;
  }

  static double totalAmount(List<ExpenseModel> expenses) {
    return expenses.fold(
      0.0,
          (sum, expense) => sum + expense.amount,
    );
  }
}