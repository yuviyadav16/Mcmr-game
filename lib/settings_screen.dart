import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool musicEnabled = true;
  bool sfxEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("SETTINGS", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SwitchListTile(
              activeColor: Colors.orangeAccent,
              title: const Text("Background Music", style: TextStyle(color: Colors.white, fontSize: 18)),
              value: musicEnabled,
              onChanged: (val) {
                setState(() => musicEnabled = val);
                // Audio Player logic yahan connect karenge
              },
            ),
            const Divider(color: Colors.grey),
            SwitchListTile(
              activeColor: Colors.orangeAccent,
              title: const Text("Sound Effects (SFX)", style: TextStyle(color: Colors.white, fontSize: 18)),
              value: sfxEnabled,
              onChanged: (val) {
                setState(() => sfxEnabled = val);
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.privacy_tip, color: Colors.white),
              title: const Text("Privacy Policy", style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.white),
              title: const Text("About Ticbull", style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
