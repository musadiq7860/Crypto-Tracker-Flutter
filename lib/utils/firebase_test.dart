import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Firebase Connection Test Utility
/// Use this class to test Firebase connectivity and services
class FirebaseConnectionTest {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Test Firebase Core Connection
  static Future<bool> testFirebaseCore() async {
    try {
      print('🔥 Testing Firebase Core connection...');
      
      // Check if Firebase is initialized
      if (Firebase.apps.isEmpty) {
        print('❌ Firebase not initialized');
        return false;
      }
      
      print('✅ Firebase Core is connected and initialized');
      print('📱 Firebase App Name: ${Firebase.app().name}');
      print('🆔 Firebase Project ID: ${Firebase.app().options.projectId}');
      
      return true;
    } catch (e) {
      print('❌ Firebase Core test failed: $e');
      return false;
    }
  }

  /// Test Firebase Authentication
  static Future<bool> testFirebaseAuth() async {
    try {
      print('🔐 Testing Firebase Authentication...');
      
      // Check current user
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        print('✅ User is currently signed in: ${currentUser.email}');
        print('🆔 User UID: ${currentUser.uid}');
        print('📧 Email verified: ${currentUser.emailVerified}');
      } else {
        print('ℹ️ No user currently signed in');
      }
      
      // Test auth state changes
      _auth.authStateChanges().listen((User? user) {
        if (user != null) {
          print('🔄 Auth state changed: User signed in (${user.email})');
        } else {
          print('🔄 Auth state changed: User signed out');
        }
      });
      
      print('✅ Firebase Authentication is working');
      return true;
    } catch (e) {
      print('❌ Firebase Auth test failed: $e');
      return false;
    }
  }

  /// Test Cloud Firestore
  static Future<bool> testFirestore() async {
    try {
      print('🗄️ Testing Cloud Firestore...');
      
      // Test connection by reading a simple document
      DocumentReference testDoc = _firestore.collection('test').doc('connection');
      
      // Try to write test data
      await testDoc.set({
        'timestamp': FieldValue.serverTimestamp(),
        'test': 'Firebase connection test',
        'status': 'connected'
      });
      
      print('✅ Successfully wrote to Firestore');
      
      // Try to read test data
      DocumentSnapshot snapshot = await testDoc.get();
      if (snapshot.exists) {
        print('✅ Successfully read from Firestore');
        print('📄 Test document data: ${snapshot.data()}');
      }
      
      // Clean up test document
      await testDoc.delete();
      print('🧹 Test document cleaned up');
      
      print('✅ Cloud Firestore is working perfectly');
      return true;
    } catch (e) {
      print('❌ Firestore test failed: $e');
      return false;
    }
  }

  /// Test User Collection Access
  static Future<bool> testUserCollection() async {
    try {
      print('👥 Testing Users collection...');
      
      // Check if users collection exists and is accessible
      QuerySnapshot usersSnapshot = await _firestore
          .collection('users')
          .limit(1)
          .get();
      
      print('✅ Users collection is accessible');
      print('📊 Number of users found: ${usersSnapshot.docs.length}');
      
      if (usersSnapshot.docs.isNotEmpty) {
        DocumentSnapshot firstUser = usersSnapshot.docs.first;
        print('👤 Sample user ID: ${firstUser.id}');
        Map<String, dynamic>? userData = firstUser.data() as Map<String, dynamic>?;
        if (userData != null) {
          print('📧 Sample user email: ${userData['email'] ?? 'N/A'}');
        }
      }
      
      return true;
    } catch (e) {
      print('❌ User collection test failed: $e');
      return false;
    }
  }

  /// Run Complete Firebase Test Suite
  static Future<Map<String, bool>> runCompleteTest() async {
    print('\n🚀 Starting Complete Firebase Connection Test...\n');
    
    Map<String, bool> results = {};
    
    // Test Firebase Core
    results['core'] = await testFirebaseCore();
    print('');
    
    // Test Firebase Auth
    results['auth'] = await testFirebaseAuth();
    print('');
    
    // Test Firestore
    results['firestore'] = await testFirestore();
    print('');
    
    // Test User Collection
    results['users'] = await testUserCollection();
    print('');
    
    // Print summary
    print('📊 FIREBASE CONNECTION TEST RESULTS:');
    print('=====================================');
    results.forEach((service, success) {
      String status = success ? '✅ PASS' : '❌ FAIL';
      print('$service: $status');
    });
    
    bool allPassed = results.values.every((result) => result);
    print('');
    if (allPassed) {
      print('🎉 ALL TESTS PASSED! Firebase is fully connected and working!');
    } else {
      print('⚠️ Some tests failed. Check the logs above for details.');
    }
    
    return results;
  }

  /// Quick Connection Check
  static Future<bool> quickConnectionCheck() async {
    try {
      // Quick test - just check if we can access Firestore
      await _firestore.collection('test').limit(1).get();
      print('✅ Firebase Quick Check: CONNECTED');
      return true;
    } catch (e) {
      print('❌ Firebase Quick Check: FAILED - $e');
      return false;
    }
  }

  /// Get Firebase Project Info
  static Map<String, String> getProjectInfo() {
    try {
      FirebaseOptions options = Firebase.app().options;
      return {
        'projectId': options.projectId,
        'appId': options.appId,
        'apiKey': options.apiKey.substring(0, 10) + '...', // Partial for security
        'authDomain': options.authDomain ?? 'N/A',
        'storageBucket': options.storageBucket ?? 'N/A',
      };
    } catch (e) {
      return {'error': 'Failed to get project info: $e'};
    }
  }
}
