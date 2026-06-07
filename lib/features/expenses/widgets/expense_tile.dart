import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../add_expense_screen.dart';
import '../models/expense_model.dart';
import '../providers/expense_provider.dart';

class ExpenseTile extends StatelessWidget {
  final ExpenseModel expense;

  const ExpenseTile({
    super.key,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
          child: Icon(
            _categoryIcon(expense.category),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          expense.category,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          "${expense.ledger} • ${expense.paymentMode}\n${expense.date.day}/${expense.date.month}/${expense.date.year}",
        ),
        isThreeLine: true,
        trailing: Text(
          "- ₹${expense.amount.toStringAsFixed(0)}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        onTap: () {
          _showExpenseBottomSheet(context, expense);
        },
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case "Food":
        return Icons.restaurant;
      case "Travel":
        return Icons.directions_car;
      case "Bills":
        return Icons.receipt_long;
      case "Shopping":
        return Icons.shopping_bag;
      case "Health":
        return Icons.health_and_safety;
      case "Entertainment":
        return Icons.movie;
      case "Education":
        return Icons.school;
      default:
        return Icons.category;
    }
  }

  void _showExpenseBottomSheet(
      BuildContext context,
      ExpenseModel expense,
      ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            runSpacing: 14,
            children: [
              Text(
                expense.category,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              _detailRow(
                "Amount",
                "- ₹${expense.amount.toStringAsFixed(0)}",
              ),

              _detailRow(
                "Ledger",
                expense.ledger,
              ),

              _detailRow(
                "Payment Mode",
                expense.paymentMode,
              ),

              _detailRow(
                "Date",
                "${expense.date.day}/${expense.date.month}/${expense.date.year}",
              ),

              if (expense.notes.isNotEmpty)
                _detailRow(
                  "Notes",
                  expense.notes,
                ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddExpenseScreen(
                          expense: expense,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit Expense"),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);

                    showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: const Text("Delete Expense?"),
                          content: const Text(
                            "This expense will be permanently deleted. This action cannot be undone.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                              },
                              child: const Text("Cancel"),
                            ),
                            FilledButton(
                              onPressed: () {
                                context
                                    .read<ExpenseProvider>()
                                    .deleteExpense(expense.id);

                                Navigator.pop(dialogContext);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                    Text("Expense deleted permanently"),
                                  ),
                                );
                              },
                              child: const Text("Delete"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text("Delete Expense"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}