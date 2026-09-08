import 'package:flutter/material.dart';

enum AppThemeId { clean, dark, forest, ocean, sunset }

class AppThemeData {
  final AppThemeId id;
  final String name;
  final String emoji;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color border;
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color appBarBg;
  final Color appBarFg;
  final Color waitingTray;
  final Color waitingTrayBorder;
  final Color toolboxHandle;
  final Color toolboxHandleBorder;
  final Color playBg;
  final Color playBorder;
  final Color playShadow;
  final Color randomBg;
  final Color randomBorder;
  final Color randomShadow;
  final Color levelsBg;
  final Color levelsBorder;
  final Color levelsShadow;
  final Color settingsBg;
  final Color settingsBorder;
  final Color settingsShadow;
  final Color levelCurrent;
  final Color levelCurrentBorder;
  final Color levelCurrentShadow;
  final Color levelMilestone;
  final Color levelMilestoneBorder;
  final Color levelMilestoneShadow;
  final Color levelNormal;
  final Color levelNormalBorder;
  final Color levelNormalShadow;
  final Color levelLocked;
  final Color levelLockedBorder;
  final Color levelLockedIcon;
  final Color cardBg;
  final Color dialogBg;
  final Color switchActiveColor;

  const AppThemeData({
    required this.id,
    required this.name,
    required this.emoji,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.appBarBg,
    required this.appBarFg,
    required this.waitingTray,
    required this.waitingTrayBorder,
    required this.toolboxHandle,
    required this.toolboxHandleBorder,
    required this.playBg,
    required this.playBorder,
    required this.playShadow,
    required this.randomBg,
    required this.randomBorder,
    required this.randomShadow,
    required this.levelsBg,
    required this.levelsBorder,
    required this.levelsShadow,
    required this.settingsBg,
    required this.settingsBorder,
    required this.settingsShadow,
    required this.levelCurrent,
    required this.levelCurrentBorder,
    required this.levelCurrentShadow,
    required this.levelMilestone,
    required this.levelMilestoneBorder,
    required this.levelMilestoneShadow,
    required this.levelNormal,
    required this.levelNormalBorder,
    required this.levelNormalShadow,
    required this.levelLocked,
    required this.levelLockedBorder,
    required this.levelLockedIcon,
    required this.cardBg,
    required this.dialogBg,
    required this.switchActiveColor,
  });

  ThemeData toMaterialTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Fredoka',
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme(
        brightness: _isDark ? Brightness.dark : Brightness.light,
        primary: playBg,
        onPrimary: Colors.white,
        secondary: randomBg,
        onSecondary: Colors.white,
        surface: surface,
        onSurface: textPrimary,
        error: const Color(0xFFEF4444),
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: appBarFg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: appBarFg,
          fontFamily: 'Fredoka',
          fontWeight: FontWeight.w900,
          fontSize: 18,
          letterSpacing: 1.2,
        ),
      ),
      cardTheme: CardThemeData(color: cardBg),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return switchActiveColor;
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return switchActiveColor.withValues(alpha: 0.4);
          return null;
        }),
      ),
    );
  }

  bool get _isDark {
    final luminance = background.computeLuminance();
    return luminance < 0.3;
  }
}

class AppThemes {
  static const clean = AppThemeData(
    id: AppThemeId.clean,
    name: 'Clean',
    emoji: '⬜',
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF8FAFC),
    surfaceVariant: Color(0xFFE2E8F0),
    border: Color(0xFF94A3B8),
    borderStrong: Color(0xFF64748B),
    textPrimary: Color(0xFF1E293B),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF64748B),
    appBarBg: Color(0xFFFFFFFF),
    appBarFg: Color(0xFF1E293B),
    waitingTray: Color(0xFFCBD5E1),
    waitingTrayBorder: Color(0xFF94A3B8),
    toolboxHandle: Color(0xFFE2E8F0),
    toolboxHandleBorder: Color(0xFF94A3B8),
    playBg: Color(0xFF10B981),
    playBorder: Color(0xFF047857),
    playShadow: Color(0xFF047857),
    randomBg: Color(0xFFFFA502),
    randomBorder: Color(0xFFCC8400),
    randomShadow: Color(0xFFCC8400),
    levelsBg: Color(0xFF3897F0),
    levelsBorder: Color(0xFF1E6BB8),
    levelsShadow: Color(0xFF1E6BB8),
    settingsBg: Color(0xFF8B5CF6),
    settingsBorder: Color(0xFF6D28D9),
    settingsShadow: Color(0xFF6D28D9),
    levelCurrent: Color(0xFF10B981),
    levelCurrentBorder: Color(0xFF047857),
    levelCurrentShadow: Color(0xFF047857),
    levelMilestone: Color(0xFFFF9F43),
    levelMilestoneBorder: Color(0xFFEE5253),
    levelMilestoneShadow: Color(0xFFEE5253),
    levelNormal: Color(0xFF3897F0),
    levelNormalBorder: Color(0xFF1E6BB8),
    levelNormalShadow: Color(0xFF1E6BB8),
    levelLocked: Color(0xFFCBD5E1),
    levelLockedBorder: Color(0xFF94A3B8),
    levelLockedIcon: Color(0xFF64748B),
    cardBg: Color(0xFFFFFFFF),
    dialogBg: Color(0xFFFFFFFF),
    switchActiveColor: Color(0xFF10B981),
  );

  static const dark = AppThemeData(
    id: AppThemeId.dark,
    name: 'Dark',
    emoji: '🌑',
    background: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    surfaceVariant: Color(0xFF334155),
    border: Color(0xFF475569),
    borderStrong: Color(0xFF64748B),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFFCBD5E1),
    textMuted: Color(0xFF94A3B8),
    appBarBg: Color(0xFF1E293B),
    appBarFg: Color(0xFFF1F5F9),
    waitingTray: Color(0xFF334155),
    waitingTrayBorder: Color(0xFF475569),
    toolboxHandle: Color(0xFF334155),
    toolboxHandleBorder: Color(0xFF475569),
    playBg: Color(0xFF10B981),
    playBorder: Color(0xFF047857),
    playShadow: Color(0xFF064E3B),
    randomBg: Color(0xFFF59E0B),
    randomBorder: Color(0xFFB45309),
    randomShadow: Color(0xFF78350F),
    levelsBg: Color(0xFF3B82F6),
    levelsBorder: Color(0xFF1D4ED8),
    levelsShadow: Color(0xFF1E3A8A),
    settingsBg: Color(0xFF8B5CF6),
    settingsBorder: Color(0xFF6D28D9),
    settingsShadow: Color(0xFF4C1D95),
    levelCurrent: Color(0xFF10B981),
    levelCurrentBorder: Color(0xFF047857),
    levelCurrentShadow: Color(0xFF064E3B),
    levelMilestone: Color(0xFFF59E0B),
    levelMilestoneBorder: Color(0xFFB45309),
    levelMilestoneShadow: Color(0xFF78350F),
    levelNormal: Color(0xFF3B82F6),
    levelNormalBorder: Color(0xFF1D4ED8),
    levelNormalShadow: Color(0xFF1E3A8A),
    levelLocked: Color(0xFF334155),
    levelLockedBorder: Color(0xFF475569),
    levelLockedIcon: Color(0xFF64748B),
    cardBg: Color(0xFF1E293B),
    dialogBg: Color(0xFF1E293B),
    switchActiveColor: Color(0xFF10B981),
  );

  static const forest = AppThemeData(
    id: AppThemeId.forest,
    name: 'Forest',
    emoji: '🌿',
    background: Color(0xFF1A2E1A),
    surface: Color(0xFF243324),
    surfaceVariant: Color(0xFF2F4A2F),
    border: Color(0xFF4A6741),
    borderStrong: Color(0xFF5A7A50),
    textPrimary: Color(0xFFE8F5E9),
    textSecondary: Color(0xFFC8E6C9),
    textMuted: Color(0xFF81C784),
    appBarBg: Color(0xFF243324),
    appBarFg: Color(0xFFE8F5E9),
    waitingTray: Color(0xFF2F4A2F),
    waitingTrayBorder: Color(0xFF4A6741),
    toolboxHandle: Color(0xFF2F4A2F),
    toolboxHandleBorder: Color(0xFF4A6741),
    playBg: Color(0xFF43A047),
    playBorder: Color(0xFF2E7D32),
    playShadow: Color(0xFF1B5E20),
    randomBg: Color(0xFFFFA726),
    randomBorder: Color(0xFFE65100),
    randomShadow: Color(0xFFBF360C),
    levelsBg: Color(0xFF26A69A),
    levelsBorder: Color(0xFF00796B),
    levelsShadow: Color(0xFF004D40),
    settingsBg: Color(0xFF8D6E63),
    settingsBorder: Color(0xFF5D4037),
    settingsShadow: Color(0xFF3E2723),
    levelCurrent: Color(0xFF43A047),
    levelCurrentBorder: Color(0xFF2E7D32),
    levelCurrentShadow: Color(0xFF1B5E20),
    levelMilestone: Color(0xFFFFA726),
    levelMilestoneBorder: Color(0xFFE65100),
    levelMilestoneShadow: Color(0xFFBF360C),
    levelNormal: Color(0xFF26A69A),
    levelNormalBorder: Color(0xFF00796B),
    levelNormalShadow: Color(0xFF004D40),
    levelLocked: Color(0xFF2F4A2F),
    levelLockedBorder: Color(0xFF4A6741),
    levelLockedIcon: Color(0xFF81C784),
    cardBg: Color(0xFF243324),
    dialogBg: Color(0xFF243324),
    switchActiveColor: Color(0xFF43A047),
  );

  static const ocean = AppThemeData(
    id: AppThemeId.ocean,
    name: 'Ocean',
    emoji: '🌊',
    background: Color(0xFF0D1B2A),
    surface: Color(0xFF1B2D3F),
    surfaceVariant: Color(0xFF243B52),
    border: Color(0xFF2E5F7A),
    borderStrong: Color(0xFF3A7A9C),
    textPrimary: Color(0xFFE0F2FE),
    textSecondary: Color(0xFFBAE6FD),
    textMuted: Color(0xFF7DD3FC),
    appBarBg: Color(0xFF1B2D3F),
    appBarFg: Color(0xFFE0F2FE),
    waitingTray: Color(0xFF243B52),
    waitingTrayBorder: Color(0xFF2E5F7A),
    toolboxHandle: Color(0xFF243B52),
    toolboxHandleBorder: Color(0xFF2E5F7A),
    playBg: Color(0xFF0EA5E9),
    playBorder: Color(0xFF0369A1),
    playShadow: Color(0xFF0C4A6E),
    randomBg: Color(0xFF06B6D4),
    randomBorder: Color(0xFF0E7490),
    randomShadow: Color(0xFF164E63),
    levelsBg: Color(0xFF6366F1),
    levelsBorder: Color(0xFF4338CA),
    levelsShadow: Color(0xFF312E81),
    settingsBg: Color(0xFF8B5CF6),
    settingsBorder: Color(0xFF6D28D9),
    settingsShadow: Color(0xFF4C1D95),
    levelCurrent: Color(0xFF0EA5E9),
    levelCurrentBorder: Color(0xFF0369A1),
    levelCurrentShadow: Color(0xFF0C4A6E),
    levelMilestone: Color(0xFF06B6D4),
    levelMilestoneBorder: Color(0xFF0E7490),
    levelMilestoneShadow: Color(0xFF164E63),
    levelNormal: Color(0xFF6366F1),
    levelNormalBorder: Color(0xFF4338CA),
    levelNormalShadow: Color(0xFF312E81),
    levelLocked: Color(0xFF243B52),
    levelLockedBorder: Color(0xFF2E5F7A),
    levelLockedIcon: Color(0xFF7DD3FC),
    cardBg: Color(0xFF1B2D3F),
    dialogBg: Color(0xFF1B2D3F),
    switchActiveColor: Color(0xFF0EA5E9),
  );

  static const sunset = AppThemeData(
    id: AppThemeId.sunset,
    name: 'Sunset',
    emoji: '🌅',
    background: Color(0xFF1C0A00),
    surface: Color(0xFF2D1200),
    surfaceVariant: Color(0xFF3D1F00),
    border: Color(0xFF7C3A10),
    borderStrong: Color(0xFF9C4A18),
    textPrimary: Color(0xFFFFF3E0),
    textSecondary: Color(0xFFFFCCBC),
    textMuted: Color(0xFFFFAB91),
    appBarBg: Color(0xFF2D1200),
    appBarFg: Color(0xFFFFF3E0),
    waitingTray: Color(0xFF3D1F00),
    waitingTrayBorder: Color(0xFF7C3A10),
    toolboxHandle: Color(0xFF3D1F00),
    toolboxHandleBorder: Color(0xFF7C3A10),
    playBg: Color(0xFFFF6B35),
    playBorder: Color(0xFFBF360C),
    playShadow: Color(0xFF870000),
    randomBg: Color(0xFFFF9500),
    randomBorder: Color(0xFFE65100),
    randomShadow: Color(0xFF870000),
    levelsBg: Color(0xFFE91E63),
    levelsBorder: Color(0xFF880E4F),
    levelsShadow: Color(0xFF560027),
    settingsBg: Color(0xFF9C27B0),
    settingsBorder: Color(0xFF4A148C),
    settingsShadow: Color(0xFF12005E),
    levelCurrent: Color(0xFFFF6B35),
    levelCurrentBorder: Color(0xFFBF360C),
    levelCurrentShadow: Color(0xFF870000),
    levelMilestone: Color(0xFFFF9500),
    levelMilestoneBorder: Color(0xFFE65100),
    levelMilestoneShadow: Color(0xFF870000),
    levelNormal: Color(0xFFE91E63),
    levelNormalBorder: Color(0xFF880E4F),
    levelNormalShadow: Color(0xFF560027),
    levelLocked: Color(0xFF3D1F00),
    levelLockedBorder: Color(0xFF7C3A10),
    levelLockedIcon: Color(0xFFFFAB91),
    cardBg: Color(0xFF2D1200),
    dialogBg: Color(0xFF2D1200),
    switchActiveColor: Color(0xFFFF6B35),
  );

  static const all = [clean, dark, forest, ocean, sunset];

  static AppThemeData fromId(AppThemeId id) {
    return all.firstWhere((t) => t.id == id, orElse: () => clean);
  }

  static AppThemeData fromName(String name) {
    return all.firstWhere(
      (t) => t.id.name == name,
      orElse: () => clean,
    );
  }
}
