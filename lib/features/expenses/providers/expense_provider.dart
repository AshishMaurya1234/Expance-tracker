import 'package:flutter/material.dart';
import '../models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  final List<ExpenseModel> _expenses = [];

  List<ExpenseModel> get expenses {
    final sortedExpenses = [..._expenses];
    sortedExpenses.sort((a, b) => b.date.compareTo(a.date));
    return sortedExpenses;
  }

  //* Today Total
  double get todayTotal {
    final now = DateTime.now();

    return _expenses
        .where(
          (expense) =>
      expense.date.year == now.year &&
          expense.date.month == now.month &&
          expense.date.day == now.day,
    )
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

//* This Week Total
  double get weekTotal {
    final now = DateTime.now();

    final startOfWeek = now.subtract(
      Duration(days: now.weekday - 1),
    );

    return _expenses
        .where(
          (expense) =>
      expense.date.isAfter(
        DateTime(
          startOfWeek.year,
          startOfWeek.month,
          startOfWeek.day,
        ).subtract(const Duration(seconds: 1)),
      ) &&
          expense.date.isBefore(
            DateTime(
              now.year,
              now.month,
              now.day,
              23,
              59,
              59,
            ).add(const Duration(seconds: 1)),
          ),
    )
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

//* This Month Total
  double get monthTotal {
    final now = DateTime.now();

    return _expenses
        .where(
          (expense) =>
      expense.date.year == now.year &&
          expense.date.month == now.month,
    )
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

//* Total Transactions
  int get transactionCount {
    return _expenses.length;
  }

  void addExpense(ExpenseModel expense) {
    _expenses.add(expense);
    notifyListeners();
  }

  void updateExpense(ExpenseModel updatedExpense) {
    final index = _expenses.indexWhere(
          (expense) => expense.id == updatedExpense.id,
    );

    if (index == -1) return;

    _expenses[index] = updatedExpense;
    notifyListeners();
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((expense) => expense.id == id);
    notifyListeners();
  }
}