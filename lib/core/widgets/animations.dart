import 'package:flutter/material.dart';

/// Smooth page transition animation (fade + slide)
class SmoothPageTransition extends PageRouteBuilder {
  final Widget page;
  final Duration duration;
  final Curve curve;
  final AxisDirection axisDirection;

  SmoothPageTransition({
    required this.page,
    this.duration = const Duration(milliseconds: 420),
    this.curve = Curves.easeInOutCubic,
    this.axisDirection = AxisDirection.right,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween(
              begin: _getOffset(axisDirection),
              end: Offset.zero,
            );
            final offsetAnimation = animation.drive(
              tween.chain(CurveTween(curve: curve)),
            );

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: offsetAnimation, child: child),
            );
          },
        );

  static Offset _getOffset(AxisDirection direction) {
    switch (direction) {
      case AxisDirection.right:
        return const Offset(-0.08, 0);
      case AxisDirection.left:
        return const Offset(0.08, 0);
      case AxisDirection.down:
        return const Offset(0, -0.08);
      case AxisDirection.up:
        return const Offset(0, 0.08);
    }
  }
}

/// Fade transition animation
class FadeTransitionPage extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  FadeTransitionPage({
    required this.page,
    this.duration = const Duration(milliseconds: 320),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
}

/// Smooth scale transition
class ScaleTransitionPage extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  ScaleTransitionPage({
    required this.page,
    this.duration = const Duration(milliseconds: 360),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween(begin: 0.98, end: 1.0);
            final scaleTween = animation.drive(
              tween.chain(CurveTween(curve: Curves.easeOutCubic)),
            );

            return ScaleTransition(
              scale: scaleTween,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
        );
}

/// Animation builder for staggered animations
class StaggeredAnimationBuilder extends StatefulWidget {
  final List<Widget> children;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final Axis direction;
  final CrossAxisAlignment crossAxisAlignment;

  const StaggeredAnimationBuilder({
    super.key,
    required this.children,
    this.duration = const Duration(milliseconds: 420),
    this.delay = const Duration(milliseconds: 45),
    this.curve = Curves.easeOutCubic,
    this.direction = Axis.vertical,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  State<StaggeredAnimationBuilder> createState() =>
      _StaggeredAnimationBuilderState();
}

class _StaggeredAnimationBuilderState extends State<StaggeredAnimationBuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration + widget.delay * widget.children.length,
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant StaggeredAnimationBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newDuration = widget.duration + widget.delay * widget.children.length;
    if (_controller.duration != newDuration) {
      _controller.duration = newDuration;
      if (!_controller.isAnimating && _controller.value < 1.0) {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childrenCount = widget.children.length;
    final totalDurationMs = _controller.duration?.inMilliseconds ?? 1;

    return widget.direction == Axis.vertical
        ? Column(
            crossAxisAlignment: widget.crossAxisAlignment,
            children: List.generate(
              childrenCount,
              (i) {
                final delayMs = widget.delay.inMilliseconds * i;
                final durationMs = widget.duration.inMilliseconds;
                
                final begin = (delayMs / totalDurationMs).clamp(0.0, 1.0);
                final end = ((delayMs + durationMs) / totalDurationMs).clamp(0.0, 1.0);

                final Animation<double> animation = Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Interval(
                      begin,
                      end,
                      curve: widget.curve,
                    ),
                  ),
                );

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.06),
                      end: Offset.zero,
                    ).animate(animation),
                    child: widget.children[i],
                  ),
                );
              },
            ),
          )
        : Row(
            children: List.generate(
              childrenCount,
              (i) {
                final delayMs = widget.delay.inMilliseconds * i;
                final durationMs = widget.duration.inMilliseconds;
                
                final begin = (delayMs / totalDurationMs).clamp(0.0, 1.0);
                final end = ((delayMs + durationMs) / totalDurationMs).clamp(0.0, 1.0);

                final Animation<double> animation = Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Interval(
                      begin,
                      end,
                      curve: widget.curve,
                    ),
                  ),
                );

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.06, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: widget.children[i],
                  ),
                );
              },
            ),
          );
  }
}

/// Animated counter for smooth number transitions
class AnimatedCounter extends StatefulWidget {
  final int end;
  final Duration duration;
  final TextStyle? textStyle;
  final String? prefix;
  final String? suffix;

  const AnimatedCounter({
    super.key,
    required this.end,
    this.duration = const Duration(milliseconds: 700),
    this.textStyle,
    this.prefix,
    this.suffix,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = IntTween(
      begin: 0,
      end: widget.end,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${widget.prefix ?? ''}${_animation.value}${widget.suffix ?? ''}',
          style: widget.textStyle,
        );
      },
    );
  }
}
