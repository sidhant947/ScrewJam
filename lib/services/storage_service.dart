import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const String boxName = 'game_data';
  static const String keyHighLevel = 'high_level';
  static const String keyHaptic = 'haptic_enabled';
  static const String keyTheme = 'theme_id';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  static Box get _box => Hive.box(boxName);

  static int getHighestLevel() {
    return _box.get(keyHighLevel, defaultValue: 1);
  }

  static Future<void> setHighestLevel(int level) async {
    if (level > getHighestLevel()) {
      await _box.put(keyHighLevel, level);
    }
  }

  static bool getHapticEnabled() {
    return _box.get(keyHaptic, defaultValue: true);
  }

  static Future<void> setHapticEnabled(bool value) async {
    await _box.put(keyHaptic, value);
  }

  static String getThemeId() {
    return _box.get(keyTheme, defaultValue: 'clean');
  }

  static Future<void> setThemeId(String themeId) async {
    await _box.put(keyTheme, themeId);
  }

  static int? getCustomScrewColor(String colorName) {
    return _box.get('screw_color_$colorName');
  }

  static Future<void> setCustomScrewColor(String colorName, int? value) async {
    if (value == null) {
      await _box.delete('screw_color_$colorName');
    } else {
      await _box.put('screw_color_$colorName', value);
    }
  }

  static Future<void> resetScrewColors() async {
    final keysToDelete = _box.keys.where((k) => k.toString().startsWith('screw_color_')).toList();
    for (final k in keysToDelete) {
      await _box.delete(k);
    }
  }
}
