import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/smooth_widgets.dart';

class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  final _pinController = TextEditingController();
  bool _hasError = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _unlock() {
    final ok =
        ref.read(appSessionProvider.notifier).unlock(_pinController.text);
    if (!ok) {
      setState(() => _hasError = true);
      _pinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(appSessionProvider).profile;
    return Scaffold(
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: SmoothCard(
                borderRadius: 28,
                elevation: 24,
                backgroundColor: Colors.white.withOpacity(0.9),
                borderColor: AppColors.neonViolet.withOpacity(0.24),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.neonViolet, AppColors.neonPink],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonViolet.withOpacity(0.34),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Welcome back${profile == null ? '' : ', ${profile.name}'}',
                      textAlign: TextAlign.center,
                      style: AppTypography.headingLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your app lock PIN to continue.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.lightSubtext,
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: _pinController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 8,
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: 'PIN',
                        errorText: _hasError ? 'Incorrect PIN' : null,
                      ),
                      onChanged: (_) {
                        if (_hasError) {
                          setState(() => _hasError = false);
                        }
                      },
                      onSubmitted: (_) => _unlock(),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: SmoothButton(
                        label: 'Unlock',
                        backgroundColor: AppColors.neonViolet,
                        onPressed: _unlock,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
