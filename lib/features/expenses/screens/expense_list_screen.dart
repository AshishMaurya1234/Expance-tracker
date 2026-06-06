import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_tile.dart';

enum ExpenseFilter {
  all,
  today,
  week,
  month,
}

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final searchController = TextEditingController();

  ExpenseFilter selectedFilter = ExpenseFilter.all;
  String searchQuery = "";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<ExpenseModel> _applyFilters(List<ExpenseModel> expenses) {
    final now = DateTime.now();

    List<ExpenseModel> filteredExpenses = expenses.where((expense) {
      switch (selectedFilter) {
        case ExpenseFilter.today:
          return expense.date.year == now.year &&
              expense.date.month == now.month &&
              expense.date.day == now.day;

        case ExpenseFilter.week:
          final startOfWeek = DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(
            Duration(days: now.weekday - 1),
          );

          final endOfToday = DateTime(
            now.year,
            now.month,
            now.day,
            23,
            59,
            59,
          );

          return expense.date.isAfter(
            startOfWeek.subtract(const Duration(seconds: 1)),
          ) &&
              expense.date.isBefore(
                endOfToday.add(const Duration(seconds: 1)),
              );

        case ExpenseFilter.month:
          return expense.date.year == now.year &&
              expense.date.month == now.month;

        case ExpenseFilter.all:
          return true;
      }
    }).toList();

    if (searchQuery.trim().isEmpty) {
      return filteredExpenses;
    }

    final query = searchQuery.toLowerCase().trim();

    filteredExpenses = filteredExpenses.where((expense) {
      return expense.category.toLowerCase().contains(query) ||
          expense.ledger.toLowerCase().contains(query) ||
          expense.paymentMode.toLowerCase().contains(query) ||
          expense.notes.toLowerCase().contains(query);
    }).toList();

    return filteredExpenses;
  }

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpenseProvider>().expenses;
    final filteredExpenses = _applyFilters(expenses);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Search expenses",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                onPressed: () {
                  searchController.clear();

                  setState(() {
                    searchQuery = "";
                  });
                },
                icon: const Icon(Icons.close),
              )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),

          const SizedBox(height: 16),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip(
                  label: "All",
                  filter: ExpenseFilter.all,
                ),
                _filterChip(
                  label: "Today",
                  filter: ExpenseFilter.today,
                ),
                _filterChip(
                  label: "Week",
                  filter: ExpenseFilter.week,
                ),
                _filterChip(
                  label: "Month",
                  filter: ExpenseFilter.month,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (filteredExpenses.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(
                child: Text(
                  "No expenses found",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            ...filteredExpenses.map(
                  (expense) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ExpenseTile(expense: expense),
              ),
            ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required ExpenseFilter filter,
  }) {
    final isSelected = selectedFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            selectedFilter = filter;
          });
        },
      ),
    );
  }
}