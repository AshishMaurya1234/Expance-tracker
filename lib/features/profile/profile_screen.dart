import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/theme_provider.dart';
import '../../core/services/storage_service.dart';
import '../auth/screens/login_screen.dart';
import '../auth/services/auth_service.dart';
import '../categories/screens/category_management_screen.dart';
import '../expenses/providers/expense_provider.dart';
import '../ledgers/screens/ledger_management_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to end your current session?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4F6B),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authService = AuthService();
      await authService.logout();
      await StorageService.clearToken();

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile & Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Avatar & User Info
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF00C897), width: 3),
                  ),
                  child: const CircleAvatar(
                    radius: 44,
                    backgroundColor: Color(0xFF1E2535),
                    child: Icon(Icons.person, size: 50, color: Color(0xFF00C897)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Ashish Maurya",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "ashish@example.com",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                const Text(
                  "+91 98765 43210",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Live Database Expense Statistics
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatColumn(
                    title: "Total Records",
                    value: expenseProvider.transactionCount.toString(),
                  ),
                  Container(height: 36, width: 1, color: Colors.grey.withOpacity(0.3)),
                  _StatColumn(
                    title: "Month Spend",
                    value: "₹${expenseProvider.monthTotal.toStringAsFixed(0)}",
                  ),
                  Container(height: 36, width: 1, color: Colors.grey.withOpacity(0.3)),
                  const _StatColumn(
                    title: "Status",
                    value: "Active",
                    valueColor: Color(0xFF00C897),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Settings Section
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text("Dark Mode"),
                  subtitle: const Text("Enable dark theme"),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: const Text("Manage Categories"),
                  subtitle: const Text("Add, edit and delete categories"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CategoryManagementScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text("Manage Ledgers"),
                  subtitle: const Text("Add, edit and delete ledgers"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LedgerManagementScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // College Viva Technical Architecture
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.school, color: Color(0xFF00C897)),
                  title: Text("Project Code"),
                  subtitle: Text("BCSP-064 (IGNOU BCA)"),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.storage, color: Color(0xFF00C897)),
                  title: Text("Database Architecture"),
                  subtitle: Text("MySQL 8.x (3NF Normalized) via XAMPP"),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.security, color: Color(0xFF00C897)),
                  title: Text("Application Tier"),
                  subtitle: Text("Node.js + Express REST API with JWT"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Logout Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4F6B).withOpacity(0.15),
              foregroundColor: const Color(0xFFFF4F6B),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFFFF4F6B), width: 1),
              ),
            ),
            onPressed: () => _handleLogout(context),
            icon: const Icon(Icons.logout),
            label: const Text(
              "Logout Session",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _StatColumn({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}