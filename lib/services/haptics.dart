import 'package:flutter/services.dart';
import 'storage_service.dart';

abstract final class Haptics {
  static bool get _enabled => StorageService.getHapticEnabled();

  static void light() {
    if (_enabled) HapticFeedback.lightImpact();
  }

  static void medium() {
    if (_enabled) HapticFeedback.mediumImpact();
  }

  static void heavy() {
    if (_enabled) HapticFeedback.heavyImpact();
  }

  static void select() {
    if (_enabled) HapticFeedback.selectionClick();
  }
}
