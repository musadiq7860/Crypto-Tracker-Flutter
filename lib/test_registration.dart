import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'utils/register_user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('🔥 Firebase initialized successfully');
    
    // Register your email here
    await registerMyEmail();
    
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }
}

Future<void> registerMyEmail() async {
  print('\n🚀 Starting email registration process...\n');
  
  // CHANGE THESE TO YOUR DETAILS
  String yourEmail = 'test@example.com';  // ← PUT YOUR EMAIL HERE
  String yourPassword = 'TestPassword123!';  // ← PUT YOUR PASSWORD HERE
  String yourFirstName = 'Test User';  // ← PUT YOUR NAME HERE
  
  print('📧 Email: $yourEmail');
  print('🔐 Password: [HIDDEN]');
  print('👤 Name: $yourFirstName');
  print('\n⏳ Registering user...\n');
  
  bool success = await UserRegistration.registerUser(
    email: yourEmail,
    password: yourPassword,
    firstName: yourFirstName,
  );
  
  if (success) {
    print('\n🎉 SUCCESS! Your email has been registered in Firebase!');
    print('✅ Email: $yourEmail');
    print('✅ Account created successfully');
    print('✅ User data saved to Firestore');
    print('📧 Verification email sent');
    print('\n🔑 You can now use these credentials to login to the app!');
    
    // Test sign in
    print('\n🧪 Testing sign in...');
    bool signInSuccess = await UserRegistration.signInUser(
      email: yourEmail,
      password: yourPassword,
    );
    
    if (signInSuccess) {
      print('✅ Sign in test successful!');
      var user = UserRegistration.getCurrentUser();
      if (user != null) {
        print('👤 User ID: ${user.uid}');
        print('📧 Email: ${user.email}');
        print('✅ Email verified: ${user.emailVerified}');
      }
    } else {
      print('❌ Sign in test failed');
    }
    
  } else {
    print('\n❌ FAILED! Could not register your email');
    print('💡 Please check the error messages above');
  }
}

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Registration Test',
      home: Scaffold(
        appBar: AppBar(title: Text('Firebase Test')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_circle, size: 100, color: Colors.orange),
              SizedBox(height: 20),
              Text(
                'Firebase Registration Test',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text('Check the console for registration results'),
            ],
          ),
        ),
      ),
    );
  }
}
