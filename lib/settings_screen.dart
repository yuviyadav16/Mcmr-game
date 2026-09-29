import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool musicEnabled = true;
  bool sfxEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Pehle se saved settings ko load karna
  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      musicEnabled = prefs.getBool('bgm_enabled') ?? true;
      sfxEnabled = prefs.getBool('sfx_enabled') ?? true;
    });
  }

  // Music setting save karna
  Future<void> _saveMusicSetting(bool val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bgm_enabled', val);
    setState(() {
      musicEnabled = val;
    });
  }

  // SFX setting save karna
  Future<void> _saveSfxSetting(bool val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sfx_enabled', val);
    setState(() {
      sfxEnabled = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "SETTINGS", 
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SwitchListTile(
              activeColor: Colors.orangeAccent,
              title: const Text(
                "Background Music", 
                style: TextStyle(color: Colors.white, fontSize: 18)
              ),
              value: musicEnabled,
              onChanged: (val) {
                _saveMusicSetting(val);
              },
            ),
            const Divider(color: Colors.grey),
            SwitchListTile(
              activeColor: Colors.orangeAccent,
              title: const Text(
                "Sound Effects (SFX)", 
                style: TextStyle(color: Colors.white, fontSize: 18)
              ),
              value: sfxEnabled,
              onChanged: (val) {
                _saveSfxSetting(val);
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.privacy_tip, color: Colors.white),
              title: const Text("Privacy Policy", style: TextStyle(color: Colors.white)),
              onTap: () {
                // Privacy policy link logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.white),
              title: const Text("About Ticbull", style: TextStyle(color: Colors.white)),
              onTap: () {
                // Ticbull info logic
              },
            ),
          ],
        ),
      ),
    );
  }
}
