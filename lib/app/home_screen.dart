import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/journaling/presentation/screens/journaling_screen.dart';
import '../features/appointments/presentation/screens/appointments_screen.dart';
import '../features/psychologists/presentation/screens/psychologists_screen.dart';
import '../features/psychologists/presentation/screens/psychologist_subscriptions_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/wellness_tools/presentation/screens/wellness_tools_screen.dart';
import 'app_state.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);

    final isPsychologist =
        ref.watch(appSessionProvider).profile?.role == UserRole.psychologist;

    final pages = isPsychologist
        ? [
            const PsychologistsScreen(),
            const PsychologistSubscriptionsScreen(),
            const SettingsScreen(),
          ]
        : [
            const DashboardScreen(),
            const WellnessToolsScreen(),
            const JournalingScreen(),
            const AppointmentsScreen(),
            const SettingsScreen(),
          ];

    // Ensure selectedTab is within bounds
    final currentIndex = selectedTab >= pages.length ? 0 : selectedTab;

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: _PillBottomNavigation(
        selectedIndex: currentIndex,
        isPsychologist: isPsychologist,
        onTap: (index) {
          ref.read(selectedTabProvider.notifier).state = index;
        },
      ),
    );
  }
}

class _PillBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final bool isPsychologist;
  final ValueChanged<int> onTap;

  const _PillBottomNavigation({
    required this.selectedIndex,
    required this.isPsychologist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surface.withValues(alpha: 0.92)
            : scheme.surface.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: isDark ? 0.12 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: scheme.primary.withValues(alpha: isDark ? 0.12 : 0.08),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: isPsychologist
            ? [
                _NavItem(
                  icon: Icons.space_dashboard_outlined,
                  activeIcon: Icons.space_dashboard,
                  label: 'Dashboard',
                  isSelected: selectedIndex == 0,
                  onTap: () => onTap(0),
                ),
                _NavItem(
                  icon: Icons.subscriptions_outlined,
                  activeIcon: Icons.subscriptions,
                  label: 'Subscriptions',
                  isSelected: selectedIndex == 1,
                  onTap: () => onTap(1),
                ),
                _NavItem(
                  icon: Icons.tune_outlined,
                  activeIcon: Icons.tune,
                  label: 'Settings',
                  isSelected: selectedIndex == 2,
                  onTap: () => onTap(2),
                ),
              ]
            : [
                _NavItem(
                  icon: Icons.space_dashboard_outlined,
                  activeIcon: Icons.space_dashboard,
                  label: 'Home',
                  isSelected: selectedIndex == 0,
                  onTap: () => onTap(0),
                ),
                _NavItem(
                  icon: Icons.spa_outlined,
                  activeIcon: Icons.spa,
                  label: 'Wellness',
                  isSelected: selectedIndex == 1,
                  onTap: () => onTap(1),
                ),
                _NavItem(
                  icon: Icons.auto_stories_outlined,
                  activeIcon: Icons.auto_stories,
                  label: 'Journal',
                  isSelected: selectedIndex == 2,
                  onTap: () => onTap(2),
                ),
                _NavItem(
                  icon: Icons.event_available_outlined,
                  activeIcon: Icons.event_available,
                  label: 'Care',
                  isSelected: selectedIndex == 3,
                  onTap: () => onTap(3),
                ),
                _NavItem(
                  icon: Icons.tune_outlined,
                  activeIcon: Icons.tune,
                  label: 'Settings',
                  isSelected: selectedIndex == 4,
                  onTap: () => onTap(4),
                ),
              ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeOutCubic,
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected),
                color: isSelected
                    ? scheme.primary
                    : scheme.onSurface.withValues(alpha: 0.50),
                size: isSelected ? 22 : 20,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontSize: isSelected ? 10 : 9.5,
                color: isSelected
                    ? scheme.primary
                    : scheme.onSurface.withValues(alpha: 0.50),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
