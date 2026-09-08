import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _hapticEnabled;

  @override
  void initState() {
    super.initState();
    _hapticEnabled = StorageService.getHapticEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SETTINGS',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Card(
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              title: const Text(
                'Haptic Feedback',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              value: _hapticEnabled,
              onChanged: (value) {
                setState(() => _hapticEnabled = value);
                StorageService.setHapticEnabled(value);
              },
            ),
          ),
        ),
      ),
    );
  }
}
