import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:firebase_auth/package:firebase_auth.dart'; // Naya: User ka login status check karne ke liye
import 'firebase_options.dart'; 
import 'home_screen.dart';
import 'login_screen.dart'; // Naya: Tumhari VIP Login Screen link ho gayi

void main() async { 
  WidgetsFlutterBinding.ensureInitialized(); 
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ChaiAndChaseApp());
}

class ChaiAndChaseApp extends StatelessWidget {
  const ChaiAndChaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chai & Chase',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black, 
      ),
      home: const SplashScreen(), 
    );
  }
}

// ==========================================
// 1. LOADING SCREEN (15 Seconds - Crash Proof)
// ==========================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    // 15 Second ka exact timer
    Timer(const Duration(seconds: 15), () {
      if (mounted) {
        // Z++ SECURITY CHECK: Dekho user pehle se login hai kya?
        User? currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null && currentUser.emailVerified) {
          // Agar verified user already login hai, toh direct Home Screen (Game)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()), 
          );
        } else {
          // Agar naya user hai ya email verify nahi kiya, toh Login Screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()), 
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Center: Game Name & Loading Animation
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'CHAI & CHASE',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                const CircularProgressIndicator(color: Colors.white), 
                const SizedBox(height: 10),
                const Text('Loading assets...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          
          // Bottom: Powered By Ticbull
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'POWERED BY',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/Image/ticbull.jpg', 
                        width: 30, 
                        height: 30,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'TICBULL',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
