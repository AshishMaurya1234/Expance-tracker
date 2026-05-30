import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController phoneController =
  TextEditingController();

  final AuthService authService = AuthService();

  bool isLoading = false;

  Future<void> sendOtp() async {
    setState(() {
      isLoading = true;
    });

    await authService.sendOtp(
      phoneNumber: "+91${phoneController.text.trim()}",

      codeSent: (verificationId) {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              verificationId: verificationId,
            ),
          ),
        );
      },

      onError: (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? "Error"),
          ),
        );
      },
    );

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height: 40),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,

              decoration: const InputDecoration(
                hintText: "Enter Mobile Number",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: isLoading ? null : sendOtp,

                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Send OTP"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}