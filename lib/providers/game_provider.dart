import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_models.dart';
import '../services/haptics.dart';
import '../services/level_generator.dart';
import '../services/storage_service.dart';

final highestLevelProvider = StateProvider<int>((ref) {
  return StorageService.getHighestLevel();
});

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  final startLevel = ref.read(highestLevelProvider);
  return GameNotifier(startLevel, ref);
});

class GameNotifier extends StateNotifier<GameState> {
  final Ref _ref;

  GameNotifier(int initialLevel, this._ref) : super(LevelGenerator.generateLevel(initialLevel));

  void startLevel(int level) {
    state = LevelGenerator.generateLevel(level);
  }

  void startRandomPuzzle(PuzzleDifficulty difficulty, {int? seed}) {
    state = LevelGenerator.generateDifficultyLevel(difficulty, seed: seed);
  }

  void restartCurrentLevel() {
    if (state.isRandom && state.difficulty != null) {
      state = LevelGenerator.generateDifficultyLevel(state.difficulty!, seed: state.seed);
      return;
    }
    state = LevelGenerator.generateLevel(state.level);
  }

  void nextLevel() {
    if (state.isRandom && state.difficulty != null) {
      startRandomPuzzle(state.difficulty!);
      return;
    }
    final nextLvl = state.level + 1;
    StorageService.setHighestLevel(nextLvl);
    if (nextLvl > _ref.read(highestLevelProvider)) {
      _ref.read(highestLevelProvider.notifier).state = nextLvl;
    }
    startLevel(nextLvl);
  }

  bool isHoleCoveredByHigherPlate(PlateModel targetPlate, ScrewHoleModel hole, [List<PlateModel>? platesList]) {
    final activePlates = platesList ?? state.plates;
    final globalPos = getGlobalHolePosition(targetPlate, hole);
    const screwRadius = 15.0;
    final checkOffsets = <Offset>[
      Offset.zero,
    ];
    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      checkOffsets.add(Offset(cos(angle) * screwRadius, sin(angle) * screwRadius));
      checkOffsets.add(Offset(cos(angle) * (screwRadius * 0.65), sin(angle) * (screwRadius * 0.65)));
    }

    for (final plate in activePlates) {
      if (plate.isFalling) continue;
      if (plate.id == targetPlate.id) continue;
      if (plate.layer > targetPlate.layer) {
        for (final offset in checkOffsets) {
          if (isPointInsidePlate(globalPos + offset, plate)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  Offset getGlobalHolePosition(PlateModel plate, ScrewHoleModel hole) {
    final cosA = cos(plate.angle);
    final sinA = sin(plate.angle);
    final rx = hole.relativeOffset.dx * cosA - hole.relativeOffset.dy * sinA;
    final ry = hole.relativeOffset.dx * sinA + hole.relativeOffset.dy * cosA;
    return plate.position + Offset(rx, ry);
  }

  bool isPointInsidePlate(Offset pt, PlateModel plate) {
    final rel = pt - plate.position;
    final cosA = cos(-plate.angle);
    final sinA = sin(-plate.angle);
    final localPt = Offset(
      rel.dx * cosA - rel.dy * sinA,
      rel.dx * sinA + rel.dy * cosA,
    );
    return getPlatePath(plate).contains(localPt);
  }

  bool handleScrewTap(PlateModel plate, ScrewHoleModel hole, [List<PlateModel>? livePlates]) {
    if (state.status != GameStatus.playing) return false;
    if (hole.currentScrew == null) return false;
    if (isHoleCoveredByHigherPlate(plate, hole, livePlates)) return false;

    final screw = hole.currentScrew!;

    if (state.activeBox.targetColor == screw && !state.activeBox.isFull) {
      hole.currentScrew = null;

      final updatedBox = state.activeBox.addScrew(screw);
      state = state.copyWith(
        activeBox: updatedBox,
        score: state.score + 10,
      );

      Haptics.light();

      if (updatedBox.isFull) {
        advanceBoxAndCheckWaiting();
      } else {
        _checkGameCompletion();
      }
      return true;
    }

    final firstEmptyIdx = state.waitingHoles.indexWhere((s) => s == null);
    if (firstEmptyIdx != -1) {
      hole.currentScrew = null;
      final newWaiting = List<ScrewColor?>.from(state.waitingHoles);
      newWaiting[firstEmptyIdx] = screw;

      Haptics.select();

      state = state.copyWith(
        waitingHoles: newWaiting,
      );

      _checkGameCompletion();
      return true;
    }

    Haptics.heavy();
    return false;
  }

  void advanceBoxAndCheckWaiting() {
    if (state.pendingBoxes.isNotEmpty) {
      final newPending = List<ToolboxModel>.from(state.pendingBoxes);
      final nextBox = newPending.removeAt(0);
      state = state.copyWith(
        activeBox: nextBox,
        pendingBoxes: newPending,
      );
      Haptics.medium();
      _checkWaitingHolesForActiveBox();
    }
    _checkGameCompletion();
  }

  void _checkWaitingHolesForActiveBox() {
    var newWaiting = List<ScrewColor?>.from(state.waitingHoles);
    var currentBox = state.activeBox;
    var currentPending = List<ToolboxModel>.from(state.pendingBoxes);

    bool changed = true;
    while (changed) {
      changed = false;
      for (int i = 0; i < newWaiting.length; i++) {
        final screw = newWaiting[i];
        if (screw != null && screw == currentBox.targetColor && !currentBox.isFull) {
          currentBox = currentBox.addScrew(screw);
          newWaiting[i] = null;
          changed = true;

          if (currentBox.isFull && currentPending.isNotEmpty) {
            currentBox = currentPending.removeAt(0);
          }
          break;
        }
      }
    }

    state = state.copyWith(
      waitingHoles: newWaiting,
      activeBox: currentBox,
      pendingBoxes: currentPending,
    );
  }

  void _checkGameCompletion() {
    bool hasAnyScrews = false;
    for (var p in state.plates) {
      for (var h in p.holes) {
        if (h.currentScrew != null) {
          hasAnyScrews = true;
          break;
        }
      }
      if (hasAnyScrews) break;
    }

    final hasWaitingScrews = state.waitingHoles.any((s) => s != null);

    if (!hasAnyScrews && !hasWaitingScrews) {
      state = state.copyWith(status: GameStatus.won);
      Haptics.heavy();
      if (!state.isRandom) {
        final nextLvl = state.level + 1;
        StorageService.setHighestLevel(nextLvl);
        if (nextLvl > _ref.read(highestLevelProvider)) {
          _ref.read(highestLevelProvider.notifier).state = nextLvl;
        }
      }
      return;
    }

    final isWaitingFull = !state.waitingHoles.any((s) => s == null);
    if (isWaitingFull) {
      final canMatchActive = state.waitingHoles.any((s) => s == state.activeBox.targetColor);
      if (!canMatchActive) {
        state = state.copyWith(status: GameStatus.lost);
        Haptics.heavy();
      }
    }
  }
}
