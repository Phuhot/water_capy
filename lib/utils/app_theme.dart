import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color oceanBlue = Color(0xFF0077B6);
  static const Color lightBlue = Color(0xFF90E0EF);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF1E1E1E);

  // GIAO DIỆN SÁNG (Giữ nguyên)
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: oceanBlue,
      scaffoldBackgroundColor: pureWhite,
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: const TextStyle(
          color: darkText,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: const TextStyle(color: darkText),
      ),
      colorScheme: const ColorScheme.light(
        primary: oceanBlue,
        secondary: lightBlue,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: pureWhite,
        iconTheme: IconThemeData(color: darkText),
      ),
    );
  }

  // GIAO DIỆN TỐI (Mới thêm)
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: oceanBlue,
      scaffoldBackgroundColor: const Color(0xFF121212), // Đen nhám hiện đại
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: const TextStyle(
          color: pureWhite,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: const TextStyle(color: Colors.white70),
      ),
      colorScheme: const ColorScheme.dark(
        primary: oceanBlue,
        secondary: Color(0xFF1E1E1E), // Nền các nút bấm tối đi
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        iconTheme: IconThemeData(color: pureWhite),
      ),
    );
  }
}
