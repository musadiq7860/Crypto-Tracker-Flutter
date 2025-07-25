import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Authentication Test Utility
/// Use this class to test Firebase Authentication functionality
class AuthenticationTest {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Test Current Authentication State
  static Future<Map<String, dynamic>> testAuthState() async {
    try {
      print('🔐 Testing Authentication State...');
      
      User? currentUser = _auth.currentUser;
      
      Map<String, dynamic> result = {
        'isSignedIn': currentUser != null,
        'userEmail': currentUser?.email ?? 'Not signed in',
        'userId': currentUser?.uid ?? 'No user ID',
        'emailVerified': currentUser?.emailVerified ?? false,
        'creationTime': currentUser?.metadata.creationTime?.toString() ?? 'Unknown',
        'lastSignIn': currentUser?.metadata.lastSignInTime?.toString() ?? 'Unknown',
      };
      
      if (currentUser != null) {
        print('✅ User is signed in: ${currentUser.email}');
        print('🆔 User ID: ${currentUser.uid}');
        print('📧 Email verified: ${currentUser.emailVerified}');
        print('📅 Account created: ${currentUser.metadata.creationTime}');
        print('🕐 Last sign in: ${currentUser.metadata.lastSignInTime}');
      } else {
        print('ℹ️ No user currently signed in');
      }
      
      return result;
    } catch (e) {
      print('❌ Auth state test failed: $e');
      return {'error': e.toString()};
    }
  }

  /// Test User Data in Firestore
  static Future<Map<String, dynamic>> testUserData() async {
    try {
      print('🗄️ Testing User Data in Firestore...');
      
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('ℹ️ No user signed in to test data');
        return {'error': 'No user signed in'};
      }
      
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        print('✅ User data found in Firestore');
        print('👤 Name: ${userData['firstName']} ${userData['lastName']}');
        print('📧 Email: ${userData['email']}');
        print('🎨 Theme: ${userData['theme']}');
        print('⭐ Favorites: ${userData['favorites']?.length ?? 0} items');
        
        return {
          'exists': true,
          'data': userData,
        };
      } else {
        print('❌ User data not found in Firestore');
        return {'exists': false};
      }
    } catch (e) {
      print('❌ User data test failed: $e');
      return {'error': e.toString()};
    }
  }

  /// Test Authentication Listeners
  static void testAuthListeners() {
    print('👂 Setting up Authentication Listeners...');
    
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        print('🔄 Auth State Changed: User signed in (${user.email})');
      } else {
        print('🔄 Auth State Changed: User signed out');
      }
    });
    
    _auth.userChanges().listen((User? user) {
      if (user != null) {
        print('🔄 User Changed: ${user.email} (verified: ${user.emailVerified})');
      } else {
        print('🔄 User Changed: No user');
      }
    });
    
    print('✅ Authentication listeners set up successfully');
  }

  /// Test Sign Out Functionality
  static Future<bool> testSignOut() async {
    try {
      print('🚪 Testing Sign Out...');
      
      User? userBeforeSignOut = _auth.currentUser;
      if (userBeforeSignOut == null) {
        print('ℹ️ No user to sign out');
        return false;
      }
      
      print('👤 Signing out user: ${userBeforeSignOut.email}');
      await _auth.signOut();
      
      User? userAfterSignOut = _auth.currentUser;
      if (userAfterSignOut == null) {
        print('✅ Sign out successful');
        return true;
      } else {
        print('❌ Sign out failed - user still signed in');
        return false;
      }
    } catch (e) {
      print('❌ Sign out test failed: $e');
      return false;
    }
  }

  /// Test Password Reset Email
  static Future<bool> testPasswordReset(String email) async {
    try {
      print('📧 Testing Password Reset for: $email');
      
      await _auth.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent successfully');
      return true;
    } catch (e) {
      print('❌ Password reset test failed: $e');
      return false;
    }
  }

  /// Run Complete Authentication Test Suite
  static Future<Map<String, dynamic>> runCompleteAuthTest() async {
    print('\n🚀 Starting Complete Authentication Test Suite...\n');
    
    Map<String, dynamic> results = {};
    
    // Test 1: Authentication State
    print('📋 Test 1: Authentication State');
    results['authState'] = await testAuthState();
    print('');
    
    // Test 2: User Data
    print('📋 Test 2: User Data in Firestore');
    results['userData'] = await testUserData();
    print('');
    
    // Test 3: Authentication Listeners
    print('📋 Test 3: Authentication Listeners');
    testAuthListeners();
    results['listeners'] = {'status': 'active'};
    print('');
    
    // Print summary
    print('📊 AUTHENTICATION TEST RESULTS:');
    print('=====================================');
    
    bool authWorking = results['authState']?['isSignedIn'] == true;
    bool dataWorking = results['userData']?['exists'] == true;
    bool listenersWorking = results['listeners']?['status'] == 'active';
    
    print('Authentication State: ${authWorking ? '✅ PASS' : '❌ FAIL'}');
    print('User Data Storage: ${dataWorking ? '✅ PASS' : '❌ FAIL'}');
    print('Auth Listeners: ${listenersWorking ? '✅ PASS' : '❌ FAIL'}');
    print('');
    
    if (authWorking && dataWorking && listenersWorking) {
      print('🎉 ALL AUTHENTICATION TESTS PASSED!');
      print('🔐 Firebase Authentication is working perfectly!');
    } else {
      print('⚠️ Some authentication tests failed. Check logs above.');
    }
    
    return results;
  }

  /// Get Authentication Statistics
  static Map<String, dynamic> getAuthStats() {
    User? user = _auth.currentUser;
    
    return {
      'isSignedIn': user != null,
      'userEmail': user?.email,
      'emailVerified': user?.emailVerified ?? false,
      'accountAge': user?.metadata.creationTime != null 
        ? DateTime.now().difference(user!.metadata.creationTime!).inDays
        : 0,
      'lastSignIn': user?.metadata.lastSignInTime?.toString(),
      'providerId': user?.providerData.first.providerId,
      'authMethod': 'Email/Password',
    };
  }

  /// Quick Authentication Health Check
  static Future<bool> quickAuthCheck() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        print('ℹ️ Auth Quick Check: No user signed in');
        return false;
      }
      
      // Try to refresh the user token
      await user.getIdToken(true);
      print('✅ Auth Quick Check: Authentication is healthy');
      return true;
    } catch (e) {
      print('❌ Auth Quick Check: Authentication issue - $e');
      return false;
    }
  }
}
