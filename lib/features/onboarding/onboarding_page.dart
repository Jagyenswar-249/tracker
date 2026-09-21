import 'package:flutter/material.dart';
import '../../core/glass/glass_button.dart';
import '../../core/glass/glass_surface.dart';
import '../../core/glass/glass_tier.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/aurora_background.dart';
import '../../domain/entities/cadence.dart';

class OnboardingPage extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingPage({super.key, required this.onFinish});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<BrimColors>() ?? BrimColors.dark;

    final pages = [
      (
        'Every work is a glass vessel.',
        'Drag horizontal bars to fill each work to the brim with fluid progress.',
        Icons.water_drop,
        colors.lagoon,
      ),
      (
        'See your day, week, and month.',
        'Automatic rollups give you clarity on what is done, what is left, and your streaks.',
        Icons.auto_graph,
        colors.saffron,
      ),
      (
        'Tactile Liquid Glass design.',
        'Crafted with refractive iOS-26 materials and specular rim highlights.',
        Icons.blur_on,
        colors.orchid,
      ),
    ];

    return AuroraBackground(
      activeView: Cadence.daily,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              children: [
                // Top Skip Button
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: widget.onFinish,
                    child: Text('Skip', style: BrimTypography.label(colors.textSoft)),
                  ),
                ),
                const Spacer(),

                // Animated Page View
                SizedBox(
                  height: 380,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (p) => setState(() => _currentPage = p),
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      final item = pages[index];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GlassSurface(
                            width: 120,
                            height: 120,
                            shape: const GlassShape.circle(),
                            tint: item.$4,
                            tierOverride: GlassTier.liquid,
                            child: Icon(item.$3, size: 54, color: item.$4),
                          ),
                          const SizedBox(height: 36),
                          Text(
                            item.$1,
                            textAlign: TextAlign.center,
                            style: BrimTypography.title(colors.text),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            item.$2,
                            textAlign: TextAlign.center,
                            style: BrimTypography.body(colors.textSoft).copyWith(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const Spacer(),

                // Page Indicator Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(pages.length, (i) {
                    final isSelected = _currentPage == i;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isSelected ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isSelected ? colors.lagoon : colors.rimSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 28),

                // Next / Get Started Button
                GlassButton(
                  label: _currentPage == pages.length - 1
                      ? 'Get Started'
                      : 'Continue',
                  variant: GlassButtonVariant.primary,
                  onPressed: () {
                    if (_currentPage < pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                      );
                    } else {
                      widget.onFinish();
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
