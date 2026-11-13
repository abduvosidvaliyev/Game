import 'package:flutter/material.dart';

class NeonButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final IconData? icon;
  final double height;
  final double? width;
  final bool isOutlined;
  final bool isLoading;

  const NeonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = const Color(0xFF00F0FF),
    this.icon,
    this.height = 56,
    this.width,
    this.isOutlined = false,
    this.isLoading = false,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.onPressed == null ? Colors.grey : widget.color;

    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onPressed != null ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: widget.height,
          width: widget.width,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: widget.isOutlined
                ? effectiveColor.withOpacity(0.08)
                : effectiveColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: effectiveColor.withOpacity(widget.isOutlined ? 0.8 : 0.9),
              width: 1.8,
            ),
            boxShadow: widget.onPressed != null
                ? [
                    BoxShadow(
                      color: effectiveColor.withOpacity(_isPressed ? 0.5 : 0.3),
                      blurRadius: _isPressed ? 20 : 14,
                      spreadRadius: _isPressed ? 2 : 0,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: effectiveColor, size: 22),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        widget.text,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          shadows: [
                            Shadow(
                              color: effectiveColor,
                              blurRadius: 10,
                            ),
                          ],
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

