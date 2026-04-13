import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../tasks/presentation/screens/task_list_screen.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isEmailValid = false;

  @override
  void initState() {
    super.initState();

    emailController.addListener(() {
      final email = emailController.text.trim();

      setState(() {
        isEmailValid = _isValidEmail(email);
      });
    });
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );
    return regex.hasMatch(email);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      if (next.user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const TaskListScreen(),
          ),
              (route) => false,
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// SVG ICON (same as login)
                  Container(
                    height: 200,
                    width: 200,
                    child: SvgPicture.asset(
                      'assets/icons/check_icon.svg',
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// Title
                  const Text(
                    "Let's get started!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// EMAIL LABEL
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "EMAIL ADDRESS",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// EMAIL FIELD (with validation icon)
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF1F3F6),
                      hintText: "Enter your email",
                      suffixIcon: isEmailValid
                          ? const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// PASSWORD LABEL
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "PASSWORD",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// PASSWORD FIELD
                  CustomTextField(
                    controller: passwordController,
                    hintText: "Enter your password",
                    isPassword: true,
                  ),

                  const SizedBox(height: 26),

                  /// SIGNUP BUTTON
                  CustomButton(
                    text: authState.isLoading ? "Loading..." : "Sign up",
                    onPressed: authState.isLoading
                        ? null
                        : () {
                      ref.read(authProvider.notifier).signup(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  /// Divider
                  const Text(
                    "or sign up with",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// Social buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialCircle(
                        color: const Color(0xFF3b5998),
                        icon: Icons.facebook,
                      ),
                      const SizedBox(width: 16),
                      _socialCircle(
                        color: Colors.red,
                        icon: Icons.g_mobiledata,
                      ),
                      const SizedBox(width: 16),
                      _socialCircle(
                        color: Colors.black,
                        icon: Icons.apple,
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  /// Bottom navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(fontSize: 12),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Log in",
                          style: TextStyle(
                            color: Color(0xFF6C63FF),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  /// Error
                  if (authState.error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      authState.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialCircle({required Color color, required IconData icon}) {
    return Container(
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}