 import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'auth_gate.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with WidgetsBindingObserver {
  final AuthService _auth = AuthService();

  Timer? _timer;
  bool isChecking = false;
  bool isSending = false;
  int resendSeconds = 0;

  static const Color blush = Color(0xFFFFF5F7);
  static const Color rose = Color(0xFFFAD7E0);
  static const Color deepRose = Color(0xFFE88AAE);
  static const Color berry = Color(0xFFB85C7A);
  static const Color plum = Color(0xFF6D435A);
  static const Color cream = Color(0xFFFFFBFC);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      checkVerificationStatus(showMessage: false);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  // Fires the moment the user returns to the app from their email/browser
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkVerificationStatus(showMessage: false);
    }
  }

  Future<void> checkVerificationStatus({bool showMessage = true}) async {
    if (isChecking) return;

    setState(() => isChecking = true);

    try {
      final verified = await _auth.reloadAndCheckEmailVerified();

      if (!mounted) return;

      if (verified) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthGate()),
          (route) => false,
        );
      } else if (showMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email not verified yet. Check your inbox or spam.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      if (showMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isChecking = false);
      }
    }
  }

  Future<void> resendEmail() async {
    if (resendSeconds > 0) return;

    setState(() {
      isSending = true;
      resendSeconds = 60;
    });

    _startResendCountdown();

    try {
      await _auth.sendVerificationEmail();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent. Check inbox or spam.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => resendSeconds = 0);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => isSending = false);
      }
    }
  }

  void _startResendCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || resendSeconds <= 0) {
        timer.cancel();
        return;
      }

      setState(() => resendSeconds--);
    });
  }

  Future<void> logout() async {
    await _auth.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = _auth.currentUser?.email ?? 'your email';

    return Scaffold(
      backgroundColor: blush,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cream,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 78,
                    width: 78,
                    decoration: BoxDecoration(
                      color: rose,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.mark_email_read_rounded,
                      color: plum,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Verify your email',
                    style: TextStyle(
                      color: plum,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We sent a link to',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    email,
                    style: const TextStyle(
                      color: plum,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap the link in your email to verify, then come back — Zuri will continue automatically.',
                    style: const TextStyle(
                      color: Colors.black87,
                      height: 1.5,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: isChecking
                        ? null
                        : () => checkVerificationStatus(showMessage: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: berry,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: isChecking
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.refresh_rounded),
                    label: Text(
                      isChecking ? 'Checking...' : 'I have verified my email',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed:
                        isSending || resendSeconds > 0 ? null : resendEmail,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: berry,
                      side: const BorderSide(color: berry),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.email_rounded),
                    label: Text(
                      resendSeconds > 0
                          ? 'Resend in ${resendSeconds}s'
                          : isSending
                              ? 'Sending...'
                              : 'Resend verification email',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: logout,
                    child: const Text(
                      'Use a different account',
                      style: TextStyle(color: deepRose),
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