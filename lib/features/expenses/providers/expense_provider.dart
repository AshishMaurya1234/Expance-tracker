import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;
  String? _error;

  List<ExpenseModel> get expenses {
    final sorted = [..._expenses];
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get transactionCount => _expenses.length;

  // Map category names to database IDs
  int _resolveCategoryId(String categoryName) {
    switch (categoryName.toLowerCase().trim()) {
      case 'food':
        return 1;
      case 'travel':
        return 2;
      case 'bills':
        return 3;
      case 'shopping':
        return 4;
      case 'health':
        return 5;
      case 'entertainment':
        return 6;
      default:
        return 1;
    }
  }

  // Fetch all expenses from backend / MySQL
  Future<void> fetchExpenses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.get('/expenses');
      if (data is List) {
        _expenses = data.map<ExpenseModel>((json) {
          return ExpenseModel(
            id: json['expense_id'].toString(),
            amount: double.parse(json['amount'].toString()),
            date: DateTime.parse(json['expense_date']),
            paymentMode: json['payment_mode'] ?? 'Cash',
            notes: json['notes'] ?? '',
            category: json['category_name'] ?? 'General',
            ledger: json['ledger'] ?? 'General',
          );
        }).toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add Expense with correct category ID
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      _expenses.add(expense);
      notifyListeners();

      final categoryId = _resolveCategoryId(expense.category);

      await ApiService.post('/expenses', {
        'amount': expense.amount,
        'expense_date': expense.date.toIso8601String().substring(0, 10),
        'payment_mode': expense.paymentMode,
        'notes': expense.notes,
        'category_id': categoryId,
      });

      // Reload fresh data from database
      await fetchExpenses();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update Expense with correct category ID
  Future<void> updateExpense(ExpenseModel updatedExpense) async {
    final index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
    if (index != -1) {
      _expenses[index] = updatedExpense;
      notifyListeners();

      try {
        final categoryId = _resolveCategoryId(updatedExpense.category);

        await ApiService.put('/expenses/${updatedExpense.id}', {
          'amount': updatedExpense.amount,
          'expense_date': updatedExpense.date.toIso8601String().substring(0, 10),
          'payment_mode': updatedExpense.paymentMode,
          'notes': updatedExpense.notes,
          'category_id': categoryId,
        });

        await fetchExpenses();
      } catch (e) {
        _error = e.toString();
        notifyListeners();
      }
    }
  }

  // Delete Expense
  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();

    try {
      await ApiService.delete('/expenses/$id');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Aggregates for Dashboard
  double get todayTotal {
    final now = DateTime.now();
    return _expenses
        .where((e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get weekTotal {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final cleanStart =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return _expenses
        .where((e) =>
            e.date.isAfter(cleanStart.subtract(const Duration(seconds: 1))))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get monthTotal {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }
}