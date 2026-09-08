import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../providers/game_provider.dart';

class ScrewJamGame extends FlameGame with TapCallbacks {
  final GameNotifier notifier;
  GameState currentState;

  ScrewJamGame({
    required this.notifier,
    required this.currentState,
  });

  static const double virtualWidth = 360.0;
  static const double virtualHeight = 500.0;
  static const double horizontalPadding = 20.0;
  static const double verticalPadding = 12.0;

  double userZoom = 1.0;
  Offset userPan = Offset.zero;

  double get boardScale {
    final availableW = max(100.0, size.x - horizontalPadding * 2);
    final availableH = max(100.0, size.y - verticalPadding * 2);
    final baseScale = min(availableW / virtualWidth, availableH / virtualHeight).clamp(0.5, 1.35);
    return baseScale * userZoom;
  }

  double get boardOriginX => ((size.x - (virtualWidth * boardScale)) / 2.0) + userPan.dx;
  double get boardOriginY => ((size.y - (virtualHeight * boardScale)) / 2.0) + userPan.dy;

  Offset screenToBoard(Offset screenPos) {
    return Offset(
      (screenPos.dx - boardOriginX) / boardScale,
      (screenPos.dy - boardOriginY) / boardScale,
    );
  }

  void setZoomAndPan(double zoom, Offset pan) {
    userZoom = zoom.clamp(0.65, 3.0);
    userPan = pan;
  }

  void resetZoomAndPan() {
    userZoom = 1.0;
    userPan = Offset.zero;
  }

  void updateState(GameState newState) {
    currentState = newState;
  }

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  void update(double dt) {
    super.update(dt);

    for (final plate in currentState.plates) {
      final remainingHoles = plate.holes.where((h) => h.currentScrew != null).toList();

      if (plate.hadScrewsOnLoad && remainingHoles.isEmpty) {
        if (!plate.isFalling) {
          plate.isFalling = true;
          plate.fallSpeedY = 140.0;
          plate.fallSpeedX = (Random().nextDouble() - 0.5) * 100.0;
          plate.angularVelocity = (Random().nextDouble() - 0.5) * 5.0;
          plate.pivotWorld = null;
        }

        plate.fallSpeedY += 1500.0 * dt;
        plate.position += Offset(plate.fallSpeedX * dt, plate.fallSpeedY * dt);
        plate.angle += plate.angularVelocity * dt;

        if (plate.position.dy > 650.0) {
          plate.opacity = max(0.0, plate.opacity - dt * 1.8);
        }
      } else if (remainingHoles.length == 1) {
        final pinHole = remainingHoles.first;
        final rLocal = pinHole.relativeOffset;

        if (plate.pivotWorld == null) {
          final cosA = cos(plate.angle);
          final sinA = sin(plate.angle);
          final rx = rLocal.dx * cosA - rLocal.dy * sinA;
          final ry = rLocal.dx * sinA + rLocal.dy * cosA;
          plate.pivotWorld = plate.position + Offset(rx, ry);
        }

        final pivot = plate.pivotWorld!;
        final armDist = rLocal.distance;

        if (armDist > 1.5) {
          final cosA = cos(plate.angle);
          final sinA = sin(plate.angle);
          final cmVecX = -(rLocal.dx * cosA - rLocal.dy * sinA);

          const double g = 1450.0;
          final double torque = cmVecX * g;
          final double momentOfInertia = plate.mass * (armDist * armDist + 1600.0);
          final double angularAccel = torque / momentOfInertia;

          plate.angularVelocity += angularAccel * dt;
          plate.angularVelocity *= pow(0.965, dt * 60);
          plate.angle += plate.angularVelocity * dt;

          final newCosA = cos(plate.angle);
          final newSinA = sin(plate.angle);
          final newRx = rLocal.dx * newCosA - rLocal.dy * newSinA;
          final newRy = rLocal.dx * newSinA + rLocal.dy * newCosA;
          plate.position = pivot - Offset(newRx, newRy);
        }
      } else {
        plate.pivotWorld = null;
        plate.angularVelocity = 0.0;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.save();
    canvas.translate(boardOriginX, boardOriginY);
    canvas.scale(boardScale, boardScale);

    final sortedPlates = List<PlateModel>.from(currentState.plates)
      ..sort((a, b) => a.layer.compareTo(b.layer));

    for (final plate in sortedPlates) {
      if (plate.opacity > 0.01) {
        _renderPlate(canvas, plate);
      }
    }

    canvas.restore();
  }

  void _renderPlate(Canvas canvas, PlateModel plate) {
    canvas.save();
    canvas.translate(plate.position.dx, plate.position.dy);
    canvas.rotate(plate.angle);

    final path = getPlatePath(plate);

    final layerElevation = 4.0 + plate.layer * 4.0;
    final shadowPaint = Paint()
      ..color = const Color(0x38000000).withValues(alpha: (0.24 + plate.layer * 0.05) * plate.opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, layerElevation * 1.6);

    final outerRimDark = Paint()
      ..color = Colors.black.withValues(alpha: 0.25 * plate.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final outerGlowWhite = Paint()
      ..color = Colors.white.withValues(alpha: 0.95 * plate.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final plateBody = Paint()
      ..color = plate.color.withValues(alpha: 0.92 * plate.opacity)
      ..style = PaintingStyle.fill;

    final specularHighlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.45 * plate.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    canvas.drawPath(path.shift(Offset(0, layerElevation)), shadowPaint);
    canvas.drawPath(path, outerRimDark);
    canvas.drawPath(path, outerGlowWhite);
    canvas.drawPath(path, plateBody);
    canvas.drawPath(path, specularHighlight);

    if (plate.shapeType == PlateShapeType.iceCreamCone) {
      _renderConeDetails(canvas, plate);
    } else if (plate.shapeType == PlateShapeType.iceCreamScoopLeft ||
        plate.shapeType == PlateShapeType.iceCreamScoopRight) {
      _renderDripDetails(canvas, plate);
    } else if (plate.shapeType == PlateShapeType.donut) {
      _renderDonutHole(canvas, plate);
    }

    for (final hole in plate.holes) {
      _renderHoleAndScrew(canvas, plate, hole);
    }

    canvas.restore();
  }

  void _renderConeDetails(Canvas canvas, PlateModel plate) {
    final w = plate.size.width;
    final h = plate.size.height;
    final bandPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.85 * plate.opacity)
      ..style = PaintingStyle.fill;

    final bandRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, -h * 0.28), width: w * 0.95, height: 30),
      const Radius.circular(8),
    );
    canvas.drawRRect(bandRect, bandPaint);

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6 * plate.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawLine(
      Offset(-w * 0.45, -h * 0.28),
      Offset(w * 0.45, -h * 0.28),
      linePaint,
    );
  }

  void _renderDripDetails(Canvas canvas, PlateModel plate) {
    final w = plate.size.width;
    final h = plate.size.height;
    final dripPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.50 * plate.opacity)
      ..style = PaintingStyle.fill;

    final dripPath = Path()
      ..moveTo(-w * 0.38, -h * 0.05)
      ..quadraticBezierTo(-w * 0.2, h * 0.35, 0, -h * 0.05)
      ..quadraticBezierTo(w * 0.2, h * 0.38, w * 0.38, -h * 0.05)
      ..close();

    canvas.drawPath(dripPath, dripPaint);
  }

  void _renderDonutHole(Canvas canvas, PlateModel plate) {
    final centerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95 * plate.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(Offset.zero, 25, centerPaint);
  }

  void _renderHoleAndScrew(Canvas canvas, PlateModel plate, ScrewHoleModel hole) {
    final holePos = hole.relativeOffset;

    final rimPaint = Paint()
      ..color = const Color(0xFFBDC3C7).withValues(alpha: 0.95 * plate.opacity)
      ..style = PaintingStyle.fill;
    final holeInnerPaint = Paint()
      ..color = const Color(0xFF4A4A4A).withValues(alpha: 0.95 * plate.opacity)
      ..style = PaintingStyle.fill;
    final holeDepthPaint = Paint()
      ..color = const Color(0xFF2C2C2C).withValues(alpha: plate.opacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(holePos, 17, rimPaint);
    canvas.drawCircle(holePos, 14, holeInnerPaint);
    canvas.drawCircle(holePos + const Offset(0, 1.5), 11, holeDepthPaint);

    if (hole.currentScrew != null) {
      final screw = hole.currentScrew!;

      final screwShadowPaint = Paint()
        ..color = screw.shadow.withValues(alpha: 0.38 * plate.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(holePos + const Offset(0, 3.5), 16, screwShadowPaint);

      final screwBodyPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 0.85,
          colors: [
            screw.highlight.withValues(alpha: plate.opacity),
            screw.primary.withValues(alpha: plate.opacity),
            screw.dark.withValues(alpha: plate.opacity),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: holePos, radius: 15.5));

      canvas.drawCircle(holePos, 15.5, screwBodyPaint);

      final borderScrew = Paint()
        ..color = Colors.white.withValues(alpha: 0.65 * plate.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3;
      canvas.drawCircle(holePos, 15.5, borderScrew);

      if (hole.slotType == ScrewSlotType.star) {
        _renderStarScrewSlot(canvas, holePos, screw.dark.withValues(alpha: plate.opacity));
      } else {
        _renderCrossScrewSlot(canvas, holePos, screw.dark.withValues(alpha: plate.opacity));
      }
    }
  }

  void _renderCrossScrewSlot(Canvas canvas, Offset center, Color slotColor) {
    final crossPaint = Paint()
      ..color = slotColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.6;

    final arm = 5.5;
    canvas.drawLine(
      Offset(center.dx - arm, center.dy - arm),
      Offset(center.dx + arm, center.dy + arm),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx + arm, center.dy - arm),
      Offset(center.dx - arm, center.dy + arm),
      crossPaint,
    );
  }

  void _renderStarScrewSlot(Canvas canvas, Offset center, Color slotColor) {
    final starFillPaint = Paint()
      ..color = slotColor
      ..style = PaintingStyle.fill;

    final path = Path();
    const double outerR = 6.5;
    const double innerR = 3.2;
    const int points = 5;

    for (int i = 0; i < points * 2; i++) {
      final isEven = i % 2 == 0;
      final r = isEven ? outerR : innerR;
      final angle = (i * pi / points) - (pi / 2);
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, starFillPaint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    final rawTouchPos = event.localPosition.toOffset();
    final touchPos = screenToBoard(rawTouchPos);

    final candidates = <({PlateModel plate, ScrewHoleModel hole, double distance, int layer})>[];

    for (final plate in currentState.plates) {
      if (plate.isFalling) continue;

      for (final hole in plate.holes) {
        if (hole.currentScrew == null) continue;

        final globalHolePos = notifier.getGlobalHolePosition(plate, hole);
        final dist = (touchPos - globalHolePos).distance;

        if (dist <= 28.0) {
          if (!notifier.isHoleCoveredByHigherPlate(plate, hole, currentState.plates)) {
            candidates.add((
              plate: plate,
              hole: hole,
              distance: dist,
              layer: plate.layer,
            ));
          }
        }
      }
    }

    if (candidates.isNotEmpty) {
      candidates.sort((a, b) {
        final layerCmp = b.layer.compareTo(a.layer);
        if (layerCmp != 0) return layerCmp;
        return a.distance.compareTo(b.distance);
      });

      final best = candidates.first;

      bool coveredByHigherBody = false;
      for (final plate in currentState.plates) {
        if (plate.isFalling) continue;
        if (plate.layer > best.plate.layer) {
          if (notifier.isPointInsidePlate(touchPos, plate)) {
            coveredByHigherBody = true;
            break;
          }
        }
      }

      if (!coveredByHigherBody) {
        notifier.handleScrewTap(best.plate, best.hole, currentState.plates);
      }
      return;
    }

    final sortedPlatesDesc = List<PlateModel>.from(currentState.plates)
      ..sort((a, b) => b.layer.compareTo(a.layer));

    for (final plate in sortedPlatesDesc) {
      if (plate.isFalling) continue;
      if (notifier.isPointInsidePlate(touchPos, plate)) {
        return;
      }
    }
  }
}
