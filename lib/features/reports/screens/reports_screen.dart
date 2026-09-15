import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/report_service.dart';
import '../services/pdf_report_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _isLoading = true;
  double _totalSum = 0.0;
  List<MonthlyReportData> _breakdown = [];
  final String _selectedMonth = DateTime.now().toIso8601String().substring(0, 7);

  final List<Color> _chartColors = [
    Colors.tealAccent,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.amberAccent,
    Colors.redAccent,
    Colors.greenAccent,
  ];

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    final data = await ReportService.fetchMonthlyReport(_selectedMonth);
    setState(() {
      _totalSum = data['totalSum'];
      _breakdown = data['breakdown'];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports & Analytics"),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: "Print / Export PDF",
            onPressed: _breakdown.isEmpty
                ? null
                : () {
                    PdfReportService.printMonthlyReport(
                      month: _selectedMonth,
                      totalSum: _totalSum,
                      breakdown: _breakdown,
                    );
                  },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReport,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Monthly Spending ($_selectedMonth)",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "₹${_totalSum.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00C897),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_breakdown.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          "No transactions recorded for this month.",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    )
                  else ...[
                    const Text(
                      "Category Share",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 40,
                          sections: _breakdown.asMap().entries.map((entry) {
                            final i = entry.key;
                            final item = entry.value;
                            final color = _chartColors[i % _chartColors.length];
                            return PieChartSectionData(
                              color: color,
                              value: item.totalAmount,
                              title: '${item.sharePercentage}%',
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Category Breakdown",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._breakdown.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      final color = _chartColors[i % _chartColors.length];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color,
                            radius: 12,
                          ),
                          title: Text(item.categoryName),
                          subtitle: Text("${item.transactionCount} transaction(s)"),
                          trailing: Text(
                            "₹${item.totalAmount.toStringAsFixed(2)} (${item.sharePercentage}%)",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
    );
  }
}