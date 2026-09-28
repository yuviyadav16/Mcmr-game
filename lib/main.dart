import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart'; // Website open karne ke liye
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
// SPLASH SCREEN (AAA Studio Design)
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
    
    // Background Video (2222.mp4)
    _videoController = VideoPlayerController.asset('assets/Video/2222.mp4')
      ..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.play();
        setState(() {});
      });

    // 0% to 100% Smooth Counter (15 Seconds)
    _progressTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      setState(() {
        if (progressPercent < 100) {
          progressPercent += 1;
        }
      });
    });

    // 15 Seconds ke baad Entry Modal Popup dikhana
    _navigationTimer = Timer(const Duration(seconds: 15), () {
      if (mounted) {
        _showEntryOptionsModal(context);
      }
    });
  }

  // Website kholne ka function (ticbull.in)
  void _openTicbullWebsite() async {
    final Uri url = Uri.parse('https://ticbull.in');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // Dual Entry Modal (Email Login vs Guest)
  void _showEntryOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.black.withOpacity(0.95),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        side: BorderSide(color: Colors.orangeAccent, width: 1),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "CHAI & CHASE",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                "Choose how you want to enter the game",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 30),

              // 1. CONTINUE WITH EMAIL (Cloud Sync)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.email_outlined),
                label: const Text("CONTINUE WITH EMAIL", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                },
              ),
              const SizedBox(height: 15),

              // 2. PLAY AS GUEST (Instant Entry)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.orangeAccent, width: 1.5),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.orangeAccent),
                label: const Text("PLAY AS GUEST", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
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
          // Background Video / Poster
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

          // Light Dark Overlay taaki text aur poster dono balanced dikhein
          Container(color: Colors.black.withOpacity(0.35)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // TOP: Stylish Game Title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, Colors.orangeAccent],
                    ).createShader(bounds),
                    child: const Text(
                      'CHAI & CHASE',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3.5,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // BOTTOM SECTION: Clean Progress & Circular Logo
                  Column(
                    children: [
                      // Percentage & Loading Status (Neeche shift kiya gaya hai)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Loading assets...',
                            style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1),
                          ),
                          Text(
                            '$progressPercent%',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orangeAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progressPercent / 100,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                        minHeight: 5,
                      ),
                      const SizedBox(height: 25),

                      // POWERED BY + CIRCULAR LOGO (Clickable to ticbull.in)
                      GestureDetector(
                        onTap: _openTicbullWebsite,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white24, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'POWERED BY',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 9,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Circular Logo
                              ClipOval(
                                child: Image.asset(
                                  'assets/Image/ticbull.jpg', 
                                  width: 22, 
                                  height: 22,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'TICBULL',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
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
