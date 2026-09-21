import 'package:flutter/material.dart';
import '../../core/glass/glass_button.dart';
import '../../core/glass/glass_sheet.dart';
import '../../core/glass/glass_surface.dart';
import '../../core/glass/glass_tier.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../domain/entities/cadence.dart';
import '../../domain/entities/work.dart';
import '../../domain/period/period_math.dart';

class WorkEditorSheet extends StatefulWidget {
  final Work? initialWork;
  final ValueChanged<Work> onSave;

  const WorkEditorSheet({
    super.key,
    this.initialWork,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    Work? initialWork,
    required ValueChanged<Work> onSave,
  }) {
    return GlassSheet.show(
      context: context,
      title: Text(
        initialWork == null ? 'New work' : 'Edit work',
        style: BrimTypography.title(
          Theme.of(context).extension<BrimColors>()?.text ?? Colors.white,
        ),
      ),
      child: WorkEditorSheet(
        initialWork: initialWork,
        onSave: onSave,
      ),
    );
  }

  @override
  State<WorkEditorSheet> createState() => _WorkEditorSheetState();
}

class _WorkEditorSheetState extends State<WorkEditorSheet> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late Cadence _cadence;
  late int _weekdayMask;
  late int _effort;
  late int _colorArgb;
  String? _dueDate;
  String? _errorMessage;

  final _colorsPalette = const [
    0xFF2EC4B6, // lagoon
    0xFFFF6B81, // coral
    0xFFFFC24B, // saffron
    0xFF9B8CFF, // orchid
    0xFF5BD68A, // kelp
    0xFF5AB8FF, // sky
    0xFFFF8FD0, // rose
    0xFFD9C5A0, // sand
  ];

  @override
  void initState() {
    super.initState();
    final w = widget.initialWork;
    _titleController = TextEditingController(text: w?.title ?? '');
    _notesController = TextEditingController(text: w?.notes ?? '');
    _cadence = w?.cadence ?? Cadence.daily;
    _weekdayMask = w?.weekdayMask ?? 127;
    _effort = w?.effort ?? 1;
    _colorArgb = w?.colorArgb ?? _colorsPalette[0];
    _dueDate = w?.dueDate ?? ymd(DateTime.now());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _errorMessage = 'Give this work a title.');
      return;
    }

    final now = DateTime.now();
    final work = (widget.initialWork ??
            Work(
              id: '',
              title: title,
              colorArgb: _colorArgb,
              cadence: _cadence,
              startDate: ymd(now),
              createdAt: now,
              updatedAt: now,
            ))
        .copyWith(
      title: title,
      notes: _notesController.text.trim(),
      cadence: _cadence,
      weekdayMask: _weekdayMask,
      effort: _effort,
      colorArgb: _colorArgb,
      dueDate: _cadence == Cadence.once ? _dueDate : null,
      updatedAt: now,
    );

    widget.onSave(work);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BrimColors>() ?? BrimColors.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Input
        Text('Title', style: BrimTypography.label(colors.textSoft)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: colors.track,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _errorMessage != null ? colors.coral : colors.rimSoft,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _titleController,
            style: BrimTypography.body(colors.text),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'e.g. Write thesis chapter',
              hintStyle: BrimTypography.body(colors.textSoft.withOpacity(0.5)),
            ),
            onChanged: (_) {
              if (_errorMessage != null) {
                setState(() => _errorMessage = null);
              }
            },
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 4),
          Text(_errorMessage!, style: BrimTypography.micro(colors.coral)),
        ],

        const SizedBox(height: 16),

        // Cadence Selector
        Text('Repeats', style: BrimTypography.label(colors.textSoft)),
        const SizedBox(height: 8),
        Row(
          children: Cadence.values.map((c) {
            final isSelected = _cadence == c;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: GestureDetector(
                  onTap: () => setState(() => _cadence = c),
                  child: GlassSurface(
                    shape: const GlassShape.capsule(),
                    tint: isSelected ? colors.lagoon : null,
                    tierOverride: GlassTier.frost,
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(
                      child: Text(
                        c.label,
                        style: BrimTypography.micro(
                          isSelected ? colors.text : colors.textSoft,
                        ).copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // Days selector (Daily only)
        if (_cadence == Cadence.daily) ...[
          const SizedBox(height: 16),
          Text('Active days', style: BrimTypography.label(colors.textSoft)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final bit = 1 << i;
              final isDayActive = (_weekdayMask & bit) != 0;
              final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _weekdayMask ^= bit;
                  });
                },
                child: GlassSurface(
                  width: 38,
                  height: 38,
                  shape: const GlassShape.circle(),
                  tint: isDayActive ? colors.lagoon : null,
                  tierOverride: GlassTier.frost,
                  child: Center(
                    child: Text(
                      dayNames[i],
                      style: BrimTypography.label(
                        isDayActive ? colors.text : colors.textSoft,
                      ).copyWith(
                        fontWeight:
                            isDayActive ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],

        // Due date picker for One-off
        if (_cadence == Cadence.once) ...[
          const SizedBox(height: 16),
          Text('Due date', style: BrimTypography.label(colors.textSoft)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (date != null) {
                setState(() => _dueDate = ymd(date));
              }
            },
            child: GlassSurface(
              shape: const GlassShape.capsule(),
              tierOverride: GlassTier.frost,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _dueDate ?? 'Select due date',
                    style: BrimTypography.body(colors.text),
                  ),
                  Icon(Icons.calendar_today, size: 16, color: colors.textSoft),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Color Palette
        Text('Color', style: BrimTypography.label(colors.textSoft)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _colorsPalette.map((c) {
            final isSelected = _colorArgb == c;
            return GestureDetector(
              onTap: () => setState(() => _colorArgb = c),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Color(c),
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 2.5)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Color(c).withOpacity(0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // Effort Weight (1..3)
        Text('Effort weight', style: BrimTypography.label(colors.textSoft)),
        const SizedBox(height: 8),
        Row(
          children: [1, 2, 3].map((eff) {
            final isSelected = _effort == eff;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: GestureDetector(
                  onTap: () => setState(() => _effort = eff),
                  child: GlassSurface(
                    shape: const GlassShape.capsule(),
                    tint: isSelected ? colors.lagoon : null,
                    tierOverride: GlassTier.frost,
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(
                      child: Text(
                        'Effort $eff',
                        style: BrimTypography.label(
                          isSelected ? colors.text : colors.textSoft,
                        ).copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // Notes Input
        Text('Notes', style: BrimTypography.label(colors.textSoft)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: colors.track,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.rimSoft),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _notesController,
            maxLines: 2,
            style: BrimTypography.body(colors.text),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Add description or key milestones...',
              hintStyle: BrimTypography.body(colors.textSoft.withOpacity(0.5)),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: GlassButton(
                label: 'Cancel',
                variant: GlassButtonVariant.neutral,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassButton(
                label: widget.initialWork == null ? 'Add work' : 'Save changes',
                variant: GlassButtonVariant.primary,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
