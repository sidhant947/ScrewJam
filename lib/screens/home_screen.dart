import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/game_models.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';
import 'levels_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highestLevel = ref.watch(highestLevelProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.star_rounded, color: Color(0xFFFFA502), size: 28),
          onPressed: () => launchUrl(
            Uri.parse('https://github.com/sidhant947/ScrewJam'),
            mode: LaunchMode.externalApplication,
          ),
        ),
        title: Text(
          'LEVEL $highestLevel',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_rounded, color: Color(0xFFFF4757), size: 26),
            onPressed: () => launchUrl(
              Uri.parse('https://ko-fi.com/sidhant947'),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0.5,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                const Text(
                  'SCREW JAM',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Color(0xFF1E293B),
                    shadows: [
                      Shadow(
                        offset: Offset(0, 3),
                        blurRadius: 4,
                        color: Colors.black12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'UNSCREW, MATCH & SOLVE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                const Spacer(flex: 3),
                GestureDetector(
                  onTap: () {
                    ref.read(gameProvider.notifier).startLevel(highestLevel);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const GameScreen(),
                      ),
                    );
                  },
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF047857), width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF047857),
                          offset: Offset(0, 6),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'PLAY NOW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    _showRandomDifficultyDialog(context, ref);
                  },
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFA502),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFCC8400), width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFFCC8400),
                          offset: Offset(0, 6),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'RANDOM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LevelsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3897F0),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF1E6BB8), width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF1E6BB8),
                          offset: Offset(0, 6),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'LEVELS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF6D28D9), width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF6D28D9),
                          offset: Offset(0, 6),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'SETTINGS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 1),

              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRandomDifficultyDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'RANDOM PUZZLE',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Select puzzle difficulty',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 20),
                ...PuzzleDifficulty.values.map((diff) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        ref.read(gameProvider.notifier).startRandomPuzzle(diff);
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const GameScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: diff.color,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: diff.darkColor, width: 2.0),
                          boxShadow: [
                            BoxShadow(
                              color: diff.darkColor,
                              offset: const Offset(0, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            diff.label.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
