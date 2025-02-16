import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'base/bottom_nav_bar.dart'; // Import Bottom Navigation Bar

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "AI Lecture Notes",
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: AuthWrapper(), // Direct users based on authentication
      routes: {
        "/login": (context) => LoginScreen(),
        "/signup": (context) => SignupScreen(),
        "/home": (context) => BottomNavBar(), // Navigate to BottomNavBar
      },
    );
  }
}

// ✅ Decide whether to show Login or BottomNavBar
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return BottomNavBar(); // Show Bottom Navigation Bar
        }
        return LoginScreen(); // Show Login Page
      },
    );
  }
}
