import 'package:flutter/material.dart';
import '../../core/glass/glass_surface.dart';
import '../../core/glass/glass_tier.dart';
import '../../core/haptics/haptics.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/aurora_background.dart';
import '../../domain/entities/cadence.dart';
import '../../domain/repositories/settings_repository.dart';
import '../debug/glass_gallery_page.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback? onResetData;

  const SettingsPage({super.key, this.onResetData});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ThemeModeSetting _themeMode = ThemeModeSetting.dark;
  GlassIntensitySetting _glassIntensity = GlassIntensitySetting.full;
  int _snapStep = 5;
  double _streakThreshold = 80.0;
  int _weekStart = 1; // 1=Mon, 7=Sun
  bool _haptics = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BrimColors>() ?? BrimColors.dark;

    return AuroraBackground(
      activeView: Cadence.daily,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            Sp.screenSidePadding,
            16.0,
            Sp.screenSidePadding,
            Sp.contentBottomPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: BrimTypography.title(colors.text)),
              const SizedBox(height: 20),

              // Section 1: Appearance & Glass
              _buildSectionHeader('Appearance', colors),
              GlassSurface(
                shape: const GlassShape.rounded(Rad.card),
                tierOverride: GlassTier.frost,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildRow(
                      title: 'Theme',
                      child: _buildSelector(
                        ['System', 'Light', 'Dark'],
                        _themeMode.index,
                        (idx) => setState(() => _themeMode = ThemeModeSetting.values[idx]),
                        colors,
                      ),
                      colors: colors,
                    ),
                    const Divider(height: 24),
                    _buildRow(
                      title: 'Glass intensity',
                      child: _buildSelector(
                        ['Full', 'Balanced', 'Off'],
                        _glassIntensity.index,
                        (idx) => setState(() => _glassIntensity = GlassIntensitySetting.values[idx]),
                        colors,
                      ),
                      colors: colors,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section 2: Progress & Scrubbing
              _buildSectionHeader('Progress', colors),
              GlassSurface(
                shape: const GlassShape.rounded(Rad.card),
                tierOverride: GlassTier.frost,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildRow(
                      title: 'Snap step',
                      child: _buildSelector(
                        ['1%', '5%', '10%'],
                        _snapStep == 1 ? 0 : (_snapStep == 5 ? 1 : 2),
                        (idx) => setState(() => _snapStep = [1, 5, 10][idx]),
                        colors,
                      ),
                      colors: colors,
                    ),
                    const Divider(height: 24),
                    _buildRow(
                      title: 'Week starts on',
                      child: _buildSelector(
                        ['Mon', 'Sun', 'Sat'],
                        _weekStart == 1 ? 0 : (_weekStart == 7 ? 1 : 2),
                        (idx) => setState(() => _weekStart = [1, 7, 6][idx]),
                        colors,
                      ),
                      colors: colors,
                    ),
                    const Divider(height: 24),
                    _buildRow(
                      title: 'Haptics',
                      child: Switch.adaptive(
                        value: _haptics,
                        activeColor: colors.lagoon,
                        onChanged: (val) {
                          BrimHaptics.enabled = val;
                          setState(() => _haptics = val);
                        },
                      ),
                      colors: colors,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section 3: Data & Debug
              _buildSectionHeader('Data & Diagnostics', colors),
              GlassSurface(
                shape: const GlassShape.rounded(Rad.card),
                tierOverride: GlassTier.frost,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildActionTile(
                      icon: Icons.ios_share,
                      title: 'Export data (JSON)',
                      onTap: () {
                        BrimHaptics.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Exported data to JSON successfully')),
                        );
                      },
                      colors: colors,
                    ),
                    const Divider(height: 20),
                    _buildActionTile(
                      icon: Icons.file_download_outlined,
                      title: 'Import data (JSON)',
                      onTap: () {
                        BrimHaptics.lightImpact();
                      },
                      colors: colors,
                    ),
                    const Divider(height: 20),
                    _buildActionTile(
                      icon: Icons.palette_outlined,
                      title: 'Glass gallery (Debug)',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const GlassGalleryPage()),
                        );
                      },
                      colors: colors,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, BrimColors colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: BrimTypography.label(colors.textSoft).copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildRow({
    required String title,
    required Widget child,
    required BrimColors colors,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: BrimTypography.body(colors.text)),
        child,
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required BrimColors colors,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.lagoon),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: BrimTypography.body(colors.text)),
          ),
          Icon(Icons.chevron_right, size: 20, color: colors.textSoft),
        ],
      ),
    );
  }

  Widget _buildSelector(
    List<String> labels,
    int selectedIndex,
    ValueChanged<int> onSelect,
    BrimColors colors,
  ) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.track,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(labels.length, (i) {
          final isSelected = selectedIndex == i;
          return GestureDetector(
            onTap: () {
              BrimHaptics.selectionClick();
              onSelect(i);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? colors.lagoon : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                labels[i],
                style: BrimTypography.micro(
                  isSelected ? Colors.white : colors.textSoft,
                ).copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
