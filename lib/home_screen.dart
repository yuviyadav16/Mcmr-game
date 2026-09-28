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
  late AudioPlayer _audioPlayer;
  
  int coins = 0;
  int diamonds = 0;
  String userDisplay = "Guest User";

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // HD Background Video (1111.mp4) optimized
    _videoController = VideoPlayerController.asset('assets/Video/1111.mp4')
      ..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.play();
        setState(() {});
      });

    // Single stable audio player to prevent crashes
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  void _initAudio() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('audio/2308.mp3'));
    } catch (e) {
      print("Audio error: $e");
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
      coins = prefs.getInt('total_coins') ?? 15583;
      diamonds = prefs.getInt('total_diamonds') ?? 7;
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _audioPlayer.dispose();
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

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // TOP BAR: Coins & Diamonds (NO BOX - Clean Look)[span_5](start_span)[span_5](end_span)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildCleanStat('assets/Image/4444.png', diamonds.toString()),
                          const SizedBox(width: 15),
                          _buildCleanStat('assets/Image/3333.png', coins.toString()),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.person_outline, color: Colors.white, size: 28),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 28),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  // CENTER: Small Clean "Tap to Play" without heavy box[span_6](start_span)[span_6](end_span)
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Game Play navigation
                        },
                        child: const Text(
                          "Tap to Play",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            shadows: [
                              Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // BOTTOM NAVIGATION DOCK
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBottomNavButton(Icons.flag_outlined, "MISSIONS", () {}),
                      _buildBottomNavButton(Icons.person, "ME", () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                      }),
                      _buildBottomNavButton(Icons.shopping_bag_outlined, "SHOP", () {}),
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

  Widget _buildCleanStat(String imagePath, String value) {
    return Row(
      children: [
        Image.asset(imagePath, width: 22, height: 22),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }
}
