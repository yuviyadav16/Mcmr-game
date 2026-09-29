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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;
  
  late AudioPlayer _bgmPlayer; 
  late AudioPlayer _sfxPlayer; 
  Timer? _sfxTimer;
  
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;
  
  int coins = 0; 
  int diamonds = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initVideo();
    _initAudio();

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _blinkAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(_blinkController);
  }

  void _initVideo() {
    _videoController = VideoPlayerController.asset(
      'assets/Video/1111.mp4',
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true), 
    )..initialize().then((_) {
        if (mounted) {
          _videoController.setLooping(true);
          _videoController.setVolume(0.0); 
          _videoController.play();
          setState(() {});
        }
      }).catchError((error) {
        debugPrint("Video loading error: $error");
      });
  }

  Future<void> _initAudio() async {
    _bgmPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();

    try {
      await AudioPlayer.global.setAudioContext(
        AudioContextConfig(
          // duckAudio parameter hata diya gaya hai taaki error na aaye
          respectSilence: false,
          stayAwake: true,
        ).build(),
      );

      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.play(AssetSource('audio/2308.mp3'));

      _sfxTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
        if (mounted) {
          await _sfxPlayer.play(AssetSource('audio/2307.mp3'));
        }
      });
    } catch (e) {
      debugPrint("Audio setup error: $e");
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        coins = prefs.getInt('total_coins') ?? 0;
        diamonds = prefs.getInt('total_diamonds') ?? 0;
      });
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _sfxTimer?.cancel(); 
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildStat('assets/Image/4444.png', diamonds.toString()),
                          const SizedBox(width: 20),
                          _buildStat('assets/Image/3333.png', coins.toString()),
                        ],
                      ),
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
                  
                  const Spacer(), 

                  GestureDetector(
                    onTap: () {
                      debugPrint("Game Started!");
                    },
                    child: FadeTransition(
                      opacity: _blinkAnimation,
                      child: const Text(
                        "TAP TO PLAY",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16, 
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4.0, 
                          shadows: [
                            Shadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 3)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30), 

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

  Widget _buildStat(String imagePath, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(imagePath, width: 24, height: 24),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1)),
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white30, width: 1.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
