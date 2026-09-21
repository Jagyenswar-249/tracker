import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/theme/typography.dart';
import '../../../core/glass/glass_surface.dart';
import '../../../core/glass/glass_tier.dart';
import '../../../domain/entities/period_snapshot.dart';
import 'progress_scrubber.dart';

class WorkCard extends StatelessWidget {
  final WorkWithProgress item;
  final ValueChanged<int> onPercentChanged;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const WorkCard({
    super.key,
    required this.item,
    required this.onPercentChanged,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BrimColors>() ?? BrimColors.dark;
    final work = item.work;
    final workColor = Color(work.colorArgb);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        child: GlassSurface(
          shape: const GlassShape.rounded(Rad.card),
          tint: workColor,
          tierOverride: GlassTier.frost,
          padding: const EdgeInsets.fromLTRB(18.0, 16.0, 18.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Title, Schedule/Category & Badges
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Color dot
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 6, right: 10),
                    decoration: BoxDecoration(
                      color: workColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: workColor.withOpacity(0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),

                  // Title and Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          work.title,
                          style: BrimTypography.headline(colors.text).copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: item.isDone
                                ? TextDecoration.none
                                : TextDecoration.none,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          work.notes.isNotEmpty
                              ? work.notes
                              : '${work.cadence.label}${work.dueDate != null ? ' · due ${work.dueDate}' : ''}',
                          style: BrimTypography.label(colors.textSoft),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Overdue or Done badge
                  if (item.isOverdue)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        color: colors.coral.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: colors.coral, width: 1.0),
                      ),
                      child: Text(
                        'Overdue',
                        style: BrimTypography.micro(colors.coral).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else if (item.isDone)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        color: colors.kelp.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: colors.kelp, width: 1.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, size: 12, color: colors.kelp),
                          const SizedBox(width: 3),
                          Text(
                            'Done',
                            style: BrimTypography.micro(colors.kelp).copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              // Bottom Row: Scrubber + Percent Display
              Row(
                children: [
                  Expanded(
                    child: ProgressScrubber(
                      initialPercent: item.percent,
                      workColor: workColor,
                      workTitle: work.title,
                      onChangeEnd: onPercentChanged,
                    ),
                  ),
                  const SizedBox(width: 14),
                  SizedBox(
                    width: 44,
                    child: Text(
                      '${item.percent}%',
                      textAlign: TextAlign.end,
                      style: BrimTypography.label(colors.text).copyWith(
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
