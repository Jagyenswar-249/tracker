import 'package:flutter/material.dart';
import '../../core/glass/glass_button.dart';
import '../../core/glass/glass_surface.dart';
import '../../core/glass/glass_tier.dart';
import '../../core/haptics/haptics.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/aurora_background.dart';
import '../../domain/entities/work.dart';
import '../tasks/widgets/progress_scrubber.dart';
import '../work_editor/work_editor_sheet.dart';

class WorkDetailPage extends StatefulWidget {
  final Work work;
  final int currentPercent;
  final ValueChanged<int> onPercentChanged;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const WorkDetailPage({
    super.key,
    required this.work,
    required this.currentPercent,
    required this.onPercentChanged,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  State<WorkDetailPage> createState() => _WorkDetailPageState();
}

class _WorkDetailPageState extends State<WorkDetailPage> {
  late int _percent;
  late Work _work;

  @override
  void initState() {
    super.initState();
    _percent = widget.currentPercent;
    _work = widget.work;
  }

  void _update(int val) {
    final clamped = val.clamp(0, 100);
    setState(() => _percent = clamped);
    widget.onPercentChanged(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BrimColors>() ?? BrimColors.dark;
    final workColor = Color(_work.colorArgb);

    return AuroraBackground(
      activeView: _work.cadence,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: colors.text,
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              color: colors.textSoft,
              onPressed: () {
                WorkEditorSheet.show(
                  context: context,
                  initialWork: _work,
                  onSave: (updated) {
                    setState(() => _work = updated);
                  },
                );
              },
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: colors.textSoft),
              color: colors.bgDeep,
              onSelected: (val) {
                if (val == 'archive') {
                  widget.onArchive();
                  Navigator.of(context).pop();
                } else if (val == 'delete') {
                  widget.onDelete();
                  Navigator.of(context).pop();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'archive',
                  child: Text('Archive work', style: TextStyle(color: colors.text)),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete work', style: TextStyle(color: colors.coral)),
                ),
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Sp.screenSidePadding,
            vertical: 12.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title & Category
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: workColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: workColor.withOpacity(0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _work.title,
                      style: BrimTypography.title(colors.text),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${_work.cadence.label}${_work.dueDate != null ? ' · due ${_work.dueDate}' : ''}',
                style: BrimTypography.body(colors.textSoft),
              ),

              const SizedBox(height: 28),

              // Huge Display Numeral
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$_percent',
                      style: BrimTypography.display(colors.text).copyWith(
                        fontSize: 64,
                      ),
                    ),
                    Text(
                      '%',
                      style: BrimTypography.title(colors.textSoft).copyWith(
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Signature Scrubber (Large 20dp track)
              ProgressScrubber(
                initialPercent: _percent,
                workColor: workColor,
                workTitle: _work.title,
                height: 20.0,
                onChangeEnd: _update,
              ),

              const SizedBox(height: 16),

              // Stepper Glass Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepperButton('-5', () => _update(_percent - 5), colors),
                  const SizedBox(width: 12),
                  _buildStepperButton('+5', () => _update(_percent + 5), colors),
                  const SizedBox(width: 12),
                  _buildStepperButton('Set 100%', () => _update(100), colors, isPrimary: true, color: colors.kelp),
                ],
              ),

              const SizedBox(height: 28),

              // History Sparkline Card (14 periods)
              GlassSurface(
                shape: const GlassShape.rounded(Rad.card),
                tint: workColor,
                tierOverride: GlassTier.frost,
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'History (last 14 periods)',
                      style: BrimTypography.headline(colors.text).copyWith(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 54,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(14, (i) {
                          // Mock historical trend bars
                          final pseudoVal = ((i * 19 + _work.title.length * 7) % 80) + 20;
                          final isCurrent = i == 13;
                          final val = isCurrent ? _percent : pseudoVal;
                          final fraction = (val / 100.0).clamp(0.0, 1.0);

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 14,
                                height: 44 * fraction,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  gradient: LinearGradient(
                                    colors: [
                                      isCurrent ? workColor : workColor.withOpacity(0.5),
                                      workColor.withOpacity(0.2),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Divider(color: colors.rimSoft, height: 1),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Avg 68%', style: BrimTypography.micro(colors.textSoft)),
                        Text('Best 100%', style: BrimTypography.micro(colors.textSoft)),
                        Text('Streak 5 periods', style: BrimTypography.micro(colors.textSoft)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Notes Card
              if (_work.notes.isNotEmpty) ...[
                GlassSurface(
                  shape: const GlassShape.rounded(Rad.card),
                  tierOverride: GlassTier.frost,
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes',
                        style: BrimTypography.headline(colors.text).copyWith(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _work.notes,
                        style: BrimTypography.body(colors.textSoft),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Actions Row
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'Archive',
                      variant: GlassButtonVariant.neutral,
                      onPressed: () {
                        widget.onArchive();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassButton(
                      label: 'Delete',
                      variant: GlassButtonVariant.destructive,
                      onPressed: () {
                        widget.onDelete();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepperButton(
    String label,
    VoidCallback onTap,
    BrimColors colors, {
    bool isPrimary = false,
    Color? color,
  }) {
    return GestureDetector(
      onTap: () {
        BrimHaptics.selectionClick();
        onTap();
      },
      child: GlassSurface(
        shape: const GlassShape.capsule(),
        tint: color ?? (isPrimary ? colors.lagoon : null),
        tierOverride: GlassTier.liquid,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          label,
          style: BrimTypography.label(colors.text).copyWith(
            fontWeight: FontWeight.w700,
            color: isPrimary ? Colors.white : colors.text,
          ),
        ),
      ),
    );
  }
}
