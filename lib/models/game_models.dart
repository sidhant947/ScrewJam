import 'dart:math';
import 'package:flutter/material.dart';

enum ScrewColor {
  coral(
    primary: Color(0xFFFF4757),
    dark: Color(0xFFC0392B),
    highlight: Color(0xFFFF7675),
    shadow: Color(0x6696281B),
    label: 'Coral',
  ),
  cyan(
    primary: Color(0xFF00CEC9),
    dark: Color(0xFF009688),
    highlight: Color(0xFF81ECEC),
    shadow: Color(0x6600796B),
    label: 'Cyan',
  ),
  blue(
    primary: Color(0xFF0984E3),
    dark: Color(0xFF0C2461),
    highlight: Color(0xFF74B9FF),
    shadow: Color(0x660A3D62),
    label: 'Blue',
  ),
  yellow(
    primary: Color(0xFFF1C40F),
    dark: Color(0xFFD35400),
    highlight: Color(0xFFFFF275),
    shadow: Color(0x66B7950B),
    label: 'Yellow',
  ),
  purple(
    primary: Color(0xFF9B59B6),
    dark: Color(0xFF6C3483),
    highlight: Color(0xFFD2B4DE),
    shadow: Color(0x66512E5F),
    label: 'Purple',
  ),
  lime(
    primary: Color(0xFF2ECC71),
    dark: Color(0xFF1E8449),
    highlight: Color(0xFFA9DFBF),
    shadow: Color(0x66145A32),
    label: 'Lime',
  ),
  pink(
    primary: Color(0xFFE84393),
    dark: Color(0xFFAD1457),
    highlight: Color(0xFFFD79A8),
    shadow: Color(0x66880E4F),
    label: 'Pink',
  ),
  orange(
    primary: Color(0xFFE67E22),
    dark: Color(0xFFA04000),
    highlight: Color(0xFFF39C12),
    shadow: Color(0x667E5109),
    label: 'Orange',
  );

  final Color primary;
  final Color dark;
  final Color highlight;
  final Color shadow;
  final String label;

  const ScrewColor({
    required this.primary,
    required this.dark,
    required this.highlight,
    required this.shadow,
    required this.label,
  });
}

enum ScrewSlotType {
  cross,
  star,
}

class ScrewHoleModel {
  final String id;
  final Offset relativeOffset;
  ScrewColor? currentScrew;
  final ScrewSlotType slotType;

  ScrewHoleModel({
    required this.id,
    required this.relativeOffset,
    this.currentScrew,
    this.slotType = ScrewSlotType.cross,
  });

  ScrewHoleModel copyWith({
    String? id,
    Offset? relativeOffset,
    ScrewColor? currentScrew,
    ScrewSlotType? slotType,
    bool clearScrew = false,
  }) {
    return ScrewHoleModel(
      id: id ?? this.id,
      relativeOffset: relativeOffset ?? this.relativeOffset,
      currentScrew: clearScrew ? null : (currentScrew ?? this.currentScrew),
      slotType: slotType ?? this.slotType,
    );
  }

  ScrewHoleModel clone() {
    return ScrewHoleModel(
      id: id,
      relativeOffset: relativeOffset,
      currentScrew: currentScrew,
      slotType: slotType,
    );
  }
}

enum PlateShapeType {
  linkBar2,
  linkBar3,
  linkBar4,
  lBracket,
  tBracket,
  uBracket,
  cogwheel,
  curvedArc,
  donut,
  star,
  heart,
  circle,
  capsule,
  triangle,
  crossBar,
  roundedRect,
  iceCreamCone,
  iceCreamScoop,
  iceCreamScoopLeft,
  iceCreamScoopRight,
  popsicleStick,
  flower,
}

class PlateModel {
  final String id;
  final PlateShapeType shapeType;
  final Size size;
  final Color color;
  final int layer;
  Offset position;
  double angle;
  List<ScrewHoleModel> holes;
  bool isFalling;
  double fallSpeedX;
  double fallSpeedY;
  double angularVelocity;
  double opacity;
  Offset? pivotWorld;
  bool hadScrewsOnLoad;
  double mass;

  PlateModel({
    required this.id,
    required this.shapeType,
    required this.size,
    required this.color,
    required this.layer,
    required this.position,
    this.angle = 0.0,
    required this.holes,
    this.isFalling = false,
    this.fallSpeedX = 0.0,
    this.fallSpeedY = 0.0,
    this.angularVelocity = 0.0,
    this.opacity = 1.0,
    this.pivotWorld,
    this.hadScrewsOnLoad = false,
    this.mass = 1.0,
  });

  int get pinnedCount => holes.where((h) => h.currentScrew != null).length;

  PlateModel clone() {
    return PlateModel(
      id: id,
      shapeType: shapeType,
      size: size,
      color: color,
      layer: layer,
      position: position,
      angle: angle,
      holes: holes.map((h) => h.clone()).toList(),
      isFalling: isFalling,
      fallSpeedX: fallSpeedX,
      fallSpeedY: fallSpeedY,
      angularVelocity: angularVelocity,
      opacity: opacity,
      pivotWorld: pivotWorld,
      hadScrewsOnLoad: hadScrewsOnLoad,
      mass: mass,
    );
  }
}

Path getPlatePath(PlateModel plate) {
  final w = plate.size.width;
  final h = plate.size.height;
  final path = Path();

  switch (plate.shapeType) {
    case PlateShapeType.linkBar2:
    case PlateShapeType.linkBar3:
    case PlateShapeType.linkBar4:
    case PlateShapeType.popsicleStick:
    case PlateShapeType.capsule:
      final r = min(w, h) / 2;
      path.addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: h),
          Radius.circular(r),
        ),
      );
      break;

    case PlateShapeType.lBracket:
      final thick = min(w, h) * 0.36;
      path.moveTo(-w / 2, -h / 2);
      path.lineTo(-w / 2 + thick, -h / 2);
      path.lineTo(-w / 2 + thick, h / 2 - thick);
      path.lineTo(w / 2, h / 2 - thick);
      path.lineTo(w / 2, h / 2);
      path.lineTo(-w / 2, h / 2);
      path.close();
      break;

    case PlateShapeType.tBracket:
      final thickT = min(w, h) * 0.34;
      path.moveTo(-w / 2, -h / 2);
      path.lineTo(w / 2, -h / 2);
      path.lineTo(w / 2, -h / 2 + thickT);
      path.lineTo(thickT / 2, -h / 2 + thickT);
      path.lineTo(thickT / 2, h / 2);
      path.lineTo(-thickT / 2, h / 2);
      path.lineTo(-thickT / 2, -h / 2 + thickT);
      path.lineTo(-w / 2, -h / 2 + thickT);
      path.close();
      break;

    case PlateShapeType.uBracket:
      final thickU = min(w, h) * 0.32;
      path.moveTo(-w / 2, -h / 2);
      path.lineTo(-w / 2 + thickU, -h / 2);
      path.lineTo(-w / 2 + thickU, h / 2 - thickU);
      path.lineTo(w / 2 - thickU, h / 2 - thickU);
      path.lineTo(w / 2 - thickU, -h / 2);
      path.lineTo(w / 2, -h / 2);
      path.lineTo(w / 2, h / 2);
      path.lineTo(-w / 2, h / 2);
      path.close();
      break;

    case PlateShapeType.cogwheel:
      final outerR = w / 2;
      final innerR = outerR * 0.76;
      const cogs = 8;
      for (int i = 0; i < cogs * 2; i++) {
        final angle = (i * pi / cogs) - (pi / 2);
        final r = (i % 2 == 0) ? outerR : innerR;
        final x = r * cos(angle);
        final y = r * sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      break;

    case PlateShapeType.curvedArc:
      final outerRect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
      final innerRect = Rect.fromCenter(center: Offset.zero, width: w * 0.65, height: h * 0.65);
      path.arcTo(outerRect, -pi * 0.95, pi * 0.90, true);
      path.arcTo(innerRect, -pi * 0.05, -pi * 0.90, false);
      path.close();
      break;

    case PlateShapeType.star:
      final double outerRadius = w / 2;
      final double innerRadius = outerRadius * 0.58;
      const int numPoints = 5;
      for (int i = 0; i < numPoints * 2; i++) {
        final isEven = i % 2 == 0;
        final r = isEven ? outerRadius : innerRadius;
        final angle = (i * pi / numPoints) - (pi / 2);
        final x = r * cos(angle);
        final y = r * sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      break;

    case PlateShapeType.iceCreamCone:
      path.moveTo(0, h * 0.52);
      path.lineTo(w * 0.5, -h * 0.42);
      path.quadraticBezierTo(0, -h * 0.48, -w * 0.5, -h * 0.42);
      path.close();
      break;

    case PlateShapeType.iceCreamScoop:
      path.addArc(
        Rect.fromCenter(center: const Offset(0, 0), width: w, height: h * 0.95),
        0,
        2 * pi,
      );
      break;

    case PlateShapeType.iceCreamScoopLeft:
    case PlateShapeType.iceCreamScoopRight:
      path.moveTo(-w * 0.48, 0);
      path.quadraticBezierTo(-w * 0.48, -h * 0.48, 0, -h * 0.48);
      path.quadraticBezierTo(w * 0.48, -h * 0.48, w * 0.48, 0);
      path.quadraticBezierTo(w * 0.35, h * 0.48, w * 0.18, h * 0.25);
      path.quadraticBezierTo(0, h * 0.52, -w * 0.18, h * 0.25);
      path.quadraticBezierTo(-w * 0.35, h * 0.48, -w * 0.48, 0);
      path.close();
      break;

    case PlateShapeType.donut:
      path.addOval(Rect.fromCenter(center: Offset.zero, width: w, height: h));
      break;

    case PlateShapeType.heart:
      path.moveTo(0, h * 0.35);
      path.cubicTo(-w * 0.55, -h * 0.1, -w * 0.45, -h * 0.45, 0, -h * 0.25);
      path.cubicTo(w * 0.45, -h * 0.45, w * 0.55, -h * 0.1, 0, h * 0.35);
      path.close();
      break;

    case PlateShapeType.flower:
      const petals = 6;
      for (int i = 0; i < petals; i++) {
        final angle = (i * 2 * pi) / petals;
        final petalCenter = Offset(cos(angle) * (w * 0.28), sin(angle) * (h * 0.28));
        path.addOval(Rect.fromCenter(center: petalCenter, width: w * 0.45, height: h * 0.45));
      }
      path.addOval(Rect.fromCenter(center: Offset.zero, width: w * 0.5, height: h * 0.5));
      break;

    case PlateShapeType.crossBar:
      final bw = w * 0.35;
      final bh = h * 0.35;
      path.moveTo(-w / 2, -bh / 2);
      path.lineTo(-bw / 2, -bh / 2);
      path.lineTo(-bw / 2, -h / 2);
      path.lineTo(bw / 2, -h / 2);
      path.lineTo(bw / 2, -bh / 2);
      path.lineTo(w / 2, -bh / 2);
      path.lineTo(w / 2, bh / 2);
      path.lineTo(bw / 2, bh / 2);
      path.lineTo(bw / 2, h / 2);
      path.lineTo(-bw / 2, h / 2);
      path.lineTo(-bw / 2, bh / 2);
      path.lineTo(-w / 2, bh / 2);
      path.close();
      break;

    case PlateShapeType.triangle:
      path.moveTo(0, -h * 0.48);
      path.lineTo(w * 0.48, h * 0.48);
      path.lineTo(-w * 0.48, h * 0.48);
      path.close();
      break;

    case PlateShapeType.roundedRect:
      path.addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: h),
          const Radius.circular(18),
        ),
      );
      break;

    case PlateShapeType.circle:
      path.addOval(
        Rect.fromCenter(center: Offset.zero, width: w, height: h),
      );
      break;
  }
  return path;
}

class ToolboxModel {
  final String id;
  final ScrewColor targetColor;
  final int capacity;
  final List<ScrewColor> collected;
  final bool isCompleted;

  const ToolboxModel({
    this.id = 'box',
    required this.targetColor,
    this.capacity = 3,
    this.collected = const [],
    this.isCompleted = false,
  });

  bool get isFull => collected.length >= capacity;
  int get remaining => capacity - collected.length;

  ToolboxModel addScrew(ScrewColor color) {
    if (color != targetColor || isFull) return this;
    final newCollected = [...collected, color];
    return ToolboxModel(
      id: id,
      targetColor: targetColor,
      capacity: capacity,
      collected: newCollected,
      isCompleted: newCollected.length >= capacity,
    );
  }

  ToolboxModel copyWith({
    String? id,
    ScrewColor? targetColor,
    int? capacity,
    List<ScrewColor>? collected,
    bool? isCompleted,
  }) {
    return ToolboxModel(
      id: id ?? this.id,
      targetColor: targetColor ?? this.targetColor,
      capacity: capacity ?? this.capacity,
      collected: collected ?? this.collected,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

enum GameStatus {
  playing,
  won,
  lost,
}

class GameState {
  final int level;
  final bool isRandom;
  final PuzzleDifficulty? difficulty;
  final int? seed;
  final List<PlateModel> plates;
  final ToolboxModel activeBox;
  final List<ToolboxModel> pendingBoxes;
  final List<ScrewColor?> waitingHoles;
  final int waitingHolesCapacity;
  final GameStatus status;
  final int score;

  const GameState({
    required this.level,
    this.isRandom = false,
    this.difficulty,
    this.seed,
    required this.plates,
    required this.activeBox,
    required this.pendingBoxes,
    required this.waitingHoles,
    this.waitingHolesCapacity = 5,
    this.status = GameStatus.playing,
    this.score = 0,
  });

  GameState copyWith({
    int? level,
    bool? isRandom,
    PuzzleDifficulty? difficulty,
    int? seed,
    List<PlateModel>? plates,
    ToolboxModel? activeBox,
    List<ToolboxModel>? pendingBoxes,
    List<ScrewColor?>? waitingHoles,
    int? waitingHolesCapacity,
    GameStatus? status,
    int? score,
  }) {
    return GameState(
      level: level ?? this.level,
      isRandom: isRandom ?? this.isRandom,
      difficulty: difficulty ?? this.difficulty,
      seed: seed ?? this.seed,
      plates: plates ?? this.plates,
      activeBox: activeBox ?? this.activeBox,
      pendingBoxes: pendingBoxes ?? this.pendingBoxes,
      waitingHoles: waitingHoles ?? this.waitingHoles,
      waitingHolesCapacity: waitingHolesCapacity ?? this.waitingHolesCapacity,
      status: status ?? this.status,
      score: score ?? this.score,
    );
  }
}

enum PuzzleDifficulty {
  easy(
    label: 'Easy',
    minLevel: 1,
    maxLevel: 5,
    color: Color(0xFF10B981),
    darkColor: Color(0xFF047857),
  ),
  medium(
    label: 'Medium',
    minLevel: 6,
    maxLevel: 12,
    color: Color(0xFF3897F0),
    darkColor: Color(0xFF1E6BB8),
  ),
  hard(
    label: 'Hard',
    minLevel: 13,
    maxLevel: 20,
    color: Color(0xFFFFA502),
    darkColor: Color(0xFFCC8400),
  ),
  expert(
    label: 'Expert',
    minLevel: 21,
    maxLevel: 30,
    color: Color(0xFFFF4757),
    darkColor: Color(0xFFC0392B),
  ),
  master(
    label: 'Master',
    minLevel: 31,
    maxLevel: 50,
    color: Color(0xFF8E44AD),
    darkColor: Color(0xFF6C3483),
  );

  final String label;
  final int minLevel;
  final int maxLevel;
  final Color color;
  final Color darkColor;

  const PuzzleDifficulty({
    required this.label,
    required this.minLevel,
    required this.maxLevel,
    required this.color,
    required this.darkColor,
  });
}
