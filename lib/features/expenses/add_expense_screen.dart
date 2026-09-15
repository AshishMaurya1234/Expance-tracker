import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/expense_model.dart';
import 'providers/expense_provider.dart';
import '../categories/providers/category_provider.dart';
import '../ledgers/providers/ledger_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  final ExpenseModel? expense;

  const AddExpenseScreen({
    super.key,
    this.expense,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final amountController = TextEditingController();
  final notesController = TextEditingController();

  final paymentModes = [
    'Cash',
    'UPI',
    'Card',
    'Net Banking',
    'Wallet',
  ];

  String selectedCategory = 'Food';
  String selectedLedger = 'Cash';
  String selectedPaymentMode = 'Cash';
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    final expense = widget.expense;

    if (expense != null) {
      amountController.text = expense.amount.toStringAsFixed(0);
      notesController.text = expense.notes;
      selectedCategory = expense.category;
      selectedLedger = expense.ledger;
      selectedPaymentMode = expense.paymentMode;
      selectedDate = expense.date;
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) return;

    setState(() {
      selectedDate = pickedDate;
    });
  }

  void saveExpense() {
    final amount = double.tryParse(amountController.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
        ),
      );
      return;
    }

    final expense = ExpenseModel(
      id: widget.expense?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      category: selectedCategory,
      ledger: selectedLedger,
      paymentMode: selectedPaymentMode,
      date: selectedDate,
      notes: notesController.text.trim(),
    );

    if (widget.expense == null) {
      context.read<ExpenseProvider>().addExpense(expense);
    } else {
      context.read<ExpenseProvider>().updateExpense(expense);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.expense == null
              ? 'Expense saved successfully'
              : 'Expense updated successfully',
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        context.watch<CategoryProvider>().categories;

    final ledgers =
        context.watch<LedgerProvider>().ledgers;

    final categoryExists = categories.any(
          (category) => category.name == selectedCategory,
    );

    final ledgerExists = ledgers.any(
          (ledger) => ledger.name == selectedLedger,
    );

    if (!categoryExists && categories.isNotEmpty) {
      selectedCategory = categories.first.name;
    }

    if (!ledgerExists && ledgers.isNotEmpty) {
      selectedLedger = ledgers.first.name;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.expense == null ? 'Add Expense' : 'Edit Expense',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _card(
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    labelText: 'Amount',
                    prefixText: '₹ ',
                  ),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _sectionTitle('Category'),

              _card(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: categories.map((category) {
                    final isSelected =
                        selectedCategory == category.name;

                    return ChoiceChip(
                      label: Text(category.name),
                      selected: isSelected,
                      avatar: Icon(
                        _categoryIcon(category.icon),
                        size: 18,
                      ),
                      onSelected: (_) {
                        setState(() {
                          selectedCategory = category.name;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              _card(
                child: DropdownButtonFormField<String>(
                  initialValue: selectedLedger,
                  decoration: _inputDecoration(
                    labelText: 'Ledger / Account',
                  ),
                  items: ledgers.map((ledger) {
                    return DropdownMenuItem(
                      value: ledger.name,
                      child: Text(ledger.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      selectedLedger = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 16),

              _card(
                child: DropdownButtonFormField<String>(
                  initialValue: selectedPaymentMode,
                  decoration: _inputDecoration(
                    labelText: 'Payment Mode',
                  ),
                  items: paymentModes.map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(mode),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      selectedPaymentMode = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 16),

              _card(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Expense Date'),
                  subtitle: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: pickDate,
                ),
              ),

              const SizedBox(height: 16),

              _card(
                child: TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: _inputDecoration(
                    labelText: 'Notes',
                    hintText: 'Optional note',
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: saveExpense,
                  child: Text(
                    widget.expense == null
                        ? 'Save Expense'
                        : 'Update Expense',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          if (!isDarkMode)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String labelText,
    String? hintText,
    String? prefixText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixText: prefixText,
      filled: false,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      contentPadding: EdgeInsets.zero,
    );
  }

  IconData _categoryIcon(String icon) {
    switch (icon) {
      case "food":
        return Icons.restaurant;
      case "travel":
        return Icons.directions_car;
      case "bills":
        return Icons.receipt_long;
      case "shopping":
        return Icons.shopping_bag;
      case "health":
        return Icons.health_and_safety;
      case "education":
        return Icons.school;
      case "entertainment":
        return Icons.movie;
      case "gaming":
        return Icons.sports_esports;
      case "pets":
        return Icons.pets;
      case "fitness":
        return Icons.fitness_center;
      case "gift":
        return Icons.card_giftcard;
      case "rent":
        return Icons.home;
      case "fuel":
        return Icons.local_gas_station;
      case "salary":
        return Icons.payments;
      case "family":
        return Icons.family_restroom;
      default:
        return Icons.category;
    }
  }
}