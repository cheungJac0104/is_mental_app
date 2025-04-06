import 'package:flutter/material.dart';
import 'package:tailwind_colors/tailwind_colors.dart';

class TwSizes {
  static const double p1 = 4.0;
  static const double p2 = 8.0;
  static const double p3 = 12.0;
  static const double p4 = 16.0;
  static const double p5 = 20.0;
  static const double p6 = 24.0;
  static const double p7 = 28.0;
  static const double p8 = 32.0;
  static const double p10 = 40.0;
}

extension ThemeExtension on BuildContext {
  TwColors get twColors => Theme.of(this).extension<TwColors>()!;
  TwTextStyles get twTextStyles => Theme.of(this).extension<TwTextStyles>()!;
}

enum TwButtonVariant { primary, secondary, outline, text }

class TwColors {
  static MaterialColor primary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? createMaterialColor(TW3Colors.blue.shade400)
          : createMaterialColor(TW3Colors.blue.shade600);

  static Color secondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? TW3Colors.gray.shade400
          : TW3Colors.gray.shade600;

  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? TWUIColors.cool_gray.shade900
          : TWUIColors.cool_gray.shade50!;

  static Color text(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? TW3Colors.gray.shade100
          : TW3Colors.gray.shade800;
}

MaterialColor createMaterialColor(Color color) {
  final strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }

  for (final strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }

  return MaterialColor(color.value, swatch);
}

class TwTextStyles {
  static TextStyle heading1(BuildContext context) => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: TwColors.text(context),
      );

  static TextStyle body(BuildContext context) => TextStyle(
        fontSize: 16,
        color: TwColors.text(context),
      );
}

class TwTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String? errorText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Color? borderColor;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  const TwTextField({
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.borderColor,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.errorText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: borderColor ?? Colors.blue.shade500,
            width: 2.0,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 16.0,
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        errorText: errorText,
      ),
    );
  }
}

class TwButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isLoading;
  final Widget? icon;
  final TwButtonVariant? variant;

  const TwButton({
    required this.onPressed,
    required this.child,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
    this.isLoading = false,
    this.icon,
    this.variant,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Determine colors based on variant if provided
    final Color bgColor = variant != null
        ? _getBackgroundColor(variant!, theme)
        : (backgroundColor);

    final Color fgColor =
        variant != null ? _getForegroundColor(variant!, theme) : (textColor);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Button
        ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isLoading ? Colors.transparent : bgColor,
            foregroundColor: fgColor,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: isLoading
                  ? BorderSide(
                      color: backgroundColor,
                      width: 2.0,
                    )
                  : variant == TwButtonVariant.outline
                      ? BorderSide(color: theme.primaryColor)
                      : BorderSide.none,
            ),
          ),
          child: isLoading
              ? const SizedBox.shrink() // Hide button content when loading
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) icon!,
                    if (icon != null) const SizedBox(width: 8.0),
                    child,
                  ],
                ),
        ),

        // Loading border animation
        if (isLoading)
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
      ],
    );
  }

  Color _getBackgroundColor(TwButtonVariant variant, ThemeData theme) {
    switch (variant) {
      case TwButtonVariant.primary:
        return theme.primaryColor;
      case TwButtonVariant.secondary:
        return theme.colorScheme.secondary;
      case TwButtonVariant.outline:
        return Colors.transparent;
      case TwButtonVariant.text:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor(TwButtonVariant variant, ThemeData theme) {
    switch (variant) {
      case TwButtonVariant.primary:
      case TwButtonVariant.secondary:
        return Colors.white;
      case TwButtonVariant.outline:
      case TwButtonVariant.text:
        return theme.primaryColor;
    }
  }
}

// Add centralized layout utility classes
class TwLayout {
  static Widget centerHorizontal(Widget child) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [child],
    );
  }

  static Widget centerVertical(Widget child) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [child],
    );
  }

  static EdgeInsets symmetricPadding({
    double horizontal = 0,
    double vertical = 0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: horizontal,
      vertical: vertical,
    );
  }

  static EdgeInsets allPadding(double size) {
    return EdgeInsets.all(size);
  }
}

class TwBreakpoints {
  static double mobile = 600;
  static double tablet = 900;
  static double desktop = 1200;
}
