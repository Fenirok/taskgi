import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../../../tasks/presentation/screens/task_list_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));

    final user = ref.read(authStateChangesProvider).value;

    if (!mounted) return;

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const TaskListScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }


  Future<void> _handleNavigation() async {
    final authState = ref.read(authStateChangesProvider.future);

    /// Minimum splash duration
    await Future.delayed(const Duration(seconds: 5));

    final user = await authState;

    if (!mounted || _navigated) return;

    _navigated = true;

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const TaskListScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const _SplashUI();
  }
}

class _SplashUI extends StatelessWidget {
  const _SplashUI();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Stack(
        children: [


          Align(
            alignment: AlignmentGeometry.center,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 34,
              ),
              // decoration: BoxDecoration(
              //   color: Colors.white,
              //   borderRadius: BorderRadius.circular(28),
              //   boxShadow: [
              //     BoxShadow(
              //       color: Colors.black.withOpacity(0.05),
              //       blurRadius: 20,
              //       offset: const Offset(0, 10),
              //     ),
              //   ],
              // ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.only(left: 30),
                    child: Container(
                      height: 200,
                      width: 200,
                      child: SvgPicture.asset(
                        'assets/icons/check_icon.svg',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Get things done.",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Just a click away from\nplanning your tasks.",
                    style: TextStyle(
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _dot(false),
                      _dot(false),
                      _dot(true),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: -120,
            right: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: const BoxDecoration(
                color: Color(0xFF6C63FF),
                shape: BoxShape.circle,
              ),

            ),
          ),

          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(size: 150, Icons.arrow_forward, color: Colors.white,),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      height: 6,
      width: 6,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF6C63FF) : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
    );
  }
}