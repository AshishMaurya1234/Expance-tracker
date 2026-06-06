import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../services/auth_service.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController phoneController = TextEditingController();
  final AuthService authService = AuthService();

  late final AnimationController _animationController;

  bool isLoading = false;
  bool isPressed = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();

    if (phone.length != 10) {
      _showMessage("Please enter a valid 10 digit mobile number");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await authService.sendOtp(
        phoneNumber: "+91$phone",
        codeSent: (verificationId) {
          if (!mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpScreen(
                verificationId: verificationId,
                phoneNumber: "+91 $phone",
              ),
            ),
          );
        },
        onError: (e) {
          _showMessage(e.message ?? "Failed to send OTP");
        },
      );
    } catch (e) {
      _showMessage("Something went wrong. Please try again.");
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.cardElevated,
        content: Text(message),
      ),
    );
  }

  Animation<Offset> _slide(int index) {
    return Tween<Offset>(
      begin: const Offset(0, 0.22),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.08 * index,
          0.60 + (0.08 * index),
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  Animation<double> _fade(int index) {
    return CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.08 * index,
        0.65 + (0.08 * index),
        curve: Curves.easeOut,
      ),
    );
  }

  Widget _animatedItem({
    required int index,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: _fade(index),
      child: SlideTransition(
        position: _slide(index),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          const _AuthBackground(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 56),

                  _animatedItem(
                    index: 0,
                    child: Text(
                      "Hello Again 👋",
                      style: GoogleFonts.sora(
                        fontSize: 38,
                        height: 1.05,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  _animatedItem(
                    index: 1,
                    child: Text(
                      "Welcome back! Please enter your mobile number to continue.",
                      style: GoogleFonts.dmSans(
                        fontSize: 17,
                        height: 1.45,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 42),

                  _animatedItem(
                    index: 2,
                    child: _GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.cardElevated.withValues(alpha: 0.8),
                                  border: Border.all(
                                    color: AppTheme.border,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.phone_iphone,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Mobile Number",
                                      style: GoogleFonts.sora(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "We’ll send you a 6 digit OTP",
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          Container(
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppTheme.cardElevated.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppTheme.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  height: double.infinity,
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                        color: AppTheme.border,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Text(
                                        "🇮🇳",
                                        style: TextStyle(fontSize: 22),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "+91",
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: phoneController,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 10,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      counterText: "",
                                      hintText: "Enter mobile number",
                                      hintStyle: GoogleFonts.dmSans(
                                        fontSize: 17,
                                        color: AppTheme.textHint,
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  _animatedItem(
                    index: 3,
                    child: GestureDetector(
                      onTapDown: (_) {
                        setState(() {
                          isPressed = true;
                        });
                      },
                      onTapCancel: () {
                        setState(() {
                          isPressed = false;
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          isPressed = false;
                        });
                      },
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 120),
                        scale: isPressed ? 0.97 : 1,
                        child: _GradientButton(
                          text: "Send OTP",
                          icon: Icons.send_rounded,
                          isLoading: isLoading,
                          onPressed: isLoading ? null : sendOtp,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 42),

                  _animatedItem(
                    index: 4,
                    child: Center(
                      child: Text.rich(
                        TextSpan(
                          text: "By continuing, you agree to our ",
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppTheme.textHint,
                          ),
                          children: [
                            TextSpan(
                              text: "Terms",
                              style: GoogleFonts.dmSans(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const TextSpan(text: " & "),
                            TextSpan(
                              text: "Privacy Policy",
                              style: GoogleFonts.dmSans(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _GradientButton({
    required this.text,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.primary,
            AppTheme.gradientBlue,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.42),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: SizedBox(
            height: 62,
            width: double.infinity,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.6,
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: GoogleFonts.sora(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppTheme.cardSurface.withValues(alpha: 0.74),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.42),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.14),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _AuthBackground extends StatelessWidget {
  const _AuthBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppTheme.background),
        const Positioned(
          top: -90,
          left: -90,
          child: _Blob(
            size: 260,
            colors: [
              AppTheme.primary,
              Color(0xFF003B5F),
            ],
          ),
        ),
        const Positioned(
          top: 220,
          right: -120,
          child: _Blob(
            size: 260,
            colors: [
              AppTheme.gradientBlue,
              Color(0xFF061A55),
            ],
          ),
        ),
        const Positioned(
          bottom: -140,
          left: -120,
          child: _Blob(
            size: 300,
            colors: [
              Color(0xFF0047FF),
              Color(0xFF001122),
            ],
          ),
        ),
        const Positioned(
          bottom: -120,
          right: -90,
          child: _Blob(
            size: 300,
            colors: [
              AppTheme.primary,
              Color(0xFF001F2C),
            ],
          ),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _Blob({
    required this.size,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: colors),
        ),
      ),
    );
  }
}