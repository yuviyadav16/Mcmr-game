import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  
  // Real Data Variables
  int coins = 0;
  int diamonds = 0;

  @override
  void initState() {
    super.initState();
    _loadRealData(); // Game start hote hi real coins load honge

    _videoController = VideoPlayerController.asset('assets/Video/1111.mp4')
      ..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.play();
        setState(() {});
      });

    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.play(AssetSource('audio/2308.mp3'));
  }

  // Real Data Fetch Karne ka Logic
  Future<void> _loadRealData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Agar pehli baar game khula hai, toh 0 aayega
      coins = prefs.getInt('total_coins') ?? 0; 
      diamonds = prefs.getInt('total_diamonds') ?? 0;
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
          // Background Video
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

          Container(color: Colors.black.withOpacity(0.4)),

          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // TOP BAR: Coins, Diamonds, Profile, Settings
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Coins & Diamonds (Real Data)
                      Row(
                        children: [
                          _buildStatBadge('assets/Image/3333.png', coins.toString(), Colors.amber),
                          const SizedBox(width: 10),
                          _buildStatBadge('assets/Image/4444.png', diamonds.toString(), Colors.cyanAccent),
                        ],
                      ),
                      // Buttons
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.person, color: Colors.white, size: 28),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // PLAY BUTTON
                GestureDetector(
                  onTap: () {
                    // Start Game Logic
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Colors.orangeAccent, Colors.deepOrange]),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.orange.withOpacity(0.6), blurRadius: 15, spreadRadius: 3)
                      ],
                    ),
                    child: const Text(
                      "TAP TO CHASE",
                      style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    "LOGICAL MIRCHI GAMING",
                    style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 3, fontWeight: FontWeight.w500),
                  ),
                )
              ],
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
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5)
      ),
      child: Row(
        children: [
          Image.asset(imagePath, width: 20, height: 20),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
