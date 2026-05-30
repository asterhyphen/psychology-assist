import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/smooth_widgets.dart';

class PsychologistSubscriptionsScreen extends StatelessWidget {
  const PsychologistSubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions'),
        centerTitle: true,
      ),
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your psychiatric practice subscription',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Choose a plan for more patient tools, advanced scheduling, and priority support.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.mutedText,
                  ),
                ),
                const SizedBox(height: 24),
                const _SubscriptionCard(
                  title: 'Starter',
                  price: '\$29',
                  interval: 'per month',
                  features: [
                    'Up to 20 patient sessions',
                    'Basic appointment management',
                    'Email support',
                  ],
                  accentColor: AppColors.neonCyan,
                ),
                const SizedBox(height: 16),
                const _SubscriptionCard(
                  title: 'Professional',
                  price: '\$59',
                  interval: 'per month',
                  features: [
                    'Unlimited patient sessions',
                    'Advanced notes & analytics',
                    'Priority scheduling tools',
                    'Phone + chat support',
                  ],
                  accentColor: AppColors.neonViolet,
                  recommended: true,
                ),
                const SizedBox(height: 16),
                const _SubscriptionCard(
                  title: 'Premium',
                  price: '\$99',
                  interval: 'per month',
                  features: [
                    'All Professional features',
                    'Dedicated onboarding',
                    'Practice growth reports',
                    'Patient waiting list automation',
                  ],
                  accentColor: AppColors.success,
                ),
                const SizedBox(height: 24),
                Text(
                  'Why upgrade?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                const _BenefitTile(
                  icon: Icons.lock_outline,
                  label: 'Secure patient notes',
                ),
                const _BenefitTile(
                  icon: Icons.speed,
                  label: 'Faster workflow across your practice',
                ),
                const _BenefitTile(
                  icon: Icons.star_border,
                  label: 'Higher visibility for new patients',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final String title;
  final String price;
  final String interval;
  final List<String> features;
  final Color accentColor;
  final bool recommended;

  const _SubscriptionCard({
    required this.title,
    required this.price,
    required this.interval,
    required this.features,
    required this.accentColor,
    this.recommended = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final hasGradient = recommended;
    final cardBg = recommended
        ? (isDark
            ? const Color(0xFF162032).withValues(alpha: 0.88)
            : const Color(0xFFF5F3FF).withValues(alpha: 0.94))
        : (isDark
            ? const Color(0xFF111724).withValues(alpha: 0.84)
            : scheme.surface.withValues(alpha: 0.92));

    final effectiveBorder = recommended
        ? Border.all(color: const Color(0xFF8B5CF6), width: 2.2)
        : Border.all(color: accentColor.withValues(alpha: 0.28), width: 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: recommended
            ? [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                  blurRadius: 24,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: cardBg,
              border: effectiveBorder,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        title.toUpperCase(),
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 10.5,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (recommended)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF22D3EE)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'RECOMMENDED',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 9.5,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: isDark ? Colors.white : theme.textTheme.titleLarge?.color,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        interval,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.3)),
                const SizedBox(height: 18),
                ...features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentColor.withValues(alpha: 0.16),
                          ),
                          child: Icon(Icons.check, size: 13, color: accentColor),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            feature,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white.withValues(alpha: 0.82) : Colors.black.withValues(alpha: 0.78),
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: SmoothButton(
                    onPressed: () {},
                    label: 'Select Plan',
                    backgroundColor: recommended ? const Color(0xFF8B5CF6) : accentColor,
                    textColor: Colors.white,
                    borderRadius: 12,
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

class _BenefitTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BenefitTile({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
