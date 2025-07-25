import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:crytoapp/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../pages/Login.dart';
import '../pages/Settings.dart';
import '../pages/About.dart';
import '../utils/firebase_test.dart';
import '../utils/auth_test.dart';

class Navbar extends StatefulWidget {
  Navbar({Key? key}) : super(key: key);

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
   User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          setState(() {
            loggedInUser = UserModel.fromMap(doc.data());
            isLoading = false;
          });
        } else {
          // If no user data in Firestore, create basic user info
          setState(() {
            loggedInUser = UserModel(
              uid: user!.uid,
              email: user!.email,
              firstName: user!.displayName?.split(' ').first ?? 'User',
              secondName: user!.displayName?.split(' ').skip(1).join(' ') ?? '',
            );
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          loggedInUser = UserModel(
            uid: user!.uid,
            email: user!.email ?? 'No Email',
            firstName: 'User',
            secondName: '',
          );
          isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
     ThemeProvider themeProvider =
        Provider.of<ThemeProvider>(context, listen: false);
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            // Beautiful Header
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Profile Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.account_circle_rounded,
                      size: 60,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // User Name
                  if (isLoading)
                    const CircularProgressIndicator(color: Colors.white)
                  else
                    Text(
                      "${loggedInUser.firstName ?? 'User'} ${loggedInUser.secondName ?? ''}".trim().toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 8),
                  // User Email
                  if (!isLoading)
                    Text(
                      loggedInUser.email ?? 'No Email',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // App Logo and Theme Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 40,
                    child: Image.asset(
                      "assets/images/logo.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      onPressed: () {
                        themeProvider.toggleTheme();
                      },
                      icon: Icon(
                        themeProvider.themeMode == ThemeMode.light
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Menu Items
            _buildMenuItem(
              context,
              icon: Icons.settings_rounded,
              title: 'Settings',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),

            _buildMenuItem(
              context,
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              onTap: () {
                Navigator.of(context).pop();
              },
            ),

            _buildMenuItem(
              context,
              icon: Icons.info_outline_rounded,
              title: 'About',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
              },
            ),

            _buildMenuItem(
              context,
              icon: Icons.cloud_done_rounded,
              title: 'Test Firebase Connection',
              onTap: () {
                _testFirebaseConnection(context);
              },
            ),

            _buildMenuItem(
              context,
              icon: Icons.security_rounded,
              title: 'Test Authentication',
              onTap: () {
                _testAuthentication(context);
              },
            ),

            const SizedBox(height: 20),

            // Logout Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  logout(context);
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Log Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Crypto Tracker v1.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Test Firebase Connection and Show Results
  void _testFirebaseConnection(BuildContext context) async {
    Navigator.of(context).pop(); // Close drawer

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Testing Firebase Connection...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait while we verify all services',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );

    // Run Firebase tests
    try {
      Map<String, bool> results = await FirebaseConnectionTest.runCompleteTest();
      Map<String, String> projectInfo = FirebaseConnectionTest.getProjectInfo();

      // Check if widget is still mounted before using context
      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Show results dialog
      if (mounted) {
        showDialog(
          context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange,
                        Colors.orange.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.cloud_done_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Firebase Connection Test',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Project: ${projectInfo['projectId'] ?? 'Unknown'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),

                // Test Results
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildTestResult('Firebase Core', results['core'] ?? false),
                        _buildTestResult('Authentication', results['auth'] ?? false),
                        _buildTestResult('Cloud Firestore', results['firestore'] ?? false),
                        _buildTestResult('Users Collection', results['users'] ?? false),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Overall Status
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: results.values.every((result) => result)
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        results.values.every((result) => result)
                          ? Icons.check_circle_rounded
                          : Icons.warning_rounded,
                        color: results.values.every((result) => result)
                          ? Colors.green
                          : Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          results.values.every((result) => result)
                            ? 'All Firebase services are working perfectly!'
                            : 'Some services may need attention. Check logs for details.',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: results.values.every((result) => result)
                              ? Colors.green
                              : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
      }
    } catch (e) {
      // Handle errors
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Firebase test failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildTestResult(String testName, bool passed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: passed
          ? Colors.green.withValues(alpha: 0.1)
          : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: passed
            ? Colors.green.withValues(alpha: 0.3)
            : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.error,
            color: passed ? Colors.green : Colors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              testName,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: passed ? Colors.green : Colors.red,
              ),
            ),
          ),
          Text(
            passed ? 'PASS' : 'FAIL',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: passed ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Test Authentication and Show Results
  void _testAuthentication(BuildContext context) async {
    Navigator.of(context).pop(); // Close drawer

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Testing Authentication...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Verifying all authentication features',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );

    // Run Authentication tests
    try {
      Map<String, dynamic> results = await AuthenticationTest.runCompleteAuthTest();
      Map<String, dynamic> authStats = AuthenticationTest.getAuthStats();

      // Check if widget is still mounted before using context
      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Show results dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxHeight: 600),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue,
                            Colors.blue.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.security_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Authentication Test Results',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      authStats['isSignedIn'] == true
                        ? 'User: ${authStats['userEmail']}'
                        : 'No user signed in',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Test Results
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildAuthTestResult(
                              'Authentication State',
                              results['authState']?['isSignedIn'] == true
                            ),
                            _buildAuthTestResult(
                              'User Data Storage',
                              results['userData']?['exists'] == true
                            ),
                            _buildAuthTestResult(
                              'Auth Listeners',
                              results['listeners']?['status'] == 'active'
                            ),
                            _buildAuthTestResult(
                              'Email Verification',
                              authStats['emailVerified'] == true
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Overall Status
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: authStats['isSignedIn'] == true
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            authStats['isSignedIn'] == true
                              ? Icons.check_circle_rounded
                              : Icons.warning_rounded,
                            color: authStats['isSignedIn'] == true
                              ? Colors.green
                              : Colors.orange,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              authStats['isSignedIn'] == true
                                ? 'Authentication is working perfectly!'
                                : 'Please sign in to test all features.',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: authStats['isSignedIn'] == true
                                  ? Colors.green
                                  : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Close Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      // Handle errors
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication test failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildAuthTestResult(String testName, bool passed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: passed
          ? Colors.green.withValues(alpha: 0.1)
          : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: passed
            ? Colors.green.withValues(alpha: 0.3)
            : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.error,
            color: passed ? Colors.green : Colors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              testName,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: passed ? Colors.green : Colors.red,
              ),
            ),
          ),
          Text(
            passed ? 'PASS' : 'FAIL',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: passed ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }
