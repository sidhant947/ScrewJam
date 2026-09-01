import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_models.dart';

class LevelGenerator {
  static const double boardCenterX = 180.0;
  static const double boardCenterY = 250.0;

  static const List<Color> platePalette = [
    Color(0xFF5C6BC0),
    Color(0xFF26A69A),
    Color(0xFFFFA726),
    Color(0xFFAB47BC),
    Color(0xFFFF7043),
    Color(0xFF42A5F5),
    Color(0xFF66BB6A),
    Color(0xFFEC407A),
    Color(0xFFFFCA28),
    Color(0xFF8D6E63),
    Color(0xFF78909C),
    Color(0xFF29B6F6),
    Color(0xFF9CCC65),
    Color(0xFFFF8A65),
  ];

  static GameState generateLevel(int level, {int? seed, int? archetypeOverride}) {
    final effectiveSeed = seed ?? (level * 10007 + 733);
    final rng = Random(effectiveSeed);

    final targetPlatesCount = (5 + (sqrt(level) * 0.95) + (level * 0.02)).floor().clamp(5, 36);
    final targetLayers = (3 + (sqrt(level) * 0.35)).floor().clamp(3, 14);

    final archetypeCategory = archetypeOverride ?? (seed != null ? rng.nextInt(10) : ((level - 1) % 10));

    GameState state;
    switch (archetypeCategory) {
      case 0:
        state = _buildSymmetricalLattice(level, targetPlatesCount, targetLayers, rng);
        break;
      case 1:
        state = _buildInterlockingCogwheelMatrix(level, targetPlatesCount, targetLayers, rng);
        break;
      case 2:
        state = _buildCornerLabyrinthBrackets(level, targetPlatesCount, targetLayers, rng);
        break;
      case 3:
        state = _buildCantileverTrussBridge(level, targetPlatesCount, targetLayers, rng);
        break;
      case 4:
        state = _buildConcentricVaultFrames(level, targetPlatesCount, targetLayers, rng);
        break;
      case 5:
        state = _buildRadialClockMechanism(level, targetPlatesCount, targetLayers, rng);
        break;
      case 6:
        state = _buildCurvedAnchorRibcage(level, targetPlatesCount, targetLayers, rng);
        break;
      case 7:
        state = _buildSweetTreatsAssembly(level, targetPlatesCount, targetLayers, rng);
        break;
      case 8:
        state = _buildHeartWingsMandala(level, targetPlatesCount, targetLayers, rng);
        break;
      case 9:
      default:
        state = _buildMasterCompoundMechanism(level, targetPlatesCount, targetLayers, rng);
        break;
    }

    return _populateSolvableScrewsWithProgression(state, level, rng).copyWith(
      level: level,
      isRandom: false,
    );
  }

  static GameState generateDifficultyLevel(PuzzleDifficulty difficulty, {int? seed}) {
    final effectiveSeed = seed ?? Random().nextInt(10000000);
    final rng = Random(effectiveSeed);

    final int targetPlatesCount;
    final int targetLayers;
    final int numColors;
    final double swapRate;
    final int simulatedLevel;

    switch (difficulty) {
      case PuzzleDifficulty.easy:
        targetPlatesCount = 5 + rng.nextInt(4);
        targetLayers = 3;
        numColors = 2 + rng.nextInt(2);
        swapRate = 0.15;
        simulatedLevel = 1 + rng.nextInt(5);
        break;
      case PuzzleDifficulty.medium:
        targetPlatesCount = 9 + rng.nextInt(5);
        targetLayers = 4 + rng.nextInt(2);
        numColors = 3 + rng.nextInt(2);
        swapRate = 0.28;
        simulatedLevel = 10 + rng.nextInt(40);
        break;
      case PuzzleDifficulty.hard:
        targetPlatesCount = 15 + rng.nextInt(6);
        targetLayers = 6 + rng.nextInt(2);
        numColors = 4 + rng.nextInt(2);
        swapRate = 0.42;
        simulatedLevel = 60 + rng.nextInt(140);
        break;
      case PuzzleDifficulty.expert:
        targetPlatesCount = 22 + rng.nextInt(6);
        targetLayers = 8 + rng.nextInt(3);
        numColors = 5 + rng.nextInt(2);
        swapRate = 0.55;
        simulatedLevel = 250 + rng.nextInt(350);
        break;
      case PuzzleDifficulty.master:
        targetPlatesCount = 29 + rng.nextInt(8);
        targetLayers = 11 + rng.nextInt(4);
        numColors = 7 + rng.nextInt(2);
        swapRate = 0.68;
        simulatedLevel = 650 + rng.nextInt(350);
        break;
    }

    final archetypeCategory = rng.nextInt(10);

    GameState state;
    switch (archetypeCategory) {
      case 0:
        state = _buildSymmetricalLattice(simulatedLevel, targetPlatesCount, targetLayers, rng);
        break;
      case 1:
        state = _buildInterlockingCogwheelMatrix(simulatedLevel, targetPlatesCount, targetLayers, rng);
        break;
      case 2:
        state = _buildCornerLabyrinthBrackets(simulatedLevel, targetPlatesCount, targetLayers, rng);
        break;
      case 3:
        state = _buildCantileverTrussBridge(simulatedLevel, targetPlatesCount, targetLayers, rng);
        break;
      case 4:
        state = _buildConcentricVaultFrames(simulatedLevel, targetPlatesCount, targetLayers, rng);
        break;
      case 5:
        state = _buildRadialClockMechanism(simulatedLevel, targetPlatesCount, targetLayers, rng);
        break;
      case 6:
        state = _buildCurvedAnchorRibcage(simulatedLevel, targetPlatesCount, targetLayers, rng);
        break;
      case 7:
        state = _buildSweetTreatsAssembly(simulatedLevel, targetPlatesCount, targetLayers, rng);
        break;
      case 8:
        state = _buildHeartWingsMandala(simulatedLevel, targetPlatesCount, targetLayers, rng);
        break;
      case 9:
      default:
        state = _buildMasterCompoundMechanism(simulatedLevel, targetPlatesCount, targetLayers, rng);
        break;
    }

    final populated = _populateSolvableScrewsWithProgression(
      state,
      simulatedLevel,
      rng,
      numColorsOverride: numColors,
      swapRateOverride: swapRate,
    );

    return populated.copyWith(
      level: 0,
      isRandom: true,
      difficulty: difficulty,
      seed: effectiveSeed,
    );
  }

  static GameState _buildSymmetricalLattice(int level, int plateCount, int maxLayers, Random rng) {
    final List<PlateModel> plates = [];
    final rows = (3 + (plateCount ~/ 7)).clamp(3, 5);
    final cols = (3 + (plateCount ~/ 7)).clamp(3, 5);
    final spacing = (180.0 / max(1, rows - 1)).clamp(38.0, 56.0);

    for (int r = 0; r < rows; r++) {
      final yPos = boardCenterY - ((rows - 1) * spacing / 2) + (r * spacing);
      final isEven = r % 2 == 0;
      plates.add(
        PlateModel(
          id: 'lat_h_$r',
          shapeType: PlateShapeType.linkBar4,
          size: Size((cols * spacing + 36.0).clamp(190.0, 250.0), 34),
          color: platePalette[(r * 2 + level) % platePalette.length],
          layer: 0 + (r % 2),
          position: Offset(boardCenterX, yPos),
          holes: [
            ScrewHoleModel(id: 'lh_${r}_0', relativeOffset: const Offset(-75, 0)),
            ScrewHoleModel(id: 'lh_${r}_1', relativeOffset: const Offset(-25, 0), slotType: isEven ? ScrewSlotType.cross : ScrewSlotType.star),
            ScrewHoleModel(id: 'lh_${r}_2', relativeOffset: const Offset(25, 0)),
            ScrewHoleModel(id: 'lh_${r}_3', relativeOffset: const Offset(75, 0)),
          ],
        ),
      );
    }

    for (int c = 0; c < cols; c++) {
      final xPos = boardCenterX - ((cols - 1) * spacing / 2) + (c * spacing);
      plates.add(
        PlateModel(
          id: 'lat_v_$c',
          shapeType: PlateShapeType.linkBar4,
          size: Size(34, (rows * spacing + 36.0).clamp(190.0, 250.0)),
          color: platePalette[(c * 3 + level + 2) % platePalette.length],
          layer: 2 + (c % 2),
          position: Offset(xPos, boardCenterY),
          holes: [
            ScrewHoleModel(id: 'lv_${c}_0', relativeOffset: const Offset(0, -75)),
            ScrewHoleModel(id: 'lv_${c}_1', relativeOffset: const Offset(0, -25)),
            ScrewHoleModel(id: 'lv_${c}_2', relativeOffset: const Offset(0, 25)),
            ScrewHoleModel(id: 'lv_${c}_3', relativeOffset: const Offset(0, 75), slotType: (c % 2 == 0) ? ScrewSlotType.star : ScrewSlotType.cross),
          ],
        ),
      );
    }

    if (level >= 3 || plateCount >= 8) {
      plates.add(
        PlateModel(
          id: 'lat_diag_1',
          shapeType: PlateShapeType.linkBar3,
          size: const Size(200, 34),
          color: const Color(0xFFFF5252),
          layer: 4.clamp(0, maxLayers),
          position: const Offset(boardCenterX, boardCenterY),
          angle: pi / 4,
          holes: [
            ScrewHoleModel(id: 'ld1_0', relativeOffset: const Offset(-65, 0)),
            ScrewHoleModel(id: 'ld1_1', relativeOffset: Offset.zero, slotType: ScrewSlotType.star),
            ScrewHoleModel(id: 'ld1_2', relativeOffset: const Offset(65, 0)),
          ],
        ),
      );
    }

    if (level >= 7 || plateCount >= 12) {
      plates.add(
        PlateModel(
          id: 'lat_diag_2',
          shapeType: PlateShapeType.linkBar3,
          size: const Size(200, 34),
          color: const Color(0xFF00ACC1),
          layer: 5.clamp(0, maxLayers),
          position: const Offset(boardCenterX, boardCenterY),
          angle: -pi / 4,
          holes: [
            ScrewHoleModel(id: 'ld2_0', relativeOffset: const Offset(-65, 0)),
            ScrewHoleModel(id: 'ld2_1', relativeOffset: Offset.zero),
            ScrewHoleModel(id: 'ld2_2', relativeOffset: const Offset(65, 0), slotType: ScrewSlotType.star),
          ],
        ),
      );
    }

    if (plateCount >= 16) {
      plates.add(
        PlateModel(
          id: 'lat_outer_top',
          shapeType: PlateShapeType.linkBar3,
          size: const Size(190, 32),
          color: const Color(0xFFAB47BC),
          layer: 6.clamp(0, maxLayers),
          position: Offset(boardCenterX, boardCenterY - 105),
          holes: [
            ScrewHoleModel(id: 'lot_0', relativeOffset: const Offset(-60, 0)),
            ScrewHoleModel(id: 'lot_1', relativeOffset: Offset.zero),
            ScrewHoleModel(id: 'lot_2', relativeOffset: const Offset(60, 0)),
          ],
        ),
      );
      plates.add(
        PlateModel(
          id: 'lat_outer_bot',
          shapeType: PlateShapeType.linkBar3,
          size: const Size(190, 32),
          color: const Color(0xFF26A69A),
          layer: 6.clamp(0, maxLayers),
          position: Offset(boardCenterX, boardCenterY + 105),
          holes: [
            ScrewHoleModel(id: 'lob_0', relativeOffset: const Offset(-60, 0)),
            ScrewHoleModel(id: 'lob_1', relativeOffset: Offset.zero),
            ScrewHoleModel(id: 'lob_2', relativeOffset: const Offset(60, 0)),
          ],
        ),
      );
    }

    if (plateCount >= 22) {
      plates.add(
        PlateModel(
          id: 'lat_outer_l',
          shapeType: PlateShapeType.linkBar3,
          size: const Size(32, 190),
          color: const Color(0xFFFFA726),
          layer: 7.clamp(0, maxLayers),
          position: Offset(boardCenterX - 105, boardCenterY),
          holes: [
            ScrewHoleModel(id: 'lol_0', relativeOffset: const Offset(0, -60)),
            ScrewHoleModel(id: 'lol_1', relativeOffset: Offset.zero),
            ScrewHoleModel(id: 'lol_2', relativeOffset: const Offset(0, 60)),
          ],
        ),
      );
      plates.add(
        PlateModel(
          id: 'lat_outer_r',
          shapeType: PlateShapeType.linkBar3,
          size: const Size(32, 190),
          color: const Color(0xFF42A5F5),
          layer: 7.clamp(0, maxLayers),
          position: Offset(boardCenterX + 105, boardCenterY),
          holes: [
            ScrewHoleModel(id: 'lor_0', relativeOffset: const Offset(0, -60)),
            ScrewHoleModel(id: 'lor_1', relativeOffset: Offset.zero),
            ScrewHoleModel(id: 'lor_2', relativeOffset: const Offset(0, 60)),
          ],
        ),
      );
    }

    if (plateCount >= 28) {
      plates.add(
        PlateModel(
          id: 'lat_center_gem',
          shapeType: PlateShapeType.cogwheel,
          size: const Size(76, 76),
          color: const Color(0xFFFFD54F),
          layer: maxLayers,
          position: const Offset(boardCenterX, boardCenterY),
          holes: [
            ScrewHoleModel(id: 'lcg_0', relativeOffset: const Offset(-20, 0)),
            ScrewHoleModel(id: 'lcg_1', relativeOffset: const Offset(20, 0)),
          ],
        ),
      );
    }

    return GameState(
      level: level,
      plates: plates,
      activeBox: const ToolboxModel(targetColor: ScrewColor.purple),
      pendingBoxes: const [],
      waitingHoles: List.filled(5, null),
    );
  }

  static GameState _buildInterlockingCogwheelMatrix(int level, int plateCount, int maxLayers, Random rng) {
    final List<PlateModel> plates = [];
    final gearCount = plateCount.clamp(5, 18);

    final positions = [
      const Offset(-55, -55),
      const Offset(55, -55),
      const Offset(-55, 55),
      const Offset(55, 55),
      const Offset(0, 0),
      const Offset(0, -90),
      const Offset(0, 90),
      const Offset(-90, 0),
      const Offset(90, 0),
      const Offset(0, -130),
      const Offset(0, 130),
      const Offset(-130, 0),
      const Offset(130, 0),
      const Offset(-90, -90),
      const Offset(90, -90),
      const Offset(-90, 90),
      const Offset(90, 90),
      const Offset(0, -50),
    ];

    for (int i = 0; i < gearCount; i++) {
      final pos = Offset(boardCenterX + positions[i].dx, boardCenterY + positions[i].dy);
      final rad = (i == 4) ? 84.0 : ((i % 2 == 0) ? 76.0 : 68.0);
      final layer = i % max<int>(1, maxLayers - 1);

      plates.add(
        PlateModel(
          id: 'gear_$i',
          shapeType: PlateShapeType.cogwheel,
          size: Size(rad, rad),
          color: platePalette[(i * 3 + level) % platePalette.length],
          layer: layer,
          position: pos,
          holes: [
            ScrewHoleModel(id: 'g_${i}_0', relativeOffset: Offset(-rad * 0.26, -rad * 0.12)),
            ScrewHoleModel(id: 'g_${i}_1', relativeOffset: Offset(rad * 0.26, rad * 0.12)),
          ],
        ),
      );
    }

    plates.add(
      PlateModel(
        id: 'gear_cross_key',
        shapeType: PlateShapeType.linkBar4,
        size: const Size(220, 34),
        color: const Color(0xFFFFB300),
        layer: maxLayers,
        position: const Offset(boardCenterX, boardCenterY),
        angle: 0.0,
        holes: [
          ScrewHoleModel(id: 'gck_0', relativeOffset: const Offset(-80, 0)),
          ScrewHoleModel(id: 'gck_1', relativeOffset: const Offset(-26, 0)),
          ScrewHoleModel(id: 'gck_2', relativeOffset: const Offset(26, 0)),
          ScrewHoleModel(id: 'gck_3', relativeOffset: const Offset(80, 0), slotType: ScrewSlotType.star),
        ],
      ),
    );

    if (plateCount >= 14) {
      plates.add(
        PlateModel(
          id: 'gear_vert_key',
          shapeType: PlateShapeType.linkBar4,
          size: const Size(34, 220),
          color: const Color(0xFF00E5FF),
          layer: maxLayers,
          position: const Offset(boardCenterX, boardCenterY),
          holes: [
            ScrewHoleModel(id: 'gvk_0', relativeOffset: const Offset(0, -80)),
            ScrewHoleModel(id: 'gvk_1', relativeOffset: const Offset(0, -26)),
            ScrewHoleModel(id: 'gvk_2', relativeOffset: const Offset(0, 26)),
            ScrewHoleModel(id: 'gvk_3', relativeOffset: const Offset(0, 80)),
          ],
        ),
      );
    }

    return GameState(
      level: level,
      plates: plates,
      activeBox: const ToolboxModel(targetColor: ScrewColor.yellow),
      pendingBoxes: const [],
      waitingHoles: List.filled(5, null),
    );
  }

  static GameState _buildCornerLabyrinthBrackets(int level, int plateCount, int maxLayers, Random rng) {
    final List<PlateModel> plates = [];
    final count = (4 + (plateCount ~/ 2.5)).floor().clamp(4, 16);

    for (int i = 0; i < count; i++) {
      final quad = i % 4;
      final ring = i ~/ 4;
      final dist = (34.0 + ring * 32.0).clamp(34.0, 115.0);
      final angle = (quad * pi / 2);
      final pos = Offset(boardCenterX + cos(angle + pi / 4) * dist, boardCenterY + sin(angle + pi / 4) * dist);
      final size = (130.0 - ring * 12.0).clamp(80.0, 130.0);

      plates.add(
        PlateModel(
          id: 'l_bracket_$i',
          shapeType: PlateShapeType.lBracket,
          size: Size(size, size),
          color: platePalette[(i * 2 + level) % platePalette.length],
          layer: i % max<int>(1, maxLayers - 1),
          position: pos,
          angle: angle,
          holes: [
            ScrewHoleModel(id: 'lb_${i}_corner', relativeOffset: Offset(-size * 0.30, size * 0.30)),
            ScrewHoleModel(id: 'lb_${i}_v', relativeOffset: Offset(-size * 0.30, -size * 0.30)),
            ScrewHoleModel(id: 'lb_${i}_h', relativeOffset: Offset(size * 0.30, size * 0.30)),
          ],
        ),
      );
    }

    plates.add(
      PlateModel(
        id: 'l_center_disc',
        shapeType: PlateShapeType.cogwheel,
        size: const Size(84, 84),
        color: const Color(0xFFE91E63),
        layer: maxLayers,
        position: const Offset(boardCenterX, boardCenterY),
        holes: [
          ScrewHoleModel(id: 'lcd_0', relativeOffset: const Offset(-22, 0), slotType: ScrewSlotType.star),
          ScrewHoleModel(id: 'lcd_1', relativeOffset: const Offset(22, 0)),
        ],
      ),
    );

    if (plateCount >= 18) {
      plates.add(
        PlateModel(
          id: 'l_diag_cross',
          shapeType: PlateShapeType.linkBar3,
          size: const Size(200, 32),
          color: const Color(0xFF00E676),
          layer: maxLayers,
          position: const Offset(boardCenterX, boardCenterY),
          angle: pi / 4,
          holes: [
            ScrewHoleModel(id: 'ldc_0', relativeOffset: const Offset(-65, 0)),
            ScrewHoleModel(id: 'ldc_1', relativeOffset: Offset.zero),
            ScrewHoleModel(id: 'ldc_2', relativeOffset: const Offset(65, 0)),
          ],
        ),
      );
    }

    return GameState(
      level: level,
      plates: plates,
      activeBox: const ToolboxModel(targetColor: ScrewColor.coral),
      pendingBoxes: const [],
      waitingHoles: List.filled(5, null),
    );
  }

  static GameState _buildCantileverTrussBridge(int level, int plateCount, int maxLayers, Random rng) {
    final List<PlateModel> plates = [];
    final tCount = (4 + (plateCount ~/ 3)).clamp(4, 12);

    for (int i = 0; i < tCount; i++) {
      final yOff = (i - (tCount - 1) / 2) * (180.0 / max(1, tCount - 1)).clamp(28.0, 44.0);
      final isFlipped = i % 2 == 1;

      plates.add(
        PlateModel(
          id: 'truss_t_$i',
          shapeType: PlateShapeType.tBracket,
          size: const Size(140, 95),
          color: platePalette[(i * 3 + level) % platePalette.length],
          layer: i % max<int>(1, maxLayers - 1),
          position: Offset(boardCenterX + (isFlipped ? 18 : -18), boardCenterY + yOff),
          angle: isFlipped ? pi : 0.0,
          holes: [
            ScrewHoleModel(id: 'tt_${i}_l', relativeOffset: const Offset(-44, -28)),
            ScrewHoleModel(id: 'tt_${i}_r', relativeOffset: const Offset(44, -28)),
            ScrewHoleModel(id: 'tt_${i}_stem', relativeOffset: const Offset(0, 28)),
          ],
        ),
      );
    }

    final sideBeams = (2 + (plateCount ~/ 8)).clamp(2, 4);
    for (int b = 0; b < sideBeams; b++) {
      final xOff = (b - (sideBeams - 1) / 2) * (180.0 / max(1, sideBeams - 1)).clamp(60.0, 105.0);
      plates.add(
        PlateModel(
          id: 'truss_beam_$b',
          shapeType: PlateShapeType.linkBar4,
          size: const Size(34, 215),
          color: platePalette[(tCount + b + level) % platePalette.length],
          layer: maxLayers,
          position: Offset(boardCenterX + xOff, boardCenterY),
          holes: [
            ScrewHoleModel(id: 'tb_${b}_0', relativeOffset: const Offset(0, -78)),
            ScrewHoleModel(id: 'tb_${b}_1', relativeOffset: const Offset(0, -25)),
            ScrewHoleModel(id: 'tb_${b}_2', relativeOffset: const Offset(0, 25), slotType: (b == 0) ? ScrewSlotType.star : ScrewSlotType.cross),
            ScrewHoleModel(id: 'tb_${b}_3', relativeOffset: const Offset(0, 78)),
          ],
        ),
      );
    }

    return GameState(
      level: level,
      plates: plates,
      activeBox: const ToolboxModel(targetColor: ScrewColor.lime),
      pendingBoxes: const [],
      waitingHoles: List.filled(5, null),
    );
  }

  static GameState _buildConcentricVaultFrames(int level, int plateCount, int maxLayers, Random rng) {
    final List<PlateModel> plates = [];
    final uCount = (3 + (plateCount ~/ 3)).clamp(3, 8);

    for (int i = 0; i < uCount; i++) {
      final size = (190.0 - i * 18.0).clamp(70.0, 190.0);
      final isFlipped = i % 2 == 1;

      plates.add(
        PlateModel(
          id: 'vault_u_$i',
          shapeType: PlateShapeType.uBracket,
          size: Size(size, size),
          color: platePalette[(i * 3 + level) % platePalette.length],
          layer: i % max<int>(1, maxLayers - 1),
          position: const Offset(boardCenterX, boardCenterY),
          angle: isFlipped ? pi : 0.0,
          holes: [
            ScrewHoleModel(id: 'vu_${i}_tl', relativeOffset: Offset(-size * 0.32, -size * 0.32)),
            ScrewHoleModel(id: 'vu_${i}_tr', relativeOffset: Offset(size * 0.32, -size * 0.32)),
            ScrewHoleModel(id: 'vu_${i}_bl', relativeOffset: Offset(-size * 0.32, size * 0.32)),
            ScrewHoleModel(id: 'vu_${i}_br', relativeOffset: Offset(size * 0.32, size * 0.32)),
          ],
        ),
      );
    }

    plates.add(
      PlateModel(
        id: 'vault_lock_bar1',
        shapeType: PlateShapeType.linkBar3,
        size: const Size(190, 34),
        color: const Color(0xFF00E5FF),
        layer: maxLayers,
        position: const Offset(boardCenterX, boardCenterY),
        angle: pi / 4,
        holes: [
          ScrewHoleModel(id: 'vlb1_0', relativeOffset: const Offset(-60, 0)),
          ScrewHoleModel(id: 'vlb1_1', relativeOffset: Offset.zero, slotType: ScrewSlotType.star),
          ScrewHoleModel(id: 'vlb1_2', relativeOffset: const Offset(60, 0)),
        ],
      ),
    );

    if (plateCount >= 10) {
      plates.add(
        PlateModel(
          id: 'vault_lock_bar2',
          shapeType: PlateShapeType.linkBar3,
          size: const Size(190, 34),
          color: const Color(0xFFFF5252),
          layer: maxLayers,
          position: const Offset(boardCenterX, boardCenterY),
          angle: -pi / 4,
          holes: [
            ScrewHoleModel(id: 'vlb2_0', relativeOffset: const Offset(-60, 0)),
            ScrewHoleModel(id: 'vlb2_1', relativeOffset: Offset.zero),
            ScrewHoleModel(id: 'vlb2_2', relativeOffset: const Offset(60, 0)),
          ],
        ),
      );
    }

    return GameState(
      level: level,
      plates: plates,
      activeBox: const ToolboxModel(targetColor: ScrewColor.blue),
      pendingBoxes: const [],
      waitingHoles: List.filled(5, null),
    );
  }

  static GameState _buildRadialClockMechanism(int level, int plateCount, int maxLayers, Random rng) {
    final List<PlateModel> plates = [];
    final spokeCount = (4 + (plateCount ~/ 2.5)).floor().clamp(4, 14);
    final spokeLen = (145.0 - (spokeCount > 8 ? 15.0 : 0.0));

    for (int i = 0; i < spokeCount; i++) {
      final angle = (i * 2 * pi) / spokeCount;
      final dist = (spokeCount > 8 && i % 2 == 1) ? 30.0 : 48.0;
      final pos = Offset(boardCenterX + cos(angle) * dist, boardCenterY + sin(angle) * dist);

      plates.add(
        PlateModel(
          id: 'rad_spoke_$i',
          shapeType: PlateShapeType.linkBar2,
          size: Size(32, spokeLen),
          color: platePalette[(i * 2 + level) % platePalette.length],
          layer: i % max<int>(1, maxLayers - 1),
          position: pos,
          angle: angle + pi / 2,
          holes: [
            ScrewHoleModel(id: 'rsp_${i}_in', relativeOffset: Offset(0, -spokeLen * 0.34)),
            ScrewHoleModel(id: 'rsp_${i}_out', relativeOffset: Offset(0, spokeLen * 0.34)),
          ],
        ),
      );
    }

    plates.add(
      PlateModel(
        id: 'rad_clock_disc',
        shapeType: PlateShapeType.cogwheel,
        size: const Size(88, 88),
        color: const Color(0xFFFFD54F),
        layer: maxLayers,
        position: const Offset(boardCenterX, boardCenterY),
        holes: [
          ScrewHoleModel(id: 'rcd_0', relativeOffset: const Offset(-24, 0)),
          ScrewHoleModel(id: 'rcd_1', relativeOffset: const Offset(24, 0), slotType: ScrewSlotType.star),
        ],
      ),
    );

    if (plateCount >= 16) {
      plates.add(
        PlateModel(
          id: 'rad_ring_bar',
          shapeType: PlateShapeType.linkBar4,
          size: const Size(200, 32),
          color: const Color(0xFFAB47BC),
          layer: maxLayers,
          position: const Offset(boardCenterX, boardCenterY),
          holes: [
            ScrewHoleModel(id: 'rrb_0', relativeOffset: const Offset(-70, 0)),
            ScrewHoleModel(id: 'rrb_1', relativeOffset: const Offset(-24, 0)),
            ScrewHoleModel(id: 'rrb_2', relativeOffset: const Offset(24, 0)),
            ScrewHoleModel(id: 'rrb_3', relativeOffset: const Offset(70, 0)),
          ],
        ),
      );
    }

    return GameState(
      level: level,
      plates: plates,
      activeBox: const ToolboxModel(targetColor: ScrewColor.pink),
      pendingBoxes: const [],
      waitingHoles: List.filled(5, null),
    );
  }

  static GameState _buildCurvedAnchorRibcage(int level, int plateCount, int maxLayers, Random rng) {
    final List<PlateModel> plates = [];
    final arcCount = (4 + (plateCount ~/ 2.8)).floor().clamp(4, 14);

    for (int i = 0; i < arcCount; i++) {
      final isFlipped = i % 2 == 1;
      final yOff = (i - (arcCount - 1) / 2) * (180.0 / max(1, arcCount - 1)).clamp(22.0, 44.0);

      plates.add(
        PlateModel(
          id: 'rib_arc_$i',
          shapeType: PlateShapeType.curvedArc,
          size: const Size(180, 95),
          color: platePalette[(i * 3 + level) % platePalette.length],
          layer: i % max<int>(1, maxLayers - 1),
          position: Offset(boardCenterX, boardCenterY + yOff),
          angle: isFlipped ? pi : 0.0,
          holes: [
            ScrewHoleModel(id: 'ra_${i}_l', relativeOffset: const Offset(-60, -12)),
            ScrewHoleModel(id: 'ra_${i}_mid', relativeOffset: const Offset(0, -36)),
            ScrewHoleModel(id: 'ra_${i}_r', relativeOffset: const Offset(60, -12)),
          ],
        ),
      );
    }

    plates.add(
      PlateModel(
        id: 'rib_spine',
        shapeType: PlateShapeType.linkBar4,
        size: const Size(36, 220),
        color: const Color(0xFF00E676),
        layer: maxLayers,
        position: const Offset(boardCenterX, boardCenterY),
        holes: [
          ScrewHoleModel(id: 'rs_0', relativeOffset: const Offset(0, -82)),
          ScrewHoleModel(id: 'rs_1', relativeOffset: const Offset(0, -26)),
          ScrewHoleModel(id: 'rs_2', relativeOffset: const Offset(0, 26), slotType: ScrewSlotType.star),
          ScrewHoleModel(id: 'rs_3', relativeOffset: const Offset(0, 82)),
        ],
      ),
    );

    if (plateCount >= 14) {
      plates.add(
        PlateModel(
          id: 'rib_cross_lock',
          shapeType: PlateShapeType.linkBar3,
          size: const Size(190, 32),
          color: const Color(0xFFFF5252),
          layer: maxLayers,
          position: const Offset(boardCenterX, boardCenterY),
          holes: [
            ScrewHoleModel(id: 'rcl_0', relativeOffset: const Offset(-60, 0)),
            ScrewHoleModel(id: 'rcl_1', relativeOffset: Offset.zero),
            ScrewHoleModel(id: 'rcl_2', relativeOffset: const Offset(60, 0)),
          ],
        ),
      );
    }

    return GameState(
      level: level,
      plates: plates,
      activeBox: const ToolboxModel(targetColor: ScrewColor.cyan),
      pendingBoxes: const [],
      waitingHoles: List.filled(5, null),
    );
  }

  static GameState _buildSweetTreatsAssembly(int level, int plateCount, int maxLayers, Random rng) {
    final List<PlateModel> plates = [];

    plates.add(
      PlateModel(
        id: 'treat_cone',
        shapeType: PlateShapeType.iceCreamCone,
        size: const Size(150, 160),
        color: const Color(0xFFFFB74D),
        layer: 0,
        position: const Offset(boardCenterX, boardCenterY + 45),
        holes: [
          ScrewHoleModel(id: 'tc_0', relativeOffset: const Offset(-36, -30)),
          ScrewHoleModel(id: 'tc_1', relativeOffset: const Offset(36, -30)),
          ScrewHoleModel(id: 'tc_2', relativeOffset: const Offset(0, 40)),
        ],
      ),
    );

    plates.add(
      PlateModel(
        id: 'treat_scoop_l',
        shapeType: PlateShapeType.iceCreamScoopLeft,
        size: const Size(110, 100),
        color: const Color(0xFFF48FB1),
        layer: 1 % maxLayers,
        position: const Offset(boardCenterX - 35, boardCenterY - 45),
        holes: [
          ScrewHoleModel(id: 'tsl_0', relativeOffset: const Offset(-22, -18)),
          ScrewHoleModel(id: 'tsl_1', relativeOffset: const Offset(18, 18)),
        ],
      ),
    );

    plates.add(
      PlateModel(
        id: 'treat_scoop_r',
        shapeType: PlateShapeType.iceCreamScoopRight,
        size: const Size(110, 100),
        color: const Color(0xFF80DEEA),
        layer: 2 % maxLayers,
        position: const Offset(boardCenterX + 35, boardCenterY - 45),
        holes: [
          ScrewHoleModel(id: 'tsr_0', relativeOffset: const Offset(22, -18)),
          ScrewHoleModel(id: 'tsr_1', relativeOffset: const Offset(-18, 18), slotType: ScrewSlotType.star),
        ],
      ),
    );

    plates.add(
      PlateModel(
        id: 'treat_popsicle',
        shapeType: PlateShapeType.popsicleStick,
        size: const Size(34, 170),
        color: const Color(0xFFFFE082),
        layer: 3 % maxLayers,
        position: const Offset(boardCenterX, boardCenterY - 10),
        holes: [
          ScrewHoleModel(id: 'tp_0', relativeOffset: const Offset(0, -60)),
          ScrewHoleModel(id: 'tp_1', relativeOffset: const Offset(0, 0), slotType: ScrewSlotType.star),
          ScrewHoleModel(id: 'tp_2', relativeOffset: const Offset(0, 60)),
        ],
      ),
    );

    final extraBars = (plateCount - 4).clamp(0, 20);
    for (int i = 0; i < extraBars; i++) {
      final isHoriz = i % 2 == 0;
      final offsetStep = ((i ~/ 2) - (extraBars / 4)) * 32.0;
      final layer = (4 + i) % max<int>(1, maxLayers);

      plates.add(
        PlateModel(
          id: 'treat_bar_$i',
          shapeType: PlateShapeType.linkBar3,
          size: Size(isHoriz ? 170 : 34, isHoriz ? 34 : 170),
          color: platePalette[(i + 5 + level) % platePalette.length],
          layer: layer,
          position: Offset(boardCenterX + (isHoriz ? 0 : offsetStep), boardCenterY + (isHoriz ? offsetStep : 0)),
          holes: isHoriz
              ? [
                  ScrewHoleModel(id: 'tb_${i}_0', relativeOffset: const Offset(-55, 0)),
                  ScrewHoleModel(id: 'tb_${i}_1', relativeOffset: Offset.zero),
                  ScrewHoleModel(id: 'tb_${i}_2', relativeOffset: const Offset(55, 0)),
                ]
              : [
                  ScrewHoleModel(id: 'tb_${i}_0', relativeOffset: const Offset(0, -55)),
                  ScrewHoleModel(id: 'tb_${i}_1', relativeOffset: Offset.zero),
                  ScrewHoleModel(id: 'tb_${i}_2', relativeOffset: const Offset(0, 55)),
                ],
        ),
      );
    }

    return GameState(
      level: level,
      plates: plates,
      activeBox: const ToolboxModel(targetColor: ScrewColor.orange),
      pendingBoxes: const [],
      waitingHoles: List.filled(5, null),
    );
  }

  static GameState _buildHeartWingsMandala(int level, int plateCount, int maxLayers, Random rng) {
    final List<PlateModel> plates = [];

    plates.add(
      PlateModel(
        id: 'hw_heart_base',
        shapeType: PlateShapeType.heart,
        size: const Size(160, 150),
        color: const Color(0xFFFF5252),
        layer: 0,
        position: const Offset(boardCenterX, boardCenterY),
        holes: [
          ScrewHoleModel(id: 'hwh_0', relativeOffset: const Offset(-45, -30)),
          ScrewHoleModel(id: 'hwh_1', relativeOffset: const Offset(45, -30)),
          ScrewHoleModel(id: 'hwh_2', relativeOffset: const Offset(0, 38)),
        ],
      ),
    );

    plates.add(
      PlateModel(
        id: 'hw_wing_l',
        shapeType: PlateShapeType.linkBar3,
        size: const Size(140, 34),
        color: const Color(0xFFBA68C8),
        layer: 1 % maxLayers,
        position: const Offset(boardCenterX - 45, boardCenterY - 20),
        angle: -pi / 6,
        holes: [
          ScrewHoleModel(id: 'hwl_0', relativeOffset: const Offset(-45, 0)),
          ScrewHoleModel(id: 'hwl_1', relativeOffset: Offset.zero),
          ScrewHoleModel(id: 'hwl_2', relativeOffset: const Offset(45, 0)),
        ],
      ),
    );

    plates.add(
      PlateModel(
        id: 'hw_wing_r',
        shapeType: PlateShapeType.linkBar3,
        size: const Size(140, 34),
        color: const Color(0xFF4FC3F7),
        layer: 2 % maxLayers,
        position: const Offset(boardCenterX + 45, boardCenterY - 20),
        angle: pi / 6,
        holes: [
          ScrewHoleModel(id: 'hwr_0', relativeOffset: const Offset(-45, 0)),
          ScrewHoleModel(id: 'hwr_1', relativeOffset: Offset.zero),
          ScrewHoleModel(id: 'hwr_2', relativeOffset: const Offset(45, 0), slotType: ScrewSlotType.star),
        ],
      ),
    );

    plates.add(
      PlateModel(
        id: 'hw_center_star',
        shapeType: PlateShapeType.star,
        size: const Size(80, 80),
        color: const Color(0xFFFFD54F),
        layer: 3 % maxLayers,
        position: const Offset(boardCenterX, boardCenterY),
        holes: [
          ScrewHoleModel(id: 'hws_0', relativeOffset: const Offset(0, -18)),
          ScrewHoleModel(id: 'hws_1', relativeOffset: const Offset(0, 18), slotType: ScrewSlotType.star),
        ],
      ),
    );

    final extraWings = (plateCount - 4).clamp(0, 20);
    for (int w = 0; w < extraWings; w++) {
      final angle = (w * pi / (extraWings > 0 ? extraWings : 1)) + pi / 4;
      final dist = (35.0 + (w % 3) * 26.0).clamp(35.0, 95.0);
      final pos = Offset(boardCenterX + cos(angle) * dist, boardCenterY + sin(angle) * dist);
      final layer = (4 + w) % max<int>(1, maxLayers);

      plates.add(
        PlateModel(
          id: 'hw_extra_$w',
          shapeType: PlateShapeType.linkBar3,
          size: const Size(130, 32),
          color: platePalette[(w * 2 + level + 3) % platePalette.length],
          layer: layer,
          position: pos,
          angle: angle,
          holes: [
            ScrewHoleModel(id: 'hwe_${w}_0', relativeOffset: const Offset(-42, 0)),
            ScrewHoleModel(id: 'hwe_${w}_1', relativeOffset: Offset.zero),
            ScrewHoleModel(id: 'hwe_${w}_2', relativeOffset: const Offset(42, 0)),
          ],
        ),
      );
    }

    return GameState(
      level: level,
      plates: plates,
      activeBox: const ToolboxModel(targetColor: ScrewColor.purple),
      pendingBoxes: const [],
      waitingHoles: List.filled(5, null),
    );
  }

  static GameState _buildMasterCompoundMechanism(int level, int plateCount, int maxLayers, Random rng) {
    final List<PlateModel> plates = [];

    plates.add(
      PlateModel(
        id: 'mc_u_base',
        shapeType: PlateShapeType.uBracket,
        size: const Size(205, 205),
        color: const Color(0xFF455A64),
        layer: 0,
        position: const Offset(boardCenterX, boardCenterY),
        holes: [
          ScrewHoleModel(id: 'mcu_0', relativeOffset: const Offset(-70, -70)),
          ScrewHoleModel(id: 'mcu_1', relativeOffset: const Offset(70, -70)),
          ScrewHoleModel(id: 'mcu_2', relativeOffset: const Offset(-70, 70)),
          ScrewHoleModel(id: 'mcu_3', relativeOffset: const Offset(70, 70)),
        ],
      ),
    );

    plates.add(
      PlateModel(
        id: 'mc_t_mid',
        shapeType: PlateShapeType.tBracket,
        size: const Size(175, 135),
        color: const Color(0xFFFFB300),
        layer: 1 % maxLayers,
        position: const Offset(boardCenterX, boardCenterY - 12),
        holes: [
          ScrewHoleModel(id: 'mct_0', relativeOffset: const Offset(-58, -42)),
          ScrewHoleModel(id: 'mct_1', relativeOffset: const Offset(58, -42)),
          ScrewHoleModel(id: 'mct_2', relativeOffset: const Offset(0, 42)),
        ],
      ),
    );

    plates.add(
      PlateModel(
        id: 'mc_l_brace1',
        shapeType: PlateShapeType.lBracket,
        size: const Size(125, 125),
        color: const Color(0xFF00ACC1),
        layer: 2 % maxLayers,
        position: const Offset(boardCenterX - 35, boardCenterY + 35),
        holes: [
          ScrewHoleModel(id: 'mcl1_0', relativeOffset: const Offset(-40, 40)),
          ScrewHoleModel(id: 'mcl1_1', relativeOffset: const Offset(40, 40)),
          ScrewHoleModel(id: 'mcl1_2', relativeOffset: const Offset(-40, -40)),
        ],
      ),
    );

    plates.add(
      PlateModel(
        id: 'mc_l_brace2',
        shapeType: PlateShapeType.lBracket,
        size: const Size(125, 125),
        color: const Color(0xFFE53935),
        layer: 3 % maxLayers,
        position: const Offset(boardCenterX + 35, boardCenterY + 35),
        angle: pi / 2,
        holes: [
          ScrewHoleModel(id: 'mcl2_0', relativeOffset: const Offset(-40, 40)),
          ScrewHoleModel(id: 'mcl2_1', relativeOffset: const Offset(40, 40)),
          ScrewHoleModel(id: 'mcl2_2', relativeOffset: const Offset(-40, -40), slotType: ScrewSlotType.star),
        ],
      ),
    );

    plates.add(
      PlateModel(
        id: 'mc_cog_lock',
        shapeType: PlateShapeType.cogwheel,
        size: const Size(88, 88),
        color: const Color(0xFF7E57C2),
        layer: 4 % maxLayers,
        position: const Offset(boardCenterX, boardCenterY),
        holes: [
          ScrewHoleModel(id: 'mcg_0', relativeOffset: const Offset(-22, 0), slotType: ScrewSlotType.star),
          ScrewHoleModel(id: 'mcg_1', relativeOffset: const Offset(22, 0)),
        ],
      ),
    );

    final compoundExtras = (plateCount - 5).clamp(0, 22);
    for (int k = 0; k < compoundExtras; k++) {
      final isBar = k % 2 == 0;
      final angle = (k * pi / 4);
      final dist = (45.0 + (k % 3) * 28.0).clamp(45.0, 110.0);
      final pos = Offset(boardCenterX + cos(angle) * dist, boardCenterY + sin(angle) * dist);
      final layer = (5 + k) % max<int>(1, maxLayers);

      if (isBar) {
        plates.add(
          PlateModel(
            id: 'mc_extra_bar_$k',
            shapeType: PlateShapeType.linkBar3,
            size: const Size(140, 32),
            color: platePalette[(k * 3 + level + 4) % platePalette.length],
            layer: layer,
            position: pos,
            angle: angle,
            holes: [
              ScrewHoleModel(id: 'mceb_${k}_0', relativeOffset: const Offset(-45, 0)),
              ScrewHoleModel(id: 'mceb_${k}_1', relativeOffset: Offset.zero),
              ScrewHoleModel(id: 'mceb_${k}_2', relativeOffset: const Offset(45, 0)),
            ],
          ),
        );
      } else {
        plates.add(
          PlateModel(
            id: 'mc_extra_gear_$k',
            shapeType: PlateShapeType.cogwheel,
            size: const Size(68, 68),
            color: platePalette[(k * 2 + level + 1) % platePalette.length],
            layer: layer,
            position: pos,
            holes: [
              ScrewHoleModel(id: 'mgeg_${k}_0', relativeOffset: const Offset(-18, 0)),
              ScrewHoleModel(id: 'mgeg_${k}_1', relativeOffset: const Offset(18, 0)),
            ],
          ),
        );
      }
    }

    return GameState(
      level: level,
      plates: plates,
      activeBox: const ToolboxModel(targetColor: ScrewColor.orange),
      pendingBoxes: const [],
      waitingHoles: List.filled(5, null),
    );
  }

  static GameState _populateSolvableScrewsWithProgression(
    GameState blueprint,
    int level,
    Random rng, {
    int? numColorsOverride,
    double? swapRateOverride,
  }) {
    final sortedPlates = List<PlateModel>.from(blueprint.plates)
      ..sort((a, b) => b.layer.compareTo(a.layer));

    final allHoleRefs = <ScrewHoleModel>[];
    for (final plate in sortedPlates) {
      allHoleRefs.addAll(plate.holes);
    }

    final totalHoles = allHoleRefs.length;
    final numBoxes = max(2, (totalHoles / 3).floor());
    final activeScrewsCount = numBoxes * 3;

    final allAvailableColors = [
      ScrewColor.purple,
      ScrewColor.yellow,
      ScrewColor.blue,
      ScrewColor.lime,
      ScrewColor.coral,
      ScrewColor.pink,
      ScrewColor.orange,
      ScrewColor.cyan,
    ];

    final int numColorsToUse;
    if (numColorsOverride != null) {
      numColorsToUse = numColorsOverride.clamp(2, 8);
    } else if (level <= 3) {
      numColorsToUse = 2;
    } else if (level <= 10) {
      numColorsToUse = 3;
    } else if (level <= 40) {
      numColorsToUse = 4;
    } else if (level <= 120) {
      numColorsToUse = 5;
    } else if (level <= 350) {
      numColorsToUse = 6;
    } else if (level <= 700) {
      numColorsToUse = 7;
    } else {
      numColorsToUse = 8;
    }

    final palette = <ScrewColor>[];
    final colorPool = List<ScrewColor>.from(allAvailableColors);
    for (int i = 0; i < numColorsToUse; i++) {
      final pickIdx = (i * 3 + level * 5) % colorPool.length;
      palette.add(colorPool.removeAt(pickIdx));
    }

    final boxColors = <ScrewColor>[];
    for (int i = 0; i < numBoxes; i++) {
      boxColors.add(palette[i % palette.length]);
    }

    final screwBag = <ScrewColor>[];
    for (final color in boxColors) {
      screwBag.addAll([color, color, color]);
    }

    for (int i = 0; i < totalHoles; i++) {
      if (i < activeScrewsCount) {
        allHoleRefs[i].currentScrew = screwBag[i];
      } else {
        allHoleRefs[i].currentScrew = null;
      }
    }

    final swapWindow = (2 + (sqrt(level) * 0.15).floor()).clamp(2, 6);
    final swapRate = swapRateOverride ?? (0.15 + (sqrt(level) * 0.018)).clamp(0.15, 0.70);

    if (level >= 3 || swapRateOverride != null) {
      for (int i = 0; i < activeScrewsCount - 1; i++) {
        if (rng.nextDouble() < swapRate) {
          final nextIdx = min(activeScrewsCount - 1, i + 1 + rng.nextInt(swapWindow));
          final temp = allHoleRefs[i].currentScrew;
          allHoleRefs[i].currentScrew = allHoleRefs[nextIdx].currentScrew;
          allHoleRefs[nextIdx].currentScrew = temp;
        }
      }
    }

    final activeBox = ToolboxModel(targetColor: boxColors.first);
    final pendingBoxes = boxColors.sublist(1).map((c) => ToolboxModel(targetColor: c)).toList();

    return blueprint.copyWith(
      activeBox: activeBox,
      pendingBoxes: pendingBoxes,
    );
  }
}
