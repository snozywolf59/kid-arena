import 'package:flutter/material.dart';

// Để sử dụng font Poppins, hãy thêm vào pubspec.yaml:
// fonts:
//   - family: Poppins
//     fonts:
//       - asset: assets/fonts/Poppins-Regular.ttf
//       - asset: assets/fonts/Poppins-Medium.ttf
//         weight: 500
//       - asset: assets/fonts/Poppins-SemiBold.ttf
//         weight: 600
//       - asset: assets/fonts/Poppins-Bold.ttf
//         weight: 700
// (Tạo thư mục assets/fonts và đặt file font vào đó)

class AppTheme {
  // --- Bảng màu chính ---
  static const _primaryColor = Color(0xFF2E7D32); // Xanh lá đậm (Core Brand)
  static const _secondaryColor = Color(
    0xFF4CAF50,
  ); // Xanh lá vừa (Supporting Accent)
  static const _tertiaryColor = Color(
    0xFF81C784,
  ); // Xanh lá nhạt (Subtle Accent / Highlights)
  static const _errorColor = Color(
    0xFFD32F2F,
  ); // Đỏ đậm hơn cho lỗi (cải thiện contrast)
  static const _neutralColor = Color(0xFF757575); // Xám trung tính

  // --- Màu cho Light Theme ---
  static const _lightBackground = Color(0xFFFCFCFC); // Gần như trắng, rất nhẹ
  static const _lightSurface = Color(
    0xFFFFFFFF,
  ); // Trắng tinh cho cards, dialogs
  static const _lightOnSurface = Color(
    0xFF1A1A1A,
  ); // Gần đen cho text trên surface sáng
  static const _lightPrimaryContainer = Color(
    0xFFA5D6A7,
  ); // Container cho primary
  static const _lightOnPrimaryContainer = Color(
    0xFF00210B,
  ); // Text/icon trên primary container sáng

  // --- Màu cho Dark Theme ---
  static const _darkBackground = Color(0xFF121212); // Nền tối chuẩn Material
  static const _darkSurface = Color(
    0xFF1E1E1E,
  ); // Surface tối (hơi sáng hơn background)
  static const _darkOnSurface = Color(
    0xFFE0E0E0,
  ); // Gần trắng cho text trên surface tối
  static const _darkPrimaryContainer = Color(
    0xFF005325,
  ); // Container cho primary
  static const _darkOnPrimaryContainer = Color(
    0xFFC8E6C9,
  ); // Text/icon trên primary container tối

  // --- Font Family ---
  static const String _fontFamily = 'Poppins'; // Hoặc font bạn chọn

  // --- Theme sáng ---
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: _fontFamily,
    scaffoldBackgroundColor: _lightBackground,
    colorScheme: const ColorScheme.light(
      primary: _primaryColor,
      onPrimary: Colors.white,
      primaryContainer: _lightPrimaryContainer,
      onPrimaryContainer: _lightOnPrimaryContainer,
      secondary: _secondaryColor,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFC8E6C9),
      onSecondaryContainer: Color(0xFF00210B),
      tertiary: _tertiaryColor,
      onTertiary: Colors.black,
      tertiaryContainer: Color(0xFFD1F4D2),
      onTertiaryContainer: Color(0xFF00210B),
      error: _errorColor,
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: _lightSurface,
      onSurface: _lightOnSurface,
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF7F7F7),
      surfaceContainer: Color(0xFFF2F2F2),
      surfaceContainerHigh: Color(0xFFECECEC),
      surfaceContainerHighest: Color(0xFFE6E6E6),
      outline: Color(0xFFBDBDBD),
      outlineVariant: Color(0xFFC4C6CF),
      shadow: Colors.black,
      scrim: Colors.black54,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0.5, // Độ nổi nhẹ cho appbar
      centerTitle: true,
      backgroundColor:
          _lightSurface, // Sử dụng surface thay vì background để có thể khác biệt
      foregroundColor: _primaryColor, // Màu chữ và icon trên appbar
      iconTheme: IconThemeData(color: _primaryColor, size: 24),
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        color: _primaryColor,
        fontSize: 20,
        fontWeight: FontWeight.w600, // SemiBold
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2, // Tăng nhẹ độ nổi để dễ nhận biết
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: _lightSurface,
      surfaceTintColor:
          Colors.transparent, // Tắt hiệu ứng tint mặc định của M3 trên card
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ), // Giảm nhẹ bo tròn so với card
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryColor,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 15,
        ), // 1px border + 15 padding = 16 total
        side: const BorderSide(color: _primaryColor, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightBackground.withAlpha(128), // Màu nền input field hơi mờ
      hintStyle: TextStyle(
        color: _neutralColor.withAlpha(179),
        fontFamily: _fontFamily,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _errorColor, width: 2),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _secondaryColor, // Sử dụng màu secondary cho FAB
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(), // Hoặc StadiumBorder() nếu có extended FAB
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _lightPrimaryContainer.withAlpha(128),
      labelStyle: const TextStyle(
        color: _lightOnPrimaryContainer,
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
      ),
      selectedColor: _primaryColor,
      secondarySelectedColor: _secondaryColor,
      selectedShadowColor: _primaryColor.withAlpha(77),
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ), // Bo tròn nhiều cho chip
      side: BorderSide.none,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: _lightSurface,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        color: _lightOnSurface,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: TextStyle(
        fontFamily: _fontFamily,
        color: _lightOnSurface.withAlpha(204),
        fontSize: 16,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: _lightSurface,
      surfaceTintColor:
          Colors.transparent, // Quan trọng để tránh tinting của M3
      elevation: 5,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      modalBackgroundColor: _lightSurface, // Cho modal bottom sheets
    ),
    tabBarTheme: TabBarTheme(
      indicatorColor: _primaryColor,
      labelColor: _primaryColor,
      unselectedLabelColor: _neutralColor,
      labelStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
      indicatorSize: TabBarIndicatorSize.label, // Hoặc .tab
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _primaryColor,
      linearTrackColor: _lightPrimaryContainer,
      circularTrackColor: _lightPrimaryContainer,
    ),
    tooltipTheme: TooltipThemeData(
      preferBelow: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _neutralColor.withAlpha(230),
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontFamily: _fontFamily,
        color: Colors.white,
        fontSize: 12,
      ),
    ),
    iconTheme: const IconThemeData(
      color: _neutralColor, // Màu icon mặc định
      size: 24,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: _primaryColor, // Màu icon trong ListTile
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      selectedTileColor: _primaryColor.withAlpha(26),
      selectedColor: _primaryColor, // Màu text khi selected
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey[300],
      thickness: 0.8,
      space: 1, // Khoảng cách trên và dưới của divider
    ),
    // ... thêm các tùy chỉnh theme khác nếu cần
  );

  // --- Theme tối ---
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: _fontFamily,
    scaffoldBackgroundColor: _darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: _primaryColor,
      onPrimary: Colors.white,
      primaryContainer: _darkPrimaryContainer,
      onPrimaryContainer: _darkOnPrimaryContainer,
      secondary: _secondaryColor,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF003813),
      onSecondaryContainer: Color(0xFFC8E6C9),
      tertiary: _tertiaryColor,
      onTertiary: Colors.black,
      tertiaryContainer: Color(0xFF004F26),
      onTertiaryContainer: Color(0xFFD1F4D2),
      error: _errorColor,
      onError: Colors.black,
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: _darkSurface,
      onSurface: _darkOnSurface,
      surfaceContainerLowest: Color(0xFF1A1A1A),
      surfaceContainerLow: Color(0xFF1F1F1F),
      surfaceContainer: Color(0xFF242424),
      surfaceContainerHigh: Color(0xFF292929),
      surfaceContainerHighest: Color(0xFF2E2E2E),
      outline: Color(0xFF757575),
      outlineVariant: Color(0xFF494949),
      shadow: Colors.black,
      scrim: Colors.black54,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0.5,
      centerTitle: true,
      backgroundColor: _darkSurface,
      foregroundColor: _tertiaryColor, // Hoặc Colors.white tùy sở thích
      iconTheme: const IconThemeData(
        color: _tertiaryColor,
        size: 24,
      ), // Hoặc Colors.white
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        color: _tertiaryColor, // Hoặc Colors.white
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: _darkSurface, // Card sử dụng _darkSurface
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor:
            _primaryColor, // Có thể làm sáng _primaryColor một chút cho dark mode
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor:
            _tertiaryColor, // Dùng tertiary (màu xanh lá sáng) cho dễ nhìn
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _tertiaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        side: BorderSide(color: _tertiaryColor.withAlpha(179), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurface.withAlpha(153),
      hintStyle: TextStyle(
        color: _neutralColor.withAlpha(153),
        fontFamily: _fontFamily,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _tertiaryColor,
          width: 2,
        ), // Dùng tertiary cho focus
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _errorColor.withAlpha(204), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _errorColor.withAlpha(204), width: 2),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor:
          _secondaryColor, // Có thể là _tertiaryColor để nổi bật hơn
      foregroundColor: Colors.black, // Nếu BG sáng
      elevation: 4,
      shape: const CircleBorder(),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _darkPrimaryContainer.withAlpha(128),
      labelStyle: TextStyle(
        color: _darkOnPrimaryContainer,
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
      ),
      selectedColor: _tertiaryColor,
      secondarySelectedColor: _secondaryColor,
      selectedShadowColor: _tertiaryColor.withAlpha(77),
      checkmarkColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: _darkSurface,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        color: _darkOnSurface,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: TextStyle(
        fontFamily: _fontFamily,
        color: _darkOnSurface.withAlpha(204),
        fontSize: 16,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: _darkSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 5,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      modalBackgroundColor: _darkSurface,
    ),
    tabBarTheme: TabBarTheme(
      indicatorColor: _tertiaryColor,
      labelColor: _tertiaryColor,
      unselectedLabelColor: _neutralColor.withAlpha(204),
      labelStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
      indicatorSize: TabBarIndicatorSize.label,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: _tertiaryColor,
      linearTrackColor: _darkPrimaryContainer,
      circularTrackColor: _darkPrimaryContainer,
    ),
    tooltipTheme: TooltipThemeData(
      preferBelow: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _lightSurface.withAlpha(230), // Tooltip sáng trên nền tối
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontFamily: _fontFamily,
        color: _darkBackground,
        fontSize: 12,
      ),
    ),
    iconTheme: IconThemeData(color: _neutralColor.withAlpha(204), size: 24),
    listTileTheme: ListTileThemeData(
      iconColor: _tertiaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      selectedTileColor: _tertiaryColor.withAlpha(26),
      selectedColor: _tertiaryColor,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey[700],
      thickness: 0.8,
      space: 1,
    ),
    // ... thêm các tùy chỉnh theme khác nếu cần
  );
}
