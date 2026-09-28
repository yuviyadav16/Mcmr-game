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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AudioPlayer _bgmPlayer;     // 2308.mp3 (Continuous)
  late AudioPlayer _intervalPlayer; // 2307.mp3 (Har 15 sec)
  
  // Animation Controller for "Tap to Play" pulsing effect
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Real Data Variables
  int coins = 0;
  int diamonds = 0;
  String userDisplay = "Guest User";

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // 1. HD Background Video (1111.mp4)
    _videoController = VideoPlayerController.asset('assets/Video/1111.mp4')
      ..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.play();
        setState(() {});
      });

    // 2. Dual Audio Management
    _initAudioSystem();

    // 3. Smooth Pulsing Animation for Play Button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  // Dual Audio & 15-Sec Interval Logic
  void _initAudioSystem() async {
    // Continuous BGM (2308.mp3)
    _bgmPlayer = AudioPlayer();
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.play(AssetSource('audio/2308.mp3'));

    // Interval Sound (2307.mp3) - Har 15 second par play hoga
    _intervalPlayer = AudioPlayer();
    Future.delayed(const Duration(seconds: 15), () {
      _playIntervalSoundLoop();
    });
  }

  void _playIntervalSoundLoop() async {
    if (!mounted) return;
    await _intervalPlayer.play(AssetSource('audio/2307.mp3'));
    Future.delayed(const Duration(seconds: 15), () {
      _playIntervalSoundLoop();
    });
  }

  // Real Data & Login Status Fetch
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Firebase se check karo ki user ka email logged-in hai ya nahi
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null && firebaseUser.email != null) {
      setState(() {
        userDisplay = firebaseUser.email!;
      });
    } else {
      // Fallback to local preference
      setState(() {
        userDisplay = prefs.getString('user_email') ?? "Guest User";
      });
    }

    setState(() {
      coins = prefs.getInt('total_coins') ?? 15583; // Default sample coins
      diamonds = prefs.getInt('total_diamonds') ?? 7; // Default sample diamonds
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _bgmPlayer.dispose();
    _intervalPlayer.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // Profile Popup (Email vs Guest details)
  void _showProfilePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.orangeAccent)),
        title: const Text("PLAYER IDENTITY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Logged in as:", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            const SizedBox(height: 5),
            Text(userDisplay, style: const TextStyle(color: Colors.orangeAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            const Text("Your game progress is synced securely with Ticbull Cloud.", style: TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CLOSE", style: TextStyle(color: Colors.white)),
          ),
          if (userDisplay == "Guest User")
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
              },
              child: const Text("LOGIN NOW", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. HD Background Video (1111.mp4)
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

          // Subtle Dark Overlay for professional contrast
          Container(color: Colors.black.withOpacity(0.3)),

          // 2. Main UI Layout (Subway Surfers Style)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // TOP BAR: Diamonds, Coins, Profile, Settings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Currencies
                      Row(
                        children: [
                          _buildStatBadge('assets/Image/4444.png', diamonds.toString(), Colors.cyanAccent),
                          const SizedBox(width: 8),
                          _buildStatBadge('assets/Image/3333.png', coins.toString(), Colors.amber),
                        ],
                      ),
                      // Top Action Buttons
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.person_outline, color: Colors.white, size: 28),
                            onPressed: () => _showProfilePopup(context),
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

                  // CENTER: Glowing "TAP TO PLAY" Button with Smooth Animation
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Navigate to actual Game Play Screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Launching Game Engine... 🎮")),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF9800), Color(0xFFE65100)],
                          ),
                          borderRadius: BorderRadius.circular(35),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.8),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Text(
                          "Tap to Play",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.5,
                            shadows: [
                              Shadow(color: Colors.black45, offset: Offset(2, 2), blurRadius: 4),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // BOTTOM NAVIGATION DOCK (Missions, Me, Shop, Events)
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

  Widget _buildStatBadge(String imagePath, String value, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Image.asset(imagePath, width: 20, height: 20),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 75,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
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
