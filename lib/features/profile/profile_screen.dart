import 'package:flutter/material.dart';

import '../../core/services/storage_service.dart';
import '../auth/screens/login_screen.dart';
import '../auth/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../../core/providers/theme_provider.dart';
import '../categories/screens/category_management_screen.dart';
import '../ledgers/screens/ledger_management_screen.dart';

class ProfileScreen extends StatelessWidget {

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final authService = AuthService();
    final themeProvider = context.watch<ThemeProvider>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [

        Card(
          child: SwitchListTile(
            title: const Text("Dark Mode"),
            subtitle: const Text(
              "Enable dark theme",
            ),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),
        ),

        const SizedBox(height: 12),

        Card(
          child: ListTile(
            leading: const Icon(Icons.category),
            title: const Text("Manage Categories"),
            subtitle: const Text(
              "Add, edit and delete categories",
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const CategoryManagementScreen(),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        Card(
          child: ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text("Manage Ledgers"),
            subtitle: const Text(
              "Add, edit and delete ledgers",
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const LedgerManagementScreen(),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        Card(
          child: ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () async {
              await authService.logout();

              await StorageService.clearToken();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                    (route) => false,
              );
            },
          ),
        ),
      ],
    );
  }
}