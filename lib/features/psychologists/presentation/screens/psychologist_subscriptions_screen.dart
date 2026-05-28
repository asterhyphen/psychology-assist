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
    final isDark = theme.brightness == Brightness.dark;

    return SmoothCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(18),
      backgroundColor: recommended
          ? accentColor.withValues(alpha: isDark ? 0.16 : 0.10)
          : accentColor.withValues(alpha: isDark ? 0.08 : 0.05),
      borderColor: recommended ? accentColor : accentColor.withValues(alpha: 0.24),
      borderWidth: recommended ? 2.0 : 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: AppTypography.headingSmall.copyWith(
                  color: recommended ? accentColor : theme.textTheme.titleMedium?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (recommended)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Recommended',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: AppTypography.headingLarge.copyWith(
                  color: isDark ? Colors.white : theme.textTheme.titleLarge?.color,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                interval,
                style: AppTypography.bodySmall.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.6)),

          const SizedBox(height: 18),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 18, color: accentColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      feature,
                      style: AppTypography.bodyMedium.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: SmoothButton(
              onPressed: () {},
              label: 'Select plan',
              backgroundColor: accentColor,
              textColor: Colors.white,
              borderRadius: 14,
            ),
          ),
        ],
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
