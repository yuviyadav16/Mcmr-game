import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VideoPlayerController _videoController;
  
  // Do alag audio players taaki aapas mein conflict na ho
  late AudioPlayer _bgmPlayer; // 2308.mp3 (Permanent Loop)
  late AudioPlayer _sfxPlayer; // 2307.mp3 (Every 15 sec)
  Timer? _sfxTimer;
  
  int coins = 0;
  int diamonds = 0;
  String userDisplay = "Guest User";

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initVideo();
    _initAudio();
  }

  void _initVideo() {
    // Video player ko safely initialize kiya gaya hai taaki crash na ho
    _videoController = VideoPlayerController.asset('assets/Video/1111.mp4')
      ..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.setVolume(0.0); // Video ka apna sound mute rakha hai
        _videoController.play();
        setState(() {});
      }).catchError((error) {
        print("Video loading error: $error");
      });
  }

  void _initAudio() async {
    _bgmPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();

    try {
      // 1. Permanent background music (2308.mp3)
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.play(AssetSource('audio/2308.mp3'));

      // 2. 15 second gap wala sound (2307.mp3)
      _sfxTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
        if (mounted) {
          await _sfxPlayer.play(AssetSource('audio/2307.mp3'));
        }
      });
    } catch (e) {
      print("Audio setup error: $e");
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    
    if (firebaseUser != null && firebaseUser.email != null) {
      setState(() {
        userDisplay = firebaseUser.email!;
      });
    } else {
      setState(() {
        userDisplay = prefs.getString('user_email') ?? "Guest User";
      });
    }

    setState(() {
      // Dummy values ko hata kar direct backend/prefs data liya hai
      coins = prefs.getInt('total_coins') ?? 15583;
      diamonds = prefs.getInt('total_diamonds') ?? 7;
    });
  }

  @override
  void dispose() {
    _sfxTimer?.cancel(); // Timer memory leak rokne ke liye
    _videoController.dispose();
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background HD Video Player
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

          // Foreground UI Elements
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // TOP BAR: Coins & Diamonds (Boxes removed, made Bigger)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildBigStat('assets/Image/4444.png', diamonds.toString()),
                          const SizedBox(width: 24),
                          _buildBigStat('assets/Image/3333.png', coins.toString()),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.person, color: Colors.white, size: 32),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings, color: Colors.white, size: 32),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  // CENTER: Professional "Tap to Play" Text
                  GestureDetector(
                    onTap: () {
                      // Yahan apne game logic ka navigation daalein
                      print("Game Started!");
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: const Text(
                        "TAP TO PLAY",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ),
                  ),

                  // BOTTOM NAVIGATION DOCK
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBottomNavButton(Icons.flag, "MISSIONS", () {}),
                      _buildBottomNavButton(Icons.person, "ME", () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                      }),
                      _buildBottomNavButton(Icons.shopping_bag, "SHOP", () {}),
                      _buildBottomNavButton(Icons.public, "EVENTS", () {}),
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

  // Box hata kar sidha Icon aur Text bada kar diya gaya hai
  Widget _buildBigStat(String imagePath, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(imagePath, width: 34, height: 34), // Icon size bada kiya
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22, // Font size bada kiya
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(color: Colors.black, blurRadius: 6, offset: Offset(1, 1)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 75,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white30, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }
}
