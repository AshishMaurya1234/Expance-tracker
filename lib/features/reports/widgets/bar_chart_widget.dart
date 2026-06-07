import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartWidget extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const BarChartWidget({
    super.key,
    required this.categoryTotals,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) {
      return const SizedBox.shrink();
    }

    final entries = categoryTotals.entries.toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 280,
          child: BarChart(
            BarChartData(
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();

                      if (index < 0 || index >= entries.length) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          entries[index].key.substring(
                            0,
                            entries[index].key.length > 3
                                ? 3
                                : entries[index].key.length,
                          ),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: List.generate(
                entries.length,
                    (index) {
                  final entry = entries[index];

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        width: 18,
                        borderRadius: BorderRadius.circular(8),
                        color: _categoryColor(entry.key),
                      ),
                    ],
                  );
                },
              ),
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