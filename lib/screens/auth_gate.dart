 import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'login_screen.dart';
import 'email_verification_screen.dart';
import 'onboarding_screen.dart';
import 'main_shell.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  static const Color blush = Color(0xFFFFF5F7);
  static const Color berry = Color(0xFFB85C7A);

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return StreamBuilder<User?>(
      stream: auth.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: blush,
            body: Center(
              child: CircularProgressIndicator(color: berry),
            ),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const LoginScreen();
        }

        if (!user.emailVerified) {
          return const EmailVerificationScreen();
        }

        return const _ProfileGate();
      },
    );
  }
}

class _ProfileGate extends StatefulWidget {
  const _ProfileGate();

  @override
  State<_ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<_ProfileGate> {
  final FirestoreService _firestore = FirestoreService();

  static const Color blush = Color(0xFFFFF5F7);
  static const Color berry = Color(0xFFB85C7A);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _firestore.userProfileExists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: blush,
            body: Center(
              child: CircularProgressIndicator(color: berry),
            ),
          );
        }

        final profileExists = snapshot.data ?? false;

        if (profileExists) {
          return const MainShell();
        }

        return const OnboardingScreen();
      },
    );
  }
}