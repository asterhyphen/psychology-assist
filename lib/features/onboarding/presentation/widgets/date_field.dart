part of '../screens/onboarding_screen.dart';

class _DateField extends StatelessWidget {
  final DateTime? date;
  final VoidCallback onTap;

  const _DateField({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = date == null
        ? 'Select date of birth'
        : '${date!.day}/${date!.month}/${date!.year}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date of birth', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: AppColors.lightDivider,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.cake_outlined, color: AppColors.neonViolet),
                const SizedBox(width: 12),
                Text(text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
