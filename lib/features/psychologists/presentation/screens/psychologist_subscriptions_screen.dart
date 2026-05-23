import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/smooth_widgets.dart';

class PsychologistSubscriptionsScreen extends StatelessWidget {
  const PsychologistSubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions'),
        centerTitle: true,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your psychiatric practice subscription',
                  style: AppTypography.headingLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  'Choose a plan for more patient tools, advanced scheduling, and priority support.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.lightSubtext,
                  ),
                ),
                const SizedBox(height: 24),
                _SubscriptionCard(
                  title: 'Starter',
                  price: '4B0 29',
                  interval: 'per month',
                  features: [
                    'Up to 20 patient sessions',
                    'Basic appointment management',
                    'Email support',
                  ],
                  accentColor: AppColors.neonCyan,
                ),
                const SizedBox(height: 16),
                _SubscriptionCard(
                  title: 'Professional',
                  price: '4B0 59',
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
                _SubscriptionCard(
                  title: 'Premium',
                  price: '4B0 99',
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
                  style: AppTypography.headingMedium,
                ),
                const SizedBox(height: 12),
                _BenefitTile(
                  icon: Icons.lock_outline,
                  label: 'Secure patient notes',
                ),
                _BenefitTile(
                  icon: Icons.speed,
                  label: 'Faster workflow across your practice',
                ),
                _BenefitTile(
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
    return SmoothCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(18),
      backgroundColor: accentColor.withOpacity(0.07),
      borderColor: accentColor.withOpacity(0.18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: AppTypography.labelLarge.copyWith(
                  color: accentColor,
                ),
              ),
              const Spacer(),
              if (recommended)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Recommended',
                    style: AppTypography.labelSmall.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w700,
                    ),
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
                style: AppTypography.headingMedium.copyWith(
                  color: accentColor,
                  fontSize: 32,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                interval,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.lightSubtext,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 18, color: accentColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      feature,
                      style: AppTypography.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Select plan'),
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
