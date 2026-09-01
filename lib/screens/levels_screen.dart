import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';

class LevelsScreen extends ConsumerWidget {
  const LevelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highestLevel = ref.watch(highestLevelProvider);
    final totalLevels = highestLevel + 10 < 20 ? 20 : highestLevel + 10;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LEVELS',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFF1F4F9),
              Color(0xFFE2E8F0),
            ],
          ),
        ),
        child: SafeArea(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: totalLevels,
            itemBuilder: (context, index) {
                    final levelNum = index + 1;
                    final isUnlocked = levelNum <= highestLevel;
                    final isCurrent = levelNum == highestLevel;

                    final isMilestone = levelNum % 5 == 0;

                    return GestureDetector(
                      onTap: isUnlocked
                          ? () {
                              ref.read(gameProvider.notifier).startLevel(levelNum);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const GameScreen(),
                                ),
                              );
                            }
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? (isCurrent
                                  ? const Color(0xFF10B981)
                                  : (isMilestone ? const Color(0xFFFF9F43) : const Color(0xFF3897F0)))
                              : const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isUnlocked
                                ? (isCurrent
                                    ? const Color(0xFF047857)
                                    : (isMilestone ? const Color(0xFFEE5253) : const Color(0xFF1E6BB8)))
                                : const Color(0xFF94A3B8),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isUnlocked
                                  ? (isCurrent
                                      ? const Color(0xFF047857)
                                      : (isMilestone ? const Color(0xFFEE5253) : const Color(0xFF1E6BB8)))
                                  : const Color(0xFF94A3B8),
                              offset: const Offset(0, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (isMilestone && isUnlocked)
                              const Positioned(
                                top: 4,
                                right: 4,
                                child: Icon(
                                  Icons.star_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            Center(
                              child: isUnlocked
                                  ? Text(
                                      '$levelNum',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.lock_rounded,
                                      color: Color(0xFF64748B),
                                      size: 24,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }
      }
