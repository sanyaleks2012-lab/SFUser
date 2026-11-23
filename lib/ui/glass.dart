import 'dart:ui';

import 'package:flutter/material.dart';

/// Frosted "liquid glass" panel: the content behind it is blurred, the panel
/// has a translucent tint and a light rim that catches the highlight.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blur;

  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.padding,
    this.blur = 24,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = theme.colorScheme.surface;

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: isDark ? 0.16 : 0.55),
                surface.withValues(alpha: isDark ? 0.24 : 0.58),
                surface.withValues(alpha: isDark ? 0.14 : 0.42),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.2 : 0.7),
              width: 1,
            ),
          ),
          child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
        ),
      ),
    );
  }
}

/// Background behind the whole app: a soft gradient with two colored light
/// spots. The glass panels above blur it, which gives the liquid look.
class GlassBackground extends StatelessWidget {
  final Widget child;

  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.surfaceContainerLowest,
                  scheme.surfaceContainer,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -140,
          left: -100,
          child: _lightSpot(scheme.primary, 380),
        ),
        Positioned(
          bottom: -160,
          right: -120,
          child: _lightSpot(scheme.tertiary, 420),
        ),
        Positioned.fill(child: child),
      ],
    );
  }

  Widget _lightSpot(Color color, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.5),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tint for content placed inside a glass panel (rows, inner boxes).
Color glassInset(ThemeData theme) {
  final isDark = theme.brightness == Brightness.dark;
  return theme.colorScheme.surface.withValues(alpha: isDark ? 0.3 : 0.35);
}
