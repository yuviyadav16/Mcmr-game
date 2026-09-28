import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart'; // Naya: Firebase Core Package
import 'firebase_options.dart'; // Naya: Tumhari API keys wali file
import 'home_screen.dart';

void main() async { // Naya: 'async' lagana zaroori hai kyunki hum backend se connect kar rahe hain
  // Ye line app ko initialize hone se pehle crash hone se rokti hai
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // Naya: Yahan tumhara Firebase Database game start hote hi initialize ho jayega
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
        scaffoldBackgroundColor: Colors.black, // Ekdum professional dark look
      ),
      home: const SplashScreen(), // Game start hote hi Loading screen aayegi
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
      // 'mounted' check sabse zaroori hai! Ye confirm karta hai ki app 
      // background me band nahi hui hai. Isse app C-R-A-S-H nahi hoti.
      if (mounted) {
        // Direct nayi Home Screen par bhej do (Bina login ke)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()), 
        );
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
                // Yahan tum apna Logo.png bhi laga sakte ho
                // Image.asset('assets/Image/Logo.png', width: 150),
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
                const CircularProgressIndicator(color: Colors.white), // Loading Spinner
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
                      // Tumhara Ticbull ka logo
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
