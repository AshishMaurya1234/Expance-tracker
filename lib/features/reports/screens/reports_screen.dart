import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../expenses/providers/expense_provider.dart';
import '../services/report_service.dart';
import '../widgets/pie_chart_widget.dart';
import '../widgets/bar_chart_widget.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpenseProvider>().expenses;
    final categoryTotals = ReportService.categoryTotals(expenses);
    final totalAmount = ReportService.totalAmount(expenses);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Reports",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Total Spent: ₹${totalAmount.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const Text(
            "Category Distribution",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          PieChartWidget(
            categoryTotals: categoryTotals,
          ),

          const SizedBox(height: 20),

          const Text(
            "Category Bar Chart",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          BarChartWidget(
            categoryTotals: categoryTotals,
          ),

          const SizedBox(height: 20),

          const Text(
            "Category Breakdown",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          if (categoryTotals.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 80),
                child: Text("No report data available"),
              ),
            )
          else
            ...categoryTotals.entries.map(
                  (entry) {
                final percentage =
                totalAmount == 0 ? 0 : (entry.value / totalAmount) * 100;

                return Card(
                  child: ListTile(
                    title: Text(entry.key),
                    subtitle: Text("${percentage.toStringAsFixed(1)}%"),
                    trailing: Text(
                      "₹${entry.value.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}