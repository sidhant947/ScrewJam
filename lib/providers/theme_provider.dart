import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_theme.dart';
import '../services/storage_service.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeData>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppThemeData> {
  ThemeNotifier() : super(AppThemes.fromName(StorageService.getThemeId()));

  void setTheme(AppThemeId id) {
    state = AppThemes.fromId(id);
    StorageService.setThemeId(id.name);
  }
}
