import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signInWithGoogle() async {
    final provider = GoogleAuthProvider();
    return _auth.signInWithPopup(provider);
  }

  Future<void> signOut() => _auth.signOut();

  User? get currentUser => _auth.currentUser;
}
