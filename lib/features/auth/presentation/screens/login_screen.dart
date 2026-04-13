import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../tasks/presentation/screens/task_list_screen.dart';
import '../providers/auth_provider.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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
      backgroundColor:  Colors.white, //const Color(0xFFF5F6FA),
      body: SafeArea(
        top: true,

        child: Center(
          child: SingleChildScrollView(
            child: Container(
              //margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              // decoration: BoxDecoration(
              //   color: Colors.white,
              //   borderRadius: BorderRadius.circular(30),
              //   boxShadow: [
              //     BoxShadow(
              //       color: Colors.black.withOpacity(0.05),
              //       blurRadius: 25,
              //       offset: const Offset(0, 10),
              //     ),
              //   ],
              // ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Top Icon
                  Container(
                    height: 200,
                    width: 200,
                    // decoration: BoxDecoration(
                    //   color: const Color(0xFF6C63FF),
                    //   borderRadius: BorderRadius.circular(24),
                    // ),
                    child: SvgPicture.asset(
                      'assets/icons/check_icon.svg',
                      //fit: BoxFit.contain,

                    ),
                  ),

                  const SizedBox(height: 8),

                  /// Title
                  const Text(
                    "Welcome back!",
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

                  /// EMAIL FIELD
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

                  /// PASSWORD LABEL + FORGOT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "PASSWORD",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Forgot password?",
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// PASSWORD FIELD
                  CustomTextField(
                    controller: passwordController,
                    hintText: "Enter your password",
                    isPassword: true,
                  ),

                  const SizedBox(height: 26),

                  /// LOGIN BUTTON
                  CustomButton(
                    text: authState.isLoading ? "Loading..." : "Log in",
                    onPressed: authState.isLoading
                        ? null
                        : () {
                      ref.read(authProvider.notifier).login(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  /// Divider text
                  const Text(
                    "or log in with",
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

                  /// Bottom text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(fontSize: 12),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Get started!",
                          style: TextStyle(
                            color: Color(0xFF6C63FF),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  /// Error message
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