import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_theme.dart';
import '../models/game_models.dart';
import '../providers/theme_provider.dart';
import '../services/haptics.dart';
import '../services/storage_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late bool _hapticEnabled;

  @override
  void initState() {
    super.initState();
    _hapticEnabled = StorageService.getHapticEnabled();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);
    ref.watch(screwColorsProvider);

    return Scaffold(
      backgroundColor: currentTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: currentTheme.appBarFg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'SETTINGS',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: currentTheme.appBarFg,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
              child: Text(
                'GENERAL',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: currentTheme.textMuted,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: currentTheme.cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: currentTheme.border.withValues(alpha: 0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                title: Text(
                  'Haptic Feedback',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: currentTheme.textPrimary,
                  ),
                ),
                value: _hapticEnabled,
                activeThumbColor: currentTheme.switchActiveColor,
                onChanged: (value) {
                  setState(() => _hapticEnabled = value);
                  StorageService.setHapticEnabled(value);
                },
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
              child: Text(
                'THEME',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: currentTheme.textMuted,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: currentTheme.cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: currentTheme.border.withValues(alpha: 0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                children: AppThemes.all.map((theme) {
                  final isSelected = theme.id == currentTheme.id;
                  final isLast = theme.id == AppThemes.all.last.id;
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                        title: Text(
                          theme.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: currentTheme.textPrimary,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_rounded, color: currentTheme.switchActiveColor, size: 24)
                            : null,
                        onTap: () {
                          Haptics.select();
                          ref.read(themeProvider.notifier).setTheme(theme.id);
                        },
                      ),
                      if (!isLast)
                        Divider(
                          height: 1,
                          thickness: 1,
                          indent: 20,
                          endIndent: 20,
                          color: currentTheme.border.withValues(alpha: 0.2),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SCREW COLORS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: currentTheme.textMuted,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Haptics.select();
                      ref.read(screwColorsProvider.notifier).resetAll();
                    },
                    child: Text(
                      'Reset All',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: currentTheme.switchActiveColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: currentTheme.cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: currentTheme.border.withValues(alpha: 0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: ScrewColor.values.map((screwColor) {
                  return GestureDetector(
                    onTap: () {
                      Haptics.select();
                      _showScrewColorPicker(context, screwColor, currentTheme);
                    },
                    child: Center(
                      child: ScrewPreviewWidget(screwColor: screwColor, size: 44),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showScrewColorPicker(BuildContext context, ScrewColor screwColor, AppThemeData appTheme) {
    final initialColor = screwColor.primary;
    final initialHex = initialColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
    final controller = TextEditingController(text: initialHex);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: appTheme.dialogBg,
              title: Row(
                children: [
                  ScrewPreviewWidget(screwColor: screwColor, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    '${screwColor.label} Hex Color',
                    style: TextStyle(color: appTheme.textPrimary, fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  ScrewPreviewWidget(screwColor: screwColor, size: 64),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    maxLength: 6,
                    style: TextStyle(color: appTheme.textPrimary, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2.0),
                    decoration: InputDecoration(
                      prefixText: '# ',
                      prefixStyle: TextStyle(color: appTheme.textMuted, fontWeight: FontWeight.w900, fontSize: 18),
                      counterText: '',
                      filled: true,
                      fillColor: appTheme.surfaceVariant,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onChanged: (val) {
                      final clean = val.replaceAll('#', '').trim();
                      if (clean.length == 6) {
                        final parsed = int.tryParse('0xFF$clean');
                        if (parsed != null) {
                          ref.read(screwColorsProvider.notifier).setColor(screwColor, Color(parsed));
                          setDialogState(() {});
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Haptics.select();
                          ref.read(screwColorsProvider.notifier).resetColor(screwColor);
                          final defaultHex = screwColor.defaultPrimary.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
                          controller.text = defaultHex;
                          setDialogState(() {});
                        },
                        child: Text(
                          'Reset Default',
                          style: TextStyle(color: appTheme.textMuted, fontWeight: FontWeight.w800),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appTheme.switchActiveColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Haptics.select();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class ScrewPreviewWidget extends StatelessWidget {
  final ScrewColor screwColor;
  final double size;

  const ScrewPreviewWidget({
    super.key,
    required this.screwColor,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ScrewPreviewPainter(screwColor: screwColor),
    );
  }
}

class _ScrewPreviewPainter extends CustomPainter {
  final ScrewColor screwColor;

  _ScrewPreviewPainter({required this.screwColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final screwShadowPaint = Paint()
      ..color = screwColor.shadow
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(center + const Offset(0, 1.5), r, screwShadowPaint);

    final screwBodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.4),
        radius: 0.85,
        colors: [
          screwColor.highlight,
          screwColor.primary,
          screwColor.dark,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: r));

    canvas.drawCircle(center, r, screwBodyPaint);

    final borderScrew = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, r, borderScrew);

    final crossPaint = Paint()
      ..color = screwColor.dark
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = max(1.5, r * 0.2);

    final arm = r * 0.38;
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

  @override
  bool shouldRepaint(covariant _ScrewPreviewPainter oldDelegate) {
    return oldDelegate.screwColor.primary != screwColor.primary ||
        oldDelegate.screwColor.dark != screwColor.dark ||
        oldDelegate.screwColor.highlight != screwColor.highlight;
  }
}
