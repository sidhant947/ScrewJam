import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_theme.dart';
import '../models/game_models.dart';
import '../services/storage_service.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeData>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppThemeData> with WidgetsBindingObserver {
  late AppThemeId _selectedId;

  ThemeNotifier() : super(AppThemes.clean) {
    WidgetsBinding.instance.addObserver(this);
    final savedName = StorageService.getThemeId();
    _selectedId = AppThemeId.values.firstWhere(
      (e) => e.name == savedName,
      orElse: () => AppThemeId.clean,
    );
    _updateState();
  }

  @override
  void didChangePlatformBrightness() {
    if (_selectedId == AppThemeId.system) {
      _updateState();
    }
  }

  void setTheme(AppThemeId id) {
    _selectedId = id;
    StorageService.setThemeId(id.name);
    _updateState();
  }

  void _updateState() {
    state = AppThemes.resolve(_selectedId);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

final screwColorsProvider = StateNotifierProvider<ScrewColorsNotifier, int>((ref) {
  return ScrewColorsNotifier();
});

class ScrewColorsNotifier extends StateNotifier<int> {
  ScrewColorsNotifier() : super(0) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    for (final color in ScrewColor.values) {
      final val = StorageService.getCustomScrewColor(color.name);
      if (val != null) {
        ScrewColor.customColors[color] = Color(val);
      } else {
        ScrewColor.customColors.remove(color);
      }
    }
    state++;
  }

  void setColor(ScrewColor screwColor, Color newColor) {
    ScrewColor.customColors[screwColor] = newColor;
    StorageService.setCustomScrewColor(screwColor.name, newColor.toARGB32());
    state++;
  }

  void resetColor(ScrewColor screwColor) {
    ScrewColor.customColors.remove(screwColor);
    StorageService.setCustomScrewColor(screwColor.name, null);
    state++;
  }

  void resetAll() {
    ScrewColor.customColors.clear();
    StorageService.resetScrewColors();
    state++;
  }
}
