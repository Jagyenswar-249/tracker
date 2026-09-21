import 'package:flutter/material.dart';
import '../../../core/haptics/haptics.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/glass/glass_surface.dart';
import '../../../core/glass/glass_tier.dart';

enum TaskFilter { all, active, done, overdue }

class FilterChips extends StatelessWidget {
  final TaskFilter selected;
  final ValueChanged<TaskFilter> onSelected;

  const FilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BrimColors>() ?? BrimColors.dark;

    final filters = [
      (TaskFilter.all, 'All'),
      (TaskFilter.active, 'Active'),
      (TaskFilter.done, 'Done'),
      (TaskFilter.overdue, 'Overdue'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: filters.map((f) {
          final isSelected = selected == f.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                BrimHaptics.selectionClick();
                onSelected(f.$1);
              },
              child: GlassSurface(
                shape: const GlassShape.capsule(),
                tint: isSelected ? colors.lagoon : null,
                tierOverride: GlassTier.frost,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 6.0,
                ),
                child: Text(
                  f.$2,
                  style: BrimTypography.label(
                    isSelected ? colors.text : colors.textSoft,
                  ).copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
