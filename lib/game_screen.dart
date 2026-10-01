import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:math';

// ==========================================
// 1. GAME OBJECT CLASS (Trains, Enemies)
// ==========================================
class GameObject {
  String imagePath;
  int lane; // -1 (Left), 0 (Center), 1 (Right)
  double distance; // 0.0 (Far away/Horizon) to 1.0 (Screen bottom)
  String type; // 'train', 'ramp', 'barrier_jump', 'barrier_slide', 'enemy'
  
  GameObject({required this.imagePath, required this.lane, this.distance = 0.0, required this.type});
}

// ==========================================
// 2. MAIN GAME SCREEN
// ==========================================
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // --- Video Map Sequence (gb1 to gb5) ---
  late VideoPlayerController _bgController1;
  late VideoPlayerController _bgController2;
  bool _useController1 = true;
  int _currentVideoIndex = 1;
  Timer? _videoTimer;

  // --- Audio System ---
  late AudioPlayer _bgmPlayer;
  late AudioPlayer _sfxPlayer;

  // --- Player Physics & Lanes ---
  int _currentLane = 0; // -1, 0, 1
  double _characterY = 0; // Jump height (0 is ground)
  double _gravity = 2.0; 
  double _jumpVelocity = -16.0;
  double _currentVelocity = 0;
  bool _isJumping = false;
  String _playerState = 'run'; // 'run', 'jump', 'slide'
  String _selectedCharacter = 'modi'; // Ya 'meloni'

  // --- Player & CID WebM Controllers ---
  VideoPlayerController? _playerRunController;
  VideoPlayerController? _playerJumpController;
  VideoPlayerController? _playerSlideController;
  VideoPlayerController? _cidRunController;
  bool _showCID = false;

  // --- Object Spawner (Enemies & Trains) ---
  List<GameObject> _activeObjects = [];
  Timer? _spawnTimer;
  Random _random = Random();
  double _gameSpeed = 0.015; // Objects aane ki speed

  // --- Engine Timers ---
  Timer? _physicsTimer;
  Timer? _gameTimer;
  int _score = 0;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initAudio();
    _initVideoMapSequence();
    _initPlayerVideos();
    _startPhysicsEngine();
    _startGameLoop();
  }

  // --- INITIALIZERS ---
  void _initAudio() async {
    _bgmPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.play(AssetSource('audio/yuvi.mp3'));
  }

  void _playSound(String type) async {
    if (type == 'jump') await _sfxPlayer.play(AssetSource('audio/sfx/player/${_selectedCharacter}_jump.mp3'));
    if (type == 'slide') await _sfxPlayer.play(AssetSource('audio/sfx/player/slide.mp3'));
    if (type == 'stumble') await _sfxPlayer.play(AssetSource('audio/sfx/player/stumble.mp3'));
  }

  void _initPlayerVideos() {
    _playerRunController = VideoPlayerController.asset('assets/players/${_selectedCharacter}_run.webm')
      ..initialize().then((_) { _playerRunController!.setLooping(true); _playerRunController!.play(); setState(() {}); });
    _playerJumpController = VideoPlayerController.asset('assets/players/${_selectedCharacter}_jump.webm')
      ..initialize().then((_) { _playerJumpController!.setLooping(true); });
    _playerSlideController = VideoPlayerController.asset('assets/players/${_selectedCharacter}_slide.webm')
      ..initialize().then((_) { _playerSlideController!.setLooping(true); });
    _cidRunController = VideoPlayerController.asset('assets/inspector/cid_run.webm')
      ..initialize().then((_) { _cidRunController!.setLooping(true); _cidRunController!.play(); });
  }

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

  // --- MAIN PHYSICS & GAME LOOP (Maths Logic) ---
  void _startPhysicsEngine() {
    _physicsTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) { // ~60 FPS
      
      // 1. Jump Gravity Math
      if (_isJumping || _characterY > 0) {
        _currentVelocity += _gravity;
        _characterY -= _currentVelocity;

        if (_characterY <= 0) { 
          _characterY = 0;
          _isJumping = false;
          _currentVelocity = 0;
          if (_playerState == 'jump') _changePlayerState('run');
        }
      }

      // 2. Object Perspective Math (Objects moving towards player)
      for (int i = 0; i < _activeObjects.length; i++) {
        _activeObjects[i].distance += _gameSpeed;
      }
      // Remove objects that passed the screen (distance > 1.2)
      _activeObjects.removeWhere((obj) => obj.distance > 1.2);

      // 3. Simple Collision Math
      for (var obj in _activeObjects) {
        if (obj.distance > 0.8 && obj.distance < 1.0 && obj.lane == _currentLane) {
          // Player is in the same lane as object
          if (obj.type == 'barrier_jump' && !_isJumping) {
            _triggerStumble();
          } else if (obj.type == 'barrier_slide' && _playerState != 'slide') {
            _triggerStumble();
          } else if (obj.type == 'train' || obj.type == 'enemy') {
            // Needs exact avoidance
            if (!_isJumping && _playerState != 'slide') _triggerStumble();
          }
        }
      }

      if (mounted) setState(() {});
    });
  }

  void _triggerStumble() {
    // Collision hone par kya hoga
    if (!_showCID) {
      _playSound('stumble');
      setState(() { _showCID = true; });
      // CID goes away if no collision for 8 seconds
      Future.delayed(const Duration(seconds: 8), () {
        if (mounted) setState(() { _showCID = false; });
      });
    } else {
      // Game Over Logic here (CID caught you)
      // Navigating to Game Over Screen
    }
  }

  void _changePlayerState(String newState) {
    if (_playerState == newState) return;
    setState(() { _playerState = newState; });
    
    _playerRunController?.pause();
    _playerJumpController?.pause();
    _playerSlideController?.pause();
    
    if (newState == 'run') _playerRunController?.play();
    if (newState == 'jump') { _playerJumpController?.seekTo(Duration.zero); _playerJumpController?.play(); }
    if (newState == 'slide') { _playerSlideController?.seekTo(Duration.zero); _playerSlideController?.play(); }
  }

  // --- SPAWNER LOGIC ---
  void _startGameLoop() {
    _gameTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) setState(() { _score += 1; });
    });
    
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      _elapsedSeconds += 1;
      _spawnObstacle();
    });
  }

  void _spawnObstacle() {
    if (!mounted) return;
    int randomLane = _random.nextInt(3) - 1; // -1, 0, or 1
    int objType = _random.nextInt(10); // Random type selector

    String path;
    String type;

    if (objType < 3) {
      path = 'assets/obstacles/barrier_1jump.png'; type = 'barrier_jump';
    } else if (objType < 5) {
      path = 'assets/obstacles/barrier_slide.png'; type = 'barrier_slide';
    } else if (objType < 8) {
      path = 'assets/trains/normal_train_1green.png'; type = 'train';
    } else {
      // Spawn Enemy if 4 mins passed, else train
      if (_elapsedSeconds > 160) { // Using 160 ticks as demo for progressive difficulty
         path = 'assets/obstacles/enemy_fanta_yogi.png'; type = 'enemy';
      } else {
         path = 'assets/trains/ramp_train_1red.png'; type = 'ramp';
      }
    }
    
    _activeObjects.add(GameObject(imagePath: path, lane: randomLane, type: type));
  }

  // --- SWIPE CONTROLS ---
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
        _currentVelocity += 15.0; // Fast Fall
      }
    }
  }

  @override
  void dispose() {
    _videoTimer?.cancel();
    _physicsTimer?.cancel();
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
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

    // Smooth Lane Alignment Math
    Alignment playerAlignment = Alignment(0, 1.0);
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
            // 1. MAP BACKGROUND
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

            // 2. SPAWNED OBSTACLES (Fake 3D Perspective Scaling)
            ..._activeObjects.map((obj) => _build3DObject(obj)),

            // 3. PLAYER CHARACTER (WebM)
            AnimatedAlign(
              alignment: playerAlignment,
              duration: const Duration(milliseconds: 150), // Smooth Lane Switch
              child: Transform.translate(
                offset: Offset(0, -_characterY), 
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50.0), 
                  child: _buildPlayerCharacter(),
                ),
              ),
            ),
            
            // 4. CID INSPECTOR (If stumble)
            if (_showCID && _cidRunController != null && _cidRunController!.value.isInitialized)
               AnimatedAlign(
                 alignment: playerAlignment, 
                 duration: const Duration(milliseconds: 200),
                 child: Padding(
                   padding: const EdgeInsets.only(bottom: 0.0), 
                   child: SizedBox(
                     width: 140, height: 160,
                     child: VideoPlayer(_cidRunController!),
                   )
                 )
               ),

            // 5. UI HUD
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.pause_circle_filled, color: Colors.white, size: 45),
                      onPressed: () {}, // Add pause logic
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

  // --- HELPER WIDGETS ---
  
  // Perspective Scaler (Makes things look like they are coming towards you)
  Widget _build3DObject(GameObject obj) {
    // X Alignment mapping based on lane and perspective
    double alignX = 0;
    if (obj.lane == -1) alignX = -0.6 * obj.distance; // Moves outward as it gets closer
    if (obj.lane == 1) alignX = 0.6 * obj.distance;

    // Y Alignment mapping
    double alignY = -0.2 + (1.2 * obj.distance); // Starts high (horizon), moves low

    // Size scaling
    double scale = 0.1 + (0.9 * obj.distance); // Starts small, gets big

    return Align(
      alignment: Alignment(alignX, alignY),
      child: Transform.scale(
        scale: scale,
        child: Image.asset(
          obj.imagePath,
          width: 150, 
          height: 150,
          errorBuilder: (c, e, s) => const Icon(Icons.warning, color: Colors.red, size: 50),
        ),
      ),
    );
  }

  // Proper WebM player mapping
  Widget _buildPlayerCharacter() {
    VideoPlayerController? activeController;
    if (_playerState == 'run') activeController = _playerRunController;
    else if (_playerState == 'jump') activeController = _playerJumpController;
    else if (_playerState == 'slide') activeController = _playerSlideController;

    if (activeController != null && activeController.value.isInitialized) {
      return SizedBox(
        width: 120, 
        height: _playerState == 'slide' ? 90 : 160, 
        child: VideoPlayer(activeController),
      );
    } else {
       return const SizedBox(width: 50, height: 50, child: CircularProgressIndicator(color: Colors.blue));
    }
  }
}
