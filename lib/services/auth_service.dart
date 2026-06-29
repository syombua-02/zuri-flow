import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = credential.user;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Sign up failed';
    } catch (_) {
      throw 'Something went wrong during sign up';
    }
  }

  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await credential.user?.reload();
      return _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Login failed';
    } catch (_) {
      throw 'Something went wrong during login';
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw 'No logged in user found';
      }

      await user.reload();
      final refreshedUser = _auth.currentUser;

      if (refreshedUser != null && !refreshedUser.emailVerified) {
        await refreshedUser.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Failed to send verification email';
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> reloadAndCheckEmailVerified() async {
    final user = _auth.currentUser;

    if (user == null) return false;

    await user.reload();
    final refreshedUser = _auth.currentUser;

    return refreshedUser?.emailVerified ?? false;
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // User cancelled the Google sign-in dialog
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Google sign-in failed';
    } catch (e) {
      throw 'Google sign-in failed. Please try again.';
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Failed to send password reset email';
    } catch (_) {
      throw 'Something went wrong while sending reset email';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}