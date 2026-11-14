import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class Spacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

class AppTheme {
  static const _brandPrimary = Color(0xFF4F46E5);

  static const _colors = FlexSchemeColor(
    primary: _brandPrimary,
    primaryContainer: Color(0xFFE0DEFF),
    secondary: Color(0xFF5C6BC0),
    secondaryContainer: Color(0xFFDDE1FF),
    tertiary: Color(0xFF7C4DFF),
    tertiaryContainer: Color(0xFFEDE7FF),
  );

  static const _darkScaffold = Color(0xFF342E9B);
  static const _darkSurface = Color(0xFF3C35AF);

  static const _darkColors = FlexSchemeColor(
    primary: Color(0xFFB8B3FF),
    primaryContainer: Color(0xFF4F46E5),
    secondary: Color(0xFF9FA8DA),
    secondaryContainer: Color(0xFF4338CA),
    tertiary: Color(0xFFCEB5FF),
    tertiaryContainer: Color(0xFF5B21B6),
  );

  static const _subThemes = FlexSubThemesData(
    interactionEffects: true,
    blendOnLevel: 10,
    inputDecoratorBorderType: FlexInputBorderType.outline,
    inputDecoratorRadius: 16.0,
    chipRadius: 20.0,
    cardRadius: 20.0,
    cardElevation: 0,
    dialogRadius: 24.0,
    fabRadius: 20.0,
    appBarScrolledUnderElevation: 0,
    navigationBarIndicatorRadius: 16.0,
    navigationBarElevation: 0,
  );

  static ThemeData light() {
    final base = FlexThemeData.light(
      colors: _colors,
      useMaterial3: true,
      textTheme: AppTypography.textTheme,
      subThemesData: _subThemes,
    );
    return base.copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: base.colorScheme.surfaceContainerLowest,
      ),
      navigationBarTheme: base.navigationBarTheme.copyWith(
        elevation: 0,
        indicatorColor: _brandPrimary,
        indicatorShape: const StadiumBorder(),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _brandPrimary,
            );
          }
          return TextStyle(fontSize: 12);
        }),
      ),
      extensions: [AppColors.light],
    );
  }

  static ThemeData dark() {
    final base = FlexThemeData.dark(
      colors: _darkColors,
      useMaterial3: true,
      textTheme: AppTypography.textTheme,
      subThemesData: _subThemes.copyWith(blendOnLevel: 20),
    );
    final scheme = base.colorScheme.copyWith(
      surface: _darkSurface,
      surfaceContainerLowest: const Color(0xFF2B257A),
      surfaceContainerLow: const Color(0xFF302B8D),
      surfaceContainer: const Color(0xFF3731A0),
      surfaceContainerHigh: const Color(0xFF4641BE),
      surfaceContainerHighest: const Color(0xFF524CC9),
      onSurface: Colors.white,
      onSurfaceVariant: const Color(0xFFD0CDF5),
      outline: const Color(0xFF8B86D8),
      outlineVariant: const Color(0xFF6B65C0),
      inverseSurface: const Color(0xFFE8E5FF),
      onInverseSurface: const Color(0xFF2B257A),
    );
    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: _darkScaffold,
      appBarTheme: base.appBarTheme.copyWith(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: _darkScaffold,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: scheme.surfaceContainerHigh,
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        hintStyle: TextStyle(color: const Color(0xFF9B97D4)),
        prefixIconColor: const Color(0xFFD0CDF5),
        suffixIconColor: const Color(0xFFD0CDF5),
        fillColor: _darkSurface,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _brandPrimary,
          foregroundColor: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4641BE),
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFD0CDF5),
          side: BorderSide(color: scheme.outline),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return _brandPrimary;
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return const Color(0xFFD0CDF5);
          }),
          side: WidgetStatePropertyAll(
            BorderSide(color: scheme.outline),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return const Color(0xFF9B97D4);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _brandPrimary;
          return const Color(0xFF4641BE);
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _brandPrimary;
          return scheme.outline;
        }),
      ),
      navigationBarTheme: base.navigationBarTheme.copyWith(
        elevation: 0,
        backgroundColor: _darkScaffold,
        indicatorColor: scheme.primary,
        indicatorShape: const StadiumBorder(),
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Colors.white);
          }
          return IconThemeData(color: const Color(0xFFD0CDF5));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: scheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return TextStyle(color: const Color(0xFFD0CDF5), fontSize: 12);
        }),
      ),
      dialogTheme: base.dialogTheme.copyWith(
        backgroundColor: _darkSurface,
      ),
      bottomSheetTheme: base.bottomSheetTheme.copyWith(
        backgroundColor: const Color(0xFF2B257A),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
      ),
      extensions: [AppColors.dark],
    );
  }
}
