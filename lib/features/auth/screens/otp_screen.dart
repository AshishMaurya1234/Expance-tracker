import 'package:flutter/material.dart';

import '../../../core/services/storage_service.dart';
import '../../dashboard/dashboard_screen.dart';
import '../services/auth_service.dart';

class OtpScreen extends StatefulWidget {

  final String verificationId;

  const OtpScreen({
    super.key,
    required this.verificationId,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {

  final TextEditingController otpController =
  TextEditingController();

  final AuthService authService = AuthService();

  bool isLoading = false;

  Future<void> verifyOtp() async {

    setState(() {
      isLoading = true;
    });

    try {

      final credential = await authService.verifyOtp(
        verificationId: widget.verificationId,
        otp: otpController.text.trim(),
      );

      final token =
      await credential.user?.getIdToken();

      if (token != null) {
        await StorageService.saveToken(token);
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        ),
            (route) => false,
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify OTP"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height: 40),

            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                hintText: "Enter OTP",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: isLoading ? null : verifyOtp,

                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Verify OTP"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}