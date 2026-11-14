import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final Widget icon;
  final Color? valueColor;
  final Color? backgroundColor;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.valueColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark
            ? theme.colorScheme.surfaceContainerHigh
            : theme.colorScheme.surfaceContainerLowest);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Text(
              value,
              key: ValueKey(value),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
