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
  late AudioPlayer _sfxPlayer;

  // --- Player Physics & Lanes ---
  int _currentLane = 0; // -1 (Left), 0 (Center), 1 (Right)
  double _characterY = 0; // Jump height
  double _gravity = 2.5; 
  double _jumpVelocity = -18.0;
  double _currentVelocity = 0;
  bool _isJumping = false;
  String _playerState = 'run'; // 'run', 'jump', 'slide', 'stumble'
  
  // Character asset selection
  String _selectedCharacter = 'modi'; 

  // --- PLAYER VIDEO CONTROLLER (Asli Modi/Meloni dikhane ke liye) ---
  VideoPlayerController? _playerRunController;
  VideoPlayerController? _playerJumpController;
  VideoPlayerController? _playerSlideController;

  // --- CID Inspector State ---
  bool _showCID = false;
  VideoPlayerController? _cidRunController;

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
    _initPlayerVideos(); // Character ki .webm load karna
    _startPhysicsEngine();
    _startGameLoop();
  }

  void _initPlayerVideos() {
    // RUN Video (e.g. assets/players/modi_run.webm)[span_7](start_span)[span_7](end_span)
    _playerRunController = VideoPlayerController.asset('assets/players/${_selectedCharacter}_run.webm')
      ..initialize().then((_) {
        _playerRunController!.setLooping(true);
        _playerRunController!.play();
        setState(() {});
      });
      
    // JUMP Video (e.g. assets/players/modi_jump.webm)[span_8](start_span)[span_8](end_span)
    _playerJumpController = VideoPlayerController.asset('assets/players/${_selectedCharacter}_jump.webm')
      ..initialize().then((_) {
        _playerJumpController!.setLooping(true);
      });
      
    // SLIDE Video (e.g. assets/players/modi_slide.webm)[span_9](start_span)[span_9](end_span)
    _playerSlideController = VideoPlayerController.asset('assets/players/${_selectedCharacter}_slide.webm')
      ..initialize().then((_) {
        _playerSlideController!.setLooping(true);
      });

    // CID Inspector Video[span_10](start_span)[span_10](end_span)
    _cidRunController = VideoPlayerController.asset('assets/inspector/cid_run.webm')
      ..initialize().then((_) {
        _cidRunController!.setLooping(true);
        _cidRunController!.play();
      });
  }

  void _initAudio() async {
    _bgmPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.play(AssetSource('audio/yuvi.mp3'));[span_11](start_span)[span_11](end_span)
  }

  void _playSound(String type) async {
    if (type == 'jump') await _sfxPlayer.play(AssetSource('audio/sfx/player/${_selectedCharacter}_jump.mp3'));[span_12](start_span)[span_12](end_span)
    if (type == 'slide') await _sfxPlayer.play(AssetSource('audio/sfx/player/slide.mp3'));
  }

  // --- Video Sequence Logic (1 -> 2 -> 3 -> 4 -> 5 -> 1) ---
  void _initVideoMapSequence() {
    _bgController1 = VideoPlayerController.asset('assets/gb/gb1.mp4')[span_13](start_span)[span_13](end_span)
      ..initialize().then((_) {
        _bgController1.play();
        _bgController1.setLooping(true); 
        setState(() {});
        _scheduleNextVideo(1);
      });
    _bgController2 = VideoPlayerController.asset('assets/gb/gb2.mp4')..initialize();[span_14](start_span)[span_14](end_span)
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

        if (_characterY <= 0) { 
          _characterY = 0;
          _isJumping = false;
          _currentVelocity = 0;
          if (_playerState == 'jump') _changePlayerState('run');
        }
        setState(() {});
      }
    });
  }
  
  void _changePlayerState(String newState) {
    setState(() {
      _playerState = newState;
    });
    
    // Manage which player video is playing
    _playerRunController?.pause();
    _playerJumpController?.pause();
    _playerSlideController?.pause();
    
    if (newState == 'run') _playerRunController?.play();
    if (newState == 'jump') _playerJumpController?.play();
    if (newState == 'slide') _playerSlideController?.play();
  }

  void _startGameLoop() {
    _gameTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          _score += 1;
        });
      }
    });
    
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      _elapsedSeconds++;
      
      // TRIGGER ENEMIES AFTER 4 MINUTES (240 SECONDS)
      if (_elapsedSeconds > 240) {
        // Will call _spawnEnemy() here
      }
    });
  }

  // --- 3-Lane Swipe Controls ---
  void _onSwipeUpdate(DragUpdateDetails details) {
    if (details.delta.dx > 10) {
      if (_currentLane < 1) setState(() { _currentLane += 1; });
    } else if (details.delta.dx < -10) {
      if (_currentLane > -1) setState(() { _currentLane -= 1; });
    }
  }

  void _onSwipeEnd(DragEndDetails details) {
    if (details.primaryVelocity! < -300 && !_isJumping) {
      _isJumping = true;
      _currentVelocity = _jumpVelocity;
      _changePlayerState('jump');
      _playSound('jump');
    } else if (details.primaryVelocity! > 300) {
      if (!_isJumping) {
        _changePlayerState('slide');
        _playSound('slide');
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted && _playerState == 'slide') _changePlayerState('run');
        });
      } else {
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
    _playerRunController?.dispose();
    _playerJumpController?.dispose();
    _playerSlideController?.dispose();
    _cidRunController?.dispose();
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    VideoPlayerController activeBg = _useController1 ? _bgController1 : _bgController2;

    Alignment playerAlignment = Alignment.bottomCenter;
    if (_currentLane == -1) playerAlignment = const Alignment(-0.6, 1.0); 
    if (_currentLane == 1) playerAlignment = const Alignment(0.6, 1.0);  

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

            // LAYER 2: Obstacles & Trains Placeholder
            // Abhi ke liye ek dummy train dikha rahe hain track ke alignment test karne ke liye
            _buildObstacles(),

            // LAYER 3: Character (Asli WebM Video) & CID
            Align(
              alignment: playerAlignment,
              child: Transform.translate(
                offset: Offset(0, -_characterY), 
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 60.0), 
                  child: _buildPlayerCharacter(),
                ),
              ),
            ),
            
            // CID Inspector (Invisible unless _showCID is true)
            if (_showCID && _cidRunController != null && _cidRunController!.value.isInitialized)
               Align(
                 alignment: playerAlignment, // CID player ki lane me aayega
                 child: Padding(
                   padding: const EdgeInsets.only(bottom: 10.0), // Player ke thoda peeche
                   child: SizedBox(
                     width: 100, height: 130,
                     child: VideoPlayer(_cidRunController!),
                   )
                 )
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
                      onPressed: () {},
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

  // Asli Video Player Return Karega
  Widget _buildPlayerCharacter() {
    VideoPlayerController? activeController;
    if (_playerState == 'run') activeController = _playerRunController;
    else if (_playerState == 'jump') activeController = _playerJumpController;
    else if (_playerState == 'slide') activeController = _playerSlideController;
    else activeController = _playerRunController; // fallback

    if (activeController != null && activeController.value.isInitialized) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 120, // Adjust based on your webm aspect ratio
        height: _playerState == 'slide' ? 80 : 150, 
        child: VideoPlayer(activeController),
      );
    } else {
       // Jab tak video load ho rahi hai, ek loading indicator
       return const SizedBox(width: 50, height: 50, child: CircularProgressIndicator(color: Colors.blue));
    }
  }

  // Obstacle Spawner Layer (Dummy train to test rendering)
  Widget _buildObstacles() {
     // Yahan hum baad me math use karke aage se peeche aati hui trains banayenge.
     // Filhal testing ke liye Center track (0) par ek choti image laga dete hain
     return Align(
        alignment: const Alignment(0, -0.2), // Center lane, thoda upar (door)
        child: Image.asset('assets/trains/normal_train_1green.png', width: 80, height: 80, errorBuilder: (context, error, stackTrace) {
           return const Icon(Icons.train, size: 50, color: Colors.white);
        }),
     );
  }
}
