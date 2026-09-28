import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Video & Audio Controllers
  late VideoPlayerController _videoController;
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _timerSoundPlayer = AudioPlayer();
  Timer? _soundTimer;

  @override
  void initState() {
    super.initState();
    _initVideo();
    _initAudio();
  }

  // 1. Permanent Video Background Setup
  void _initVideo() {
    _videoController = VideoPlayerController.asset('assets/Video/1111.mp4')
      ..initialize().then((_) {
        _videoController.setLooping(true); // Smooth loop
        _videoController.setVolume(0.0); // Video ka apna sound mute (taki MP3 baje)
        _videoController.play();
        setState(() {}); // Screen update karne ke liye
      });
  }

  // 2. Dual Audio Setup
  void _initAudio() async {
    // Main BGM (Continuous Loop)
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.play(AssetSource('audio/2308.mp3'));

    // 15-Second Timer Sound
    _soundTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      await _timerSoundPlayer.play(AssetSource('audio/2307.mp3'));
    });
  }

  // 3. The Play Button Logic (Atomic Audio Kill)
  void _onPlayPressed() {
    // 15-sec wala sound instantly band aur timer cancel
    _soundTimer?.cancel();
    _timerSoundPlayer.stop();
    
    // Yahan se hum 4-videos wale game scene me jayenge
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Starting Game... Timer sound stopped! BGM continuing.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    // App band hone par memory clean karne ke liye
    _videoController.dispose();
    _bgmPlayer.dispose();
    _timerSoundPlayer.dispose();
    _soundTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // LAYER 1: 1111.mp4 Video Background
          _videoController.value.isInitialized
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController.value.size.width,
                    height: _videoController.value.size.height,
                    child: VideoPlayer(_videoController),
                  ),
                )
              : const Center(child: CircularProgressIndicator(color: Colors.orange)),
          
          // Video ko thoda dark karne ke liye (taki text clear dikhe)
          Container(color: Colors.black.withOpacity(0.2)),

          // LAYER 2: UI Elements
          SafeArea(
            child: Column(
              children: [
                // TOP BAR: Coins & Diamonds
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCurrencyBadge('assets/Image/3333.png', '2,500'), // Yahan database ka score aayega
                      _buildCurrencyBadge('assets/Image/4444.png', '150'),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // CENTER: BIG PLAY BUTTON
                ElevatedButton(
                  onPressed: _onPlayPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 10,
                  ),
                  child: const Text(
                    'PLAY',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
                  ),
                ),
                const SizedBox(height: 40),
                
                // BOTTOM ROW: Shop, Events, Settings, Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildIconButton(Icons.store, 'Shop'),
                    _buildIconButton(Icons.event, 'Events'),
                    _buildIconButton(Icons.settings, 'Settings'),
                    _buildIconButton(Icons.person, 'Login'), 
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Custom Widget: Coins & Diamonds box banane ke liye
  Widget _buildCurrencyBadge(String assetPath, String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white30, width: 1),
      ),
      child: Row(
        children: [
          Image.asset(assetPath, width: 24, height: 24),
          const SizedBox(width: 8),
          Text(
            amount,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }

  // Custom Widget: Bottom buttons banane ke liye
  Widget _buildIconButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.black54,
          radius: 28,
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 5),
        Text(
          label, 
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
