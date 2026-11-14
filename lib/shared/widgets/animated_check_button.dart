import 'package:flutter/material.dart';

class AnimatedCheckButton extends StatefulWidget {
  final bool isChecked;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final double size;

  const AnimatedCheckButton({
    super.key,
    required this.isChecked,
    required this.onChanged,
    required this.activeColor,
    this.size = 32,
  });

  @override
  State<AnimatedCheckButton> createState() => _AnimatedCheckButtonState();
}

class _AnimatedCheckButtonState extends State<AnimatedCheckButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _iconFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
      value: widget.isChecked ? 1.0 : 0.0,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.15), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _iconFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void didUpdateWidget(AnimatedCheckButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isChecked != oldWidget.isChecked) {
      if (widget.isChecked) {
        _controller.forward(from: 0.0);
      } else {
        _controller.reverse(from: 1.0);
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final uncheckedBorder = isDark ? Colors.white : theme.colorScheme.outline;
    final uncheckedSymbol = isDark ? Colors.white : theme.colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: () => widget.onChanged(!widget.isChecked),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;
          final bgColor =
              Color.lerp(Colors.transparent, widget.activeColor, progress)!;
          final borderColor =
              Color.lerp(uncheckedBorder, widget.activeColor, progress)!;
          final symbolColor =
              Color.lerp(uncheckedSymbol, Colors.white, progress)!;

          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bgColor,
                border: Border.all(
                  color: borderColor,
                  width: 2,
                ),
              ),
              child: Center(
                child: _iconFade.value < 0.5
                    ? Opacity(
                        opacity: 1.0 - (_iconFade.value * 2),
                        child: Text(
                          '\$',
                          style: TextStyle(
                            fontSize: widget.size * 0.45,
                            fontWeight: FontWeight.w700,
                            color: symbolColor,
                            height: 1,
                          ),
                        ),
                      )
                    : Opacity(
                        opacity: (_iconFade.value - 0.5) * 2,
                        child: Icon(
                          Icons.check_rounded,
                          size: widget.size * 0.55,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
