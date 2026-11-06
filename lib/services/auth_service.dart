import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authChanges => _auth.authStateChanges();

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user!.updateDisplayName(name);
    // Lưu hồ sơ người dùng vào Firestore
    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> logout() => _auth.signOut();

  /// Dịch mã lỗi Firebase sang tiếng Việt
  static String errorMessage(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Email này đã được đăng ký';
        case 'invalid-email':
          return 'Email không hợp lệ';
        case 'weak-password':
          return 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Sai email hoặc mật khẩu';
        case 'too-many-requests':
          return 'Thử quá nhiều lần, vui lòng đợi một lúc';
        case 'network-request-failed':
          return 'Lỗi kết nối mạng';
      }
      return e.message ?? 'Đã xảy ra lỗi';
    }
    return 'Đã xảy ra lỗi: $e';
  }
}
