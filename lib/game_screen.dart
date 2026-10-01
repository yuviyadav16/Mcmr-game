import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:math';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // --- Video Map Sequence ---
  late VideoPlayerController _bgController1;
  late VideoPlayerController _bgController2;
  bool _useController1 = true;
  int _currentVideoIndex = 1;
  Timer? _videoTimer;

  // --- Audio System ---
  late AudioPlayer _bgmPlayer;
  late AudioPlayer _sfxPlayer; // Jump, slide, crash ke liye

  // --- Player Physics & Lanes ---
  int _currentLane = 0; // -1 (Left), 0 (Center), 1 (Right)
  double _characterY = 0; // Jump height (0 is ground)
  double _gravity = 2.5; 
  double _jumpVelocity = -18.0;
  double _currentVelocity = 0;
  bool _isJumping = false;
  String _playerState = 'run'; // 'run', 'jump', 'slide', 'stumble'
  
  // Character asset selection (Modi or Meloni)
  String _selectedCharacter = 'modi'; // change to 'meloni' dynamically later

  // --- Game Engine Timers ---
  Timer? _physicsTimer;
  Timer? _gameTimer;
  int _score = 0;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initAudio();
    _initVideoMapSequence();
    _startPhysicsEngine();
    _startGameLoop();
  }

  void _initAudio() async {
    _bgmPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.play(AssetSource('audio/yuvi.mp3')); // Background BGM
  }

  void _playSound(String type) async {
    if (type == 'jump') await _sfxPlayer.play(AssetSource('audio/sfx/player/modi_jump.mp3'));
    if (type == 'slide') await _sfxPlayer.play(AssetSource('audio/sfx/player/slide.mp3')); // add slide sound if any
  }

  // --- Video Sequence Logic (1 -> 2 -> 3 -> 4 -> 5 -> 1) ---
  void _initVideoMapSequence() {
    _bgController1 = VideoPlayerController.asset('assets/gb/gb1.mp4')
      ..initialize().then((_) {
        _bgController1.play();
        _bgController1.setLooping(true); 
        setState(() {});
        _scheduleNextVideo(1);
      });
    _bgController2 = VideoPlayerController.asset('assets/gb/gb2.mp4')..initialize();
  }

  void _scheduleNextVideo(int index) {
    _videoTimer?.cancel();
    int durationInSeconds = (index == 1 || index == 4 || index == 5) ? 180 : 
                            (_useController1 ? _bgController1.value.duration.inSeconds : _bgController2.value.duration.inSeconds);
    
    _videoTimer = Timer(Duration(seconds: durationInSeconds), () {
      _switchToNextMap(index + 1 > 5 ? 1 : index + 1);
    });
  }

  void _switchToNextMap(int nextIndex) async {
    _currentVideoIndex = nextIndex;
    String nextVideoPath = 'assets/gb/gb$nextIndex.mp4';
    
    if (_useController1) {
      _bgController2 = VideoPlayerController.asset(nextVideoPath);
      await _bgController2.initialize();
      _bgController2.play();
      if (nextIndex == 1 || nextIndex == 4 || nextIndex == 5) _bgController2.setLooping(true);
      setState(() { _useController1 = false; });
      _bgController1.pause();
    } else {
      _bgController1 = VideoPlayerController.asset(nextVideoPath);
      await _bgController1.initialize();
      _bgController1.play();
      if (nextIndex == 1 || nextIndex == 4 || nextIndex == 5) _bgController1.setLooping(true);
      setState(() { _useController1 = true; });
      _bgController2.pause();
    }
    _scheduleNextVideo(nextIndex);
  }

  // --- Physics & Gravity Engine ---
  void _startPhysicsEngine() {
    _physicsTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_isJumping || _characterY > 0) {
        _currentVelocity += _gravity;
        _characterY -= _currentVelocity;

        if (_characterY <= 0) { // Hit Ground
          _characterY = 0;
          _isJumping = false;
          _currentVelocity = 0;
          if (_playerState == 'jump') _playerState = 'run';
        }
        setState(() {});
      }
    });
  }

  void _startGameLoop() {
    _gameTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          _score += 1;
        });
      }
    });
    
    // Separate timer for seconds
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      _elapsedSeconds++;
      
      // TRIGGER ENEMIES AFTER 4 MINUTES (240 SECONDS)
      if (_elapsedSeconds > 240) {
        // We will call _spawnEnemy() here later
      }
    });
  }

  // --- 3-Lane Swipe Controls ---
  void _onSwipeUpdate(DragUpdateDetails details) {
    // Horizontal Swipes (Left/Right)
    if (details.delta.dx > 10) {
      // Swipe Right
      if (_currentLane < 1) {
        setState(() { _currentLane += 1; });
      }
    } else if (details.delta.dx < -10) {
      // Swipe Left
      if (_currentLane > -1) {
        setState(() { _currentLane -= 1; });
      }
    }
  }

  void _onSwipeEnd(DragEndDetails details) {
    // Vertical Swipes (Up/Down)
    if (details.primaryVelocity! < -300 && !_isJumping) {
      // Jump
      _isJumping = true;
      _currentVelocity = _jumpVelocity;
      setState(() { _playerState = 'jump'; });
      _playSound('jump');
    } else if (details.primaryVelocity! > 300) {
      // Slide
      if (!_isJumping) {
        setState(() { _playerState = 'slide'; });
        _playSound('slide');
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted && _playerState == 'slide') setState(() { _playerState = 'run'; });
        });
      } else {
        // Fast Fall
        _currentVelocity += 15.0; 
      }
    }
  }

  @override
  void dispose() {
    _videoTimer?.cancel();
    _physicsTimer?.cancel();
    _gameTimer?.cancel();
    _bgController1.dispose();
    _bgController2.dispose();
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    VideoPlayerController activeBg = _useController1 ? _bgController1 : _bgController2;

    // Map -1, 0, 1 to Screen Alignment
    Alignment playerAlignment = Alignment.bottomCenter;
    if (_currentLane == -1) playerAlignment = const Alignment(-0.6, 1.0); // Left Lane
    if (_currentLane == 1) playerAlignment = const Alignment(0.6, 1.0);  // Right Lane

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onHorizontalDragUpdate: _onSwipeUpdate,
        onVerticalDragEnd: _onSwipeEnd,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // LAYER 1: Background Map Video
            if (activeBg.value.isInitialized)
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: activeBg.value.size.width,
                    height: activeBg.value.size.height,
                    child: VideoPlayer(activeBg),
                  ),
                ),
              )
            else
              const Center(child: CircularProgressIndicator(color: Colors.orange)),

            // LAYER 2: Obstacles & Trains (Coming in next step)
            // _buildObstacles(),

            // LAYER 3: Character (Modi / Meloni)
            Align(
              alignment: playerAlignment,
              child: Transform.translate(
                offset: Offset(0, -_characterY), // Jump Physics applies here
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 60.0), // Base ground margin
                  child: _buildPlayerCharacter(),
                ),
              ),
            ),

            // LAYER 4: Game HUD (Heads Up Display)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.pause_circle_filled, color: Colors.white, size: 45),
                      onPressed: () {
                        // Pause Logic
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orangeAccent, width: 2),
                      ),
                      child: Text(
                        "SCORE: $_score",
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCharacter() {
    // Bhai, Flutter default video player me transparent WebM play karne me black background de deta hai.
    // Isliye temporarily hum image placeholder laga rahe hain jab tak transparent check nahi kar lete.
    // Asli game me yahan tumhara WebM Widget aayega.
    
    IconData icon = Icons.directions_run;
    Color color = Colors.orange;
    
    if (_playerState == 'jump') { icon = Icons.arrow_upward; color = Colors.green; }
    if (_playerState == 'slide') { icon = Icons.arrow_downward; color = Colors.blue; }
    if (_playerState == 'stumble') { icon = Icons.warning; color = Colors.red; }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150), // Smooth lane switching
      width: 100,
      height: _playerState == 'slide' ? 60 : 130, // Slide hone par size chota
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            Text(_selectedCharacter.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
