import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../game/screw_jam_game.dart';
import '../models/game_models.dart';
import '../providers/game_provider.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  ScrewJamGame? _game;
  double _baseZoom = 1.0;
  Offset _basePan = Offset.zero;
  Offset _startFocalPoint = Offset.zero;

  void _onScaleStart(ScaleStartDetails details) {
    if (_game == null) return;
    _baseZoom = _game!.userZoom;
    _basePan = _game!.userPan;
    _startFocalPoint = details.localFocalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_game == null) return;
    if (details.pointerCount > 1 || _baseZoom > 1.05) {
      final newZoom = (_baseZoom * details.scale).clamp(0.65, 3.0);
      final deltaPan = details.localFocalPoint - _startFocalPoint;
      final newPan = _basePan + deltaPan;
      setState(() {
        _game!.setZoomAndPan(newZoom, newPan);
      });
    }
  }

  void _resetZoom() {
    if (_game == null) return;
    setState(() {
      _game!.resetZoomAndPan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);

    _game ??= ScrewJamGame(
      notifier: notifier,
      currentState: gameState,
    );
    _game!.updateState(gameState);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF0F4F8),
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1E293B),
            elevation: 0.5,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: gameState.isRandom
                    ? (gameState.difficulty?.color.withValues(alpha: 0.15) ?? const Color(0xFFE2E8F0))
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                gameState.isRandom
                    ? 'RANDOM • ${gameState.difficulty?.label.toUpperCase() ?? "PUZZLE"}'
                    : 'LEVEL ${gameState.level}',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1.0,
                  color: gameState.isRandom
                      ? (gameState.difficulty?.darkColor ?? const Color(0xFF1E293B))
                      : const Color(0xFF1E293B),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.replay_rounded, color: Color(0xFF64748B), size: 24),
                onPressed: () {
                  _resetZoom();
                  notifier.restartCurrentLevel();
                },
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFF1F5F9),
                  Color(0xFFE2E8F0),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildToolboxConveyor(gameState),
                  const SizedBox(height: 14),
                  _buildWaitingTray(gameState),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onScaleStart: _onScaleStart,
                            onScaleUpdate: _onScaleUpdate,
                            onDoubleTap: _resetZoom,
                            child: ClipRect(
                              clipBehavior: Clip.none,
                              child: GameWidget(game: _game!),
                            ),
                          ),
                        ),
                        if (_game != null && (_game!.userZoom < 0.98 || _game!.userZoom > 1.02 || _game!.userPan != Offset.zero))
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _resetZoom,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B).withValues(alpha: 0.82),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.restart_alt_rounded, size: 16, color: Colors.white),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${(_game!.userZoom * 100).round()}%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (gameState.status == GameStatus.won)
          _buildEndOverlay(
            title: gameState.isRandom ? 'PUZZLE COMPLETED!' : 'LEVEL COMPLETED!',
            subtitle: 'WELL DONE!',
            buttonText: gameState.isRandom ? 'NEW PUZZLE' : 'NEXT LEVEL',
            isWin: true,
            onPressed: () {
              notifier.nextLevel();
            },
          ),
        if (gameState.status == GameStatus.lost)
          _buildEndOverlay(
            title: 'OUT OF SLOTS!',
            subtitle: 'No more empty slots available',
            buttonText: 'TRY AGAIN',
            isWin: false,
            onPressed: () {
              notifier.restartCurrentLevel();
            },
          ),
      ],
    );
  }

  Widget _buildToolboxConveyor(GameState state) {
    final activeBox = state.activeBox;
    final pendingBoxes = state.pendingBoxes;

    return SizedBox(
      width: double.infinity,
      height: 74,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (pendingBoxes.isNotEmpty)
            Positioned(
              left: -48,
              top: 10,
              child: _buildMiniPendingBox(pendingBoxes.first),
            ),
          Center(
            child: _buildMainToolbox(activeBox),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPendingBox(ToolboxModel box) {
    final color = box.targetColor;
    return Container(
      width: 85,
      height: 52,
      decoration: BoxDecoration(
        color: color.primary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.dark, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: color.shadow,
            offset: const Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 44,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFCBD5E1),
                border: Border.all(color: const Color(0xFF94A3B8), width: 1.5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainToolbox(ToolboxModel box) {
    final color = box.targetColor;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          top: -8,
          child: Container(
            width: 48,
            height: 16,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              border: Border.all(color: const Color(0xFF94A3B8), width: 2.0),
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 165,
          height: 58,
          decoration: BoxDecoration(
            color: color.primary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.dark, width: 3.0),
            boxShadow: [
              BoxShadow(
                color: color.shadow,
                offset: const Offset(0, 5),
                blurRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                offset: const Offset(0, 8),
                blurRadius: 8,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(box.capacity, (index) {
                final isFilled = index < box.collected.length;
                return AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: isFilled ? 1.05 : 1.0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled ? color.primary : const Color(0xFFE2E8F0),
                      border: Border.all(
                        color: isFilled ? color.dark : const Color(0xFF94A3B8),
                        width: 1.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isFilled ? color.shadow : Colors.black12,
                          offset: const Offset(0, 2),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: isFilled
                        ? Center(
                            child: Icon(
                              Icons.close_rounded,
                              size: 15,
                              color: color.dark,
                            ),
                          )
                        : null,
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingTray(GameState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF94A3B8), width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 3),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(state.waitingHoles.length, (index) {
          final screw = state.waitingHoles[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF94A3B8),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 2.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: screw != null
                  ? Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: screw.primary,
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: screw.shadow,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: screw.dark,
                        ),
                      ),
                    )
                  : Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF64748B),
                      ),
                    ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEndOverlay({
    required String title,
    required String subtitle,
    required String buttonText,
    required bool isWin,
    required VoidCallback onPressed,
  }) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: Colors.black.withValues(alpha: 0.65),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isWin) ...[
                  const Icon(
                    Icons.sentiment_dissatisfied_rounded,
                    color: Color(0xFFEF4444),
                    size: 64,
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: isWin ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isWin ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF475569),
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: Color(0xFFCBD5E1), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'HOME',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => launchUrl(
                    Uri.parse('https://ko-fi.com/sidhant947'),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.coffee_rounded, size: 20, color: Color(0xFFFF5E5B)),
                  label: const Text(
                    'Buy me a coffee',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: Color(0xFF475569),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: Color(0xFFCBD5E1), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
