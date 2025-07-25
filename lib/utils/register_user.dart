import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRegistration {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<bool> registerUser({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      print('🔥 Starting Firebase registration for: $email');
      
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      
      if (user != null) {
        print('✅ User created successfully: ${user.uid}');
        
        // Add user details to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'firstName': firstName ?? '',
          'lastName': lastName ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'favorites': [],
          'theme': 'light',
        });
        
        print('✅ User data saved to Firestore');
        
        // Send email verification
        await user.sendEmailVerification();
        print('📧 Verification email sent to: $email');
        
        return true;
      }
      
      return false;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case 'weak-password':
          print('💡 The password provided is too weak.');
          break;
        case 'email-already-in-use':
          print('💡 The account already exists for that email.');
          break;
        case 'invalid-email':
          print('💡 The email address is not valid.');
          break;
        default:
          print('💡 Error: ${e.message}');
      }
      return false;
    } catch (e) {
      print('❌ General Error: $e');
      return false;
    }
  }

  static Future<bool> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      print('🔑 Signing in user: $email');
      
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      
      if (user != null) {
        print('✅ User signed in successfully: ${user.uid}');
        return true;
      }
      
      return false;
    } on FirebaseAuthException catch (e) {
      print('❌ Sign In Error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      print('❌ General Error: $e');
      return false;
    }
  }

  static Future<void> signOutUser() async {
    try {
      await _auth.signOut();
      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Sign Out Error: $e');
    }
  }

  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  static bool isUserSignedIn() {
    return _auth.currentUser != null;
  }
}
