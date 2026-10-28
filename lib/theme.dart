import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VS {
  static const bg = Color(0xFF0F0F11);
  static const surface = Color(0xFF16161B);
  static const surface2 = Color(0xFF1E1E26);
  static const border = Color(0xFF25252D);
  static const purple = Color(0xFF8A2BE2);
  static const blue = Color(0xFF00D2FF);
  static const pink = Color(0xFFFF5CA8);
  static const text = Color(0xFFF4F2F8);
  static const muted = Color(0xFFA9A5B8);

  static const gradient = LinearGradient(
    colors: [purple, blue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData theme() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: purple,
        secondary: blue,
        surface: surface,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme)
          .apply(bodyColor: text, displayColor: text),
    );
  }
}
