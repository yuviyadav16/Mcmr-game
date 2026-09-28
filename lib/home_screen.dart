import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VideoPlayerController _videoController;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    
    // 1. Background Video Load karna (1111.mp4)
    _videoController = VideoPlayerController.asset('assets/Video/1111.mp4')
      ..initialize().then((_) {
        _videoController.setLooping(true); // Video lagatar chalti rahegi
        _videoController.play();
        setState(() {});
      });

    // 2. Background Music Play karna (2308.mp3)
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.play(AssetSource('audio/2308.mp3'));
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
          // Background Video Overlay
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
              : Center(child: CircularProgressIndicator(color: Colors.orange)),

          // Video ko thoda dark karne ke liye taaki text clear dikhe
          Container(color: Colors.black.withOpacity(0.4)),

          // Main Game UI Elements
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Bar: Coins aur Diamonds
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Coins (3333.png)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amber, width: 1.5)
                        ),
                        child: Row(
                          children: [
                            Image.asset('assets/Image/3333.png', width: 24, height: 24),
                            SizedBox(width: 8),
                            Text("1,500", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      // Diamonds (4444.png)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.cyanAccent, width: 1.5)
                        ),
                        child: Row(
                          children: [
                            Image.asset('assets/Image/4444.png', width: 24, height: 24),
                            SizedBox(width: 8),
                            Text("50", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Center: Play Button
                GestureDetector(
                  onTap: () {
                    // Yahan character run karne ka logic aayega
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orangeAccent, Colors.deepOrange],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.orange.withOpacity(0.6), blurRadius: 15, spreadRadius: 3)
                      ],
                    ),
                    child: Text(
                      "TAP TO CHASE",
                      style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                  ),
                ),

                // Bottom: Publisher Branding
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
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
}
