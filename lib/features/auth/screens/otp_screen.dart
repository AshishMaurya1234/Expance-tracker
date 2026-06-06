import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../dashboard/dashboard_screen.dart';
import '../services/auth_service.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  final AuthService authService = AuthService();

  late String verificationId;
  late final AnimationController _animationController;

  final List<TextEditingController> otpControllers =
  List.generate(6, (_) => TextEditingController());

  final List<FocusNode> focusNodes =
  List.generate(6, (_) => FocusNode());

  bool isLoading = false;
  bool isSuccessPulse = false;
  int remainingSeconds = 30;
  Timer? timer;

  String get otpCode =>
      otpControllers.map((controller) => controller.text).join();

  @override
  void initState() {
    super.initState();

    verificationId = widget.verificationId;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animationController.forward();

    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();

    for (final controller in otpControllers) {
      controller.dispose();
    }

    for (final node in focusNodes) {
      node.dispose();
    }

    _animationController.dispose();

    super.dispose();
  }

  void startTimer() {
    timer?.cancel();

    setState(() {
      remainingSeconds = 30;
    });

    timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (remainingSeconds <= 0) {
          timer.cancel();
          return;
        }

        setState(() {
          remainingSeconds--;
        });
      },
    );
  }

  Future<void> resendOtp() async {
    if (remainingSeconds > 0 || isLoading) return;

    setState(() {
      isLoading = true;
    });

    final phone = widget.phoneNumber.replaceAll(" ", "");

    await authService.sendOtp(
      phoneNumber: phone,
      codeSent: (newVerificationId) {
        verificationId = newVerificationId;
        startTimer();

        _showMessage("OTP sent again");
      },
      onError: (e) {
        _showMessage(e.message ?? "Failed to resend OTP");
      },
    );

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> verifyOtp() async {
    if (otpCode.length != 6) {
      _showMessage("Please enter complete 6 digit OTP");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final credential = await authService.verifyOtp(
        verificationId: verificationId,
        otp: otpCode,
      );

      final token = await credential.user?.getIdToken();

      if (token != null) {
        await StorageService.saveToken(token);
      }

      setState(() {
        isSuccessPulse = true;
      });

      await Future.delayed(const Duration(milliseconds: 650));

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        ),
            (route) => false,
      );
    } catch (e) {
      _showMessage("Invalid OTP. Please try again.");
    }

    if (mounted) {
      setState(() {
        isLoading = false;
        isSuccessPulse = false;
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

  void onOtpChanged(String value, int index) {
    if (value.length > 1) {
      otpControllers[index].text = value.substring(value.length - 1);
      otpControllers[index].selection = TextSelection.fromPosition(
        TextPosition(offset: otpControllers[index].text.length),
      );
    }

    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }

    if (otpCode.length == 6) {
      setState(() {
        isSuccessPulse = true;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            isSuccessPulse = false;
          });
        }
      });
    }

    setState(() {});
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
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),

                  const SizedBox(height: 40),

                  _animatedItem(
                    index: 0,
                    child: const Icon(
                      Icons.verified_user_outlined,
                      color: AppTheme.primary,
                      size: 48,
                    ),
                  ),

                  const SizedBox(height: 24),

                  _animatedItem(
                    index: 1,
                    child: Text(
                      "Enter OTP",
                      style: GoogleFonts.sora(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  _animatedItem(
                    index: 2,
                    child: Column(
                      children: [
                        Text(
                          "We’ve sent a verification code to",
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.phoneNumber,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  _animatedItem(
                    index: 3,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 250),
                      scale: isSuccessPulse ? 1.03 : 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return _OtpBox(
                            controller: otpControllers[index],
                            focusNode: focusNodes[index],
                            onChanged: (value) {
                              onOtpChanged(value, index);
                            },
                          );
                        }),
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  _animatedItem(
                    index: 4,
                    child: TextButton.icon(
                      onPressed: remainingSeconds == 0 ? resendOtp : null,
                      icon: Icon(
                        Icons.timer_outlined,
                        color: remainingSeconds == 0
                            ? AppTheme.primary
                            : AppTheme.accent,
                      ),
                      label: Text(
                        remainingSeconds == 0
                            ? "Resend OTP"
                            : "Resend in 00:${remainingSeconds.toString().padLeft(2, '0')}",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: remainingSeconds == 0
                              ? AppTheme.primary
                              : AppTheme.accent,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  _animatedItem(
                    index: 5,
                    child: _GlassCard(
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primary.withValues(alpha: 0.15),
                            ),
                            child: const Icon(
                              Icons.security,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              "Didn’t receive the code? Make sure your number is correct and check your SMS inbox.",
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                height: 1.45,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  _animatedItem(
                    index: 6,
                    child: _GradientButton(
                      text: "Verify & Continue",
                      icon: Icons.lock_open_rounded,
                      isLoading: isLoading,
                      onPressed: isLoading ? null : verifyOtp,
                    ),
                  ),

                  const SizedBox(height: 28),

                  _animatedItem(
                    index: 7,
                    child: TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.phone_forwarded_rounded,
                        color: AppTheme.primary,
                      ),
                      label: Text(
                        "Change Number",
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Your data is safe and encrypted",
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppTheme.textHint,
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

class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool isFocused = false;

  @override
  void initState() {
    super.initState();

    widget.focusNode.addListener(() {
      setState(() {
        isFocused = widget.focusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.controller.text.isNotEmpty;

    return AnimatedScale(
      duration: const Duration(milliseconds: 160),
      scale: isFocused || hasValue ? 1.06 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 48,
        height: 62,
        decoration: BoxDecoration(
          color: AppTheme.cardElevated.withValues(alpha: 0.76),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isFocused
                ? AppTheme.primary
                : AppTheme.border,
            width: isFocused ? 1.8 : 1.1,
          ),
          boxShadow: [
            if (isFocused)
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.35),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Center(
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
            decoration: const InputDecoration(
              counterText: "",
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            onChanged: widget.onChanged,
          ),
        ),
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
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.cardSurface.withValues(alpha: 0.74),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.35),
            ),
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
          top: 160,
          right: -120,
          child: _Blob(
            size: 250,
            colors: [
              AppTheme.gradientBlue,
              Color(0xFF061A55),
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