import 'package:flutter/material.dart';

import '../../core/services/storage_service.dart';
import '../auth/screens/login_screen.dart';
import '../auth/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final authService = AuthService();

    return Center(
      child: ElevatedButton(

        onPressed: () async {

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

        child: const Text("Logout"),
      ),
    );
  }
}