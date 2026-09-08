import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';
import 'game_screen.dart';

class LevelsScreen extends ConsumerWidget {
  const LevelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highestLevel = ref.watch(highestLevelProvider);
    final appTheme = ref.watch(themeProvider);
    final totalLevels = highestLevel + 10 < 20 ? 20 : highestLevel + 10;

    return Scaffold(
      backgroundColor: appTheme.background,
      appBar: AppBar(
        title: Text(
          'LEVELS',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: appTheme.appBarFg,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: appTheme.appBarFg,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Container(
        color: appTheme.background,
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
                            ? appTheme.levelCurrent
                            : (isMilestone ? appTheme.levelMilestone : appTheme.levelNormal))
                        : appTheme.levelLocked,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isUnlocked
                          ? (isCurrent
                              ? appTheme.levelCurrentBorder
                              : (isMilestone ? appTheme.levelMilestoneBorder : appTheme.levelNormalBorder))
                          : appTheme.levelLockedBorder,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isUnlocked
                            ? (isCurrent
                                ? appTheme.levelCurrentShadow
                                : (isMilestone ? appTheme.levelMilestoneShadow : appTheme.levelNormalShadow))
                            : appTheme.levelLockedBorder,
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
                            : Icon(
                                Icons.lock_rounded,
                                color: appTheme.levelLockedIcon,
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
