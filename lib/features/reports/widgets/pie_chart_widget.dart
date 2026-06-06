import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const PieChartWidget({
    super.key,
    required this.categoryTotals,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = categoryTotals.values.fold(
      0.0,
          (sum, value) => sum + value,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 260,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 50,
              sectionsSpace: 3,
              sections: categoryTotals.entries.map((entry) {
                final percentage =
                    (entry.value / total) * 100;

                return PieChartSectionData(
                  value: entry.value,
                  title:
                  "${percentage.toStringAsFixed(0)}%",
                  radius: 70,
                  color: _categoryColor(entry.key),
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case "Food":
        return Colors.orange;

      case "Travel":
        return Colors.blue;

      case "Bills":
        return Colors.red;

      case "Shopping":
        return Colors.purple;

      case "Health":
        return Colors.green;

      case "Education":
        return Colors.cyan;

      case "Entertainment":
        return Colors.pink;

      default:
        return Colors.grey;
    }
  }
}