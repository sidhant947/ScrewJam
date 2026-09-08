import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_theme.dart';
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
          ],
        ),
      ),
    );
  }
}
