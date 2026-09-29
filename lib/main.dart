import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;
  late AudioPlayer _splashAudio; // Naya audio player yuvi.mp3 ke liye
  int progressPercent = 0;
  Timer? _progressTimer;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _initVideo();
    _initAudio();
    _startLoadingAnimation();
  }

  void _initVideo() {
    _videoController = VideoPlayerController.asset('assets/Video/2222.mp4')
      ..initialize().then((_) {
        if (mounted) {
          _videoController.setLooping(true);
          _videoController.setVolume(0.0);
          _videoController.play();
          setState(() {});
        }
      }).catchError((error) {
        debugPrint("Splash Video Error: $error");
      });
  }

  // Yahan yuvi.mp3 chalega
  Future<void> _initAudio() async {
    _splashAudio = AudioPlayer();
    await _splashAudio.setReleaseMode(ReleaseMode.loop);
    await _splashAudio.play(AssetSource('audio/yuvi.mp3'));
  }

  void _startLoadingAnimation() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (mounted && progressPercent < 100) {
        setState(() {
          progressPercent += 1;
        });
      } else {
        timer.cancel();
      }
    });

    _navigationTimer = Timer(const Duration(seconds: 15), () {
      if (mounted) {
        _checkLoginState();
      }
    });
  }

  Future<void> _checkLoginState() async {
    User? user = FirebaseAuth.instance.currentUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isGuest = prefs.getBool('isGuest') ?? false;

    if (!mounted) return;

    if (user != null || isGuest) {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      _showEntryOptionsModal(context);
    }
  }

  Future<void> _openTicbullWebsite() async {
    final Uri url = Uri.parse('https://ticbull.in');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  void _showEntryOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.black.withOpacity(0.95),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        side: BorderSide(color: Colors.orangeAccent, width: 1.5),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 35.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "CHAI & CHASE",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2.5, color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Text(
                "Select your entry method",
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 35),
              
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                icon: const Icon(Icons.email_rounded, size: 22),
                label: const Text("CONTINUE WITH EMAIL", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                },
              ),
              const SizedBox(height: 20),
              
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.orangeAccent, width: 2),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.orangeAccent, size: 28),
                label: const Text("PLAY AS GUEST", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isGuest', true);

                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _navigationTimer?.cancel();
    _videoController.dispose();
    _splashAudio.dispose(); // Audio stop ho jayega jab screen change hogi
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
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

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE SHIFTED TO TOP LEFT WITH MODERN LOOK
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.only(left: 16),
                      decoration: const BoxDecoration(
                        border: Border(left: BorderSide(color: Colors.orangeAccent, width: 4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'CHAI & CHASE',
                            style: TextStyle(
                              fontSize: 32, 
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                              color: Colors.white,
                              shadows: [
                                Shadow(color: Colors.black87, blurRadius: 10, offset: Offset(2, 2)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "ENDLESS RUNNER",
                            style: TextStyle(
                              color: Colors.orangeAccent.shade200,
                              fontSize: 12,
                              letterSpacing: 6.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // BOTTOM SECTION (Loading Bar + Platform Link)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Loading assets...',
                            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1),
                          ),
                          Text(
                            '$progressPercent%',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.orangeAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: Colors.orangeAccent.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 2))
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progressPercent / 100,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 35),
                      InkWell(
                        onTap: _openTicbullWebsite,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white30, width: 1.5),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'POWERED BY',
                                style: TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 2.0, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(width: 12),
                              ClipOval(
                                child: Image.asset('assets/Image/ticbull.jpg', width: 24, height: 24, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'TICBULL',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 2.0, color: Colors.white),
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
