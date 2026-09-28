import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
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
// 1. LOADING SCREEN (15 Seconds)
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
    _startLoadingAndCheckLogin();
  }

  void _startLoadingAndCheckLogin() async {
    // 15 Second ka Timer (Tumhari requirement ke hisaab se)
    await Future.delayed(const Duration(seconds: 15));

    // Check karna ki user pehle login kar chuka hai ya nahi
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      // Agar pehle se login hai, toh seedha Home Screen
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else {
      // Naya user hai, toh Login Screen
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
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

// ==========================================
// 2. LOGIN SCREEN (Email & Guest)
// ==========================================
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // Login save karne ka function
  void _loginUser(BuildContext context, String loginType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true); // Permanent save kar diya
    await prefs.setString('loginType', loginType); // Guest ya Email save rakha

    // Login hone ke baad Home Screen bhej do
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'WELCOME TO CHAI & CHASE',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),
              
              // Email Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () => _loginUser(context, 'Email'),
                child: const Text('CONTINUE WITH EMAIL', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
              
              // Guest Button
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () => _loginUser(context, 'Guest'),
                child: const Text('PLAY AS GUEST'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. HOME SCREEN (Isme baad me hum 1111.mp4 lagayenge)
// ==========================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'HOME SCREEN\n(Yahan tumhara 1111.mp4 chalega)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
