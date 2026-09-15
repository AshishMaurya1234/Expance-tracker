import '../../../core/services/api_service.dart';

class MonthlyReportData {
  final String categoryName;
  final int transactionCount;
  final double totalAmount;
  final double sharePercentage;

  MonthlyReportData({
    required this.categoryName,
    required this.transactionCount,
    required this.totalAmount,
    required this.sharePercentage,
  });

  factory MonthlyReportData.fromJson(Map<String, dynamic> json) {
    return MonthlyReportData(
      categoryName: json['category_name'] ?? 'Other',
      transactionCount: int.tryParse(json['transaction_count'].toString()) ?? 0,
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      sharePercentage: double.tryParse(json['share_percentage'].toString()) ?? 0.0,
    );
  }
}

class ReportService {
  static Future<Map<String, dynamic>> fetchMonthlyReport(String month) async {
    try {
      final response = await ApiService.get('/reports/monthly?month=$month');
      final totalSum = double.tryParse(response['totalSum'].toString()) ?? 0.0;
      final rawBreakdown = response['breakdown'] as List? ?? [];
      
      final breakdown = rawBreakdown
          .map((item) => MonthlyReportData.fromJson(item))
          .toList();

      return {
        'totalSum': totalSum,
        'breakdown': breakdown,
      };
    } catch (e) {
      return {
        'totalSum': 0.0,
        'breakdown': <MonthlyReportData>[],
      };
    }
  }
}