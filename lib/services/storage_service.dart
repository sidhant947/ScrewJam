import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const String boxName = 'game_data';
  static const String keyHighLevel = 'high_level';
  static const String keyHaptic = 'haptic_enabled';

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
}
