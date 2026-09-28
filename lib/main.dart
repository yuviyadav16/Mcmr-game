import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'video_player.dart'; // Make sure video_player package is imported
import 'firebase_options.dart';
import 'home_screen.dart';
import 'login_screen.dart';

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
// 1. SPLASH SCREEN: 2222.mp4 Video + 0 to 100% Progress
// ==========================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;
  int progressPercent = 0;
  late Timer _progressTimer;
  late Timer _navigationTimer;

  @override
  void initState() {
    super.initState();
    
    // 1. Background Loading Video (2222.mp4)
    _videoController = VideoPlayerController.asset('assets/Video/2222.mp4')
      ..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.play();
        setState(() {});
      });

    // 2. 0% se 100% Smooth Counter Animation (15 Seconds total)
    _progressTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      setState(() {
        if (progressPercent < 100) {
          progressPercent += 1;
        }
      });
    });

    // 3. 15 Seconds ke baad Login/Home Navigation
    _navigationTimer = Timer(const Duration(seconds: 15), () {
      if (mounted) {
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && currentUser.emailVerified) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
        }
      }
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _progressTimer.cancel();
    _navigationTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Video (2222.mp4)
          _videoController.value.isInitialized
              ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  ),
                )
              : const Center(child: CircularProgressIndicator(color: Colors.orange)),

          // Dark Overlay taaki text clear dikhe
          Container(color: Colors.black.withOpacity(0.5)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Title
                  const Column(
                    children: [
                      SizedBox(height: 20),
                      Text(
                        'CHAI & CHASE',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  // Center: 0% to 100% Loading Status
                  Column(
                    children: [
                      Text(
                        '$progressPercent%',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.orangeAccent,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Loading assets & initializing cloud...',
                        style: TextStyle(color: Colors.white70, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: LinearProgressIndicator(
                          value: progressPercent / 100,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),

                  // Bottom: Powered By Ticbull
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'POWERED BY',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/Image/ticbull.jpg', width: 24, height: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'TICBULL',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              color: Colors.white,
                            ),
                          ),
                        ],
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
