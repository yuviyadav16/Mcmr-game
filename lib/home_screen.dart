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
  
  late AudioPlayer _bgmPlayer;
  late AudioPlayer _sfxPlayer;
  Timer? _sfxTimer;
  
  // Fake data hataya, default 0 rakha hai
  int coins = 0;
  int diamonds = 0;
  String userDisplay = "Guest User";

  @override
  void initState() {
    super.initState();
    _setupAudioContext(); // Audio mix karne ka naya function
    _loadUserData();
    _initVideo();
    _initAudio();
  }

  // YAHAN FIX HAI: Video aur Audio dono ek sath chalenge bina ruke
  Future<void> _setupAudioContext() async {
    final audioContext = AudioContext(
      android: const AudioContextAndroid(
        isSpeakerphoneOn: true,
        audioMode: AndroidAudioMode.normal,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.none, // Isse video nahi rukega
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.ambient,
        options: const [AVAudioSessionOptions.mixWithOthers], // iOS ke liye mix
      ),
    );
    await AudioPlayer.global.setAudioContext(audioContext);
  }

  void _initVideo() {
    _videoController = VideoPlayerController.asset('assets/Video/1111.mp4')
      ..initialize().then((_) {
        if (mounted) {
          _videoController.setLooping(true);
          _videoController.setVolume(0.0); // Video muted rahega
          _videoController.play();
          setState(() {});
        }
      }).catchError((error) {
        debugPrint("Video Error: $error");
      });
  }

  void _initAudio() async {
    _bgmPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();

    try {
      // 2308.mp3 - Continuous Background Music
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.play(AssetSource('audio/2308.mp3'));

      // 2307.mp3 - Har 15 second baad play hoga
      _sfxTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
        if (mounted) {
          // Play karega bina BGM ya Video ko roke
          await _sfxPlayer.play(AssetSource('audio/2307.mp3'));
        }
      });
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    
    if (firebaseUser != null && firebaseUser.email != null) {
      userDisplay = firebaseUser.email!;
    } else {
      userDisplay = prefs.getString('user_email') ?? "Guest User";
    }

    if (mounted) {
      setState(() {
        // SharedPreferences se real value aayegi, nahi toh 0 dikhega
        coins = prefs.getInt('total_coins') ?? 0;
        diamonds = prefs.getInt('total_diamonds') ?? 0;
      });
    }
  }

  @override
  void dispose() {
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

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // TOP BAR: Coins & Diamonds
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildCleanStat('assets/Image/4444.png', diamonds.toString()),
                          const SizedBox(width: 24),
                          _buildCleanStat('assets/Image/3333.png', coins.toString()),
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

                  // BOTTOM AREA: Tap to Play & Menu Navigation
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // TAP TO PLAY - Box hata diya aur size chota kar diya gaya hai
                      GestureDetector(
                        onTap: () {
                          debugPrint("Game Started!");
                        },
                        child: const Text(
                          "TAP TO PLAY",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16, // Size chota kiya
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3.0,
                            shadows: [
                              Shadow(color: Colors.black87, blurRadius: 10, offset: Offset(0, 2)),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 25), // Text aur bottom menu ke beech ka gap

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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(imagePath, width: 26, height: 26),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white24, width: 1.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 22),
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
