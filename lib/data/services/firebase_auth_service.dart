import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Wraps [FirebaseAuth] to provide typed, clean methods for
/// email/password auth, Google Sign-In, and email link (passwordless) auth.
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Stream of auth state changes — use this to reactively
  /// know whether the user is logged in or out.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Currently signed-in user (null if none).
  User? get currentUser => _auth.currentUser;

  // ─── Email/Password Auth ───

  /// Sign in with email + password.
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Create a new account with email + password.
  Future<UserCredential> createAccount(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Send a password-reset email.
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Update the display name of the currently signed-in user.
  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
  }

  // ─── Google Sign-In ───

  /// Sign in with Google.
  /// Returns the [UserCredential] on success, or null if the user cancelled.
  Future<UserCredential?> signInWithGoogle() async {
    // Trigger the Google Sign-In flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // User cancelled

    // Obtain the auth details from the Google user
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a Firebase credential from the Google tokens
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google credential
    return await _auth.signInWithCredential(credential);
  }

  // ─── Email Link (Passwordless) Auth ───

  /// Send a sign-in link to the user's email.
  ///
  /// The user clicks the link in their email to sign in without a password.
  /// You must enable "Email link (passwordless sign-in)" in Firebase Console.
  Future<void> sendSignInLinkToEmail(String email) async {
    final actionCodeSettings = ActionCodeSettings(
      url: 'https://verd-800bd.firebaseapp.com/finishSignIn?email=$email',
      handleCodeInApp: true,
      androidPackageName: 'com.whitewalkers.verd',
      androidInstallApp: true,
      androidMinimumVersion: '21',
      iOSBundleId: 'com.whitewalkers.verd',
    );

    await _auth.sendSignInLinkToEmail(
      email: email.trim(),
      actionCodeSettings: actionCodeSettings,
    );
  }

  /// Check if a deep link is a sign-in email link.
  bool isSignInWithEmailLink(String link) {
    return _auth.isSignInWithEmailLink(link);
  }

  /// Complete sign-in with email link.
  Future<UserCredential> signInWithEmailLink({
    required String email,
    required String emailLink,
  }) async {
    return await _auth.signInWithEmailLink(
      email: email.trim(),
      emailLink: emailLink,
    );
  }

  // ─── Account Management ───

  /// Sign out the current user (also signs out of Google).
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Delete the current user's account.
  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }

  /// Translates a [FirebaseAuthException] code into a user-friendly message.
  static String friendlyErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in method.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
