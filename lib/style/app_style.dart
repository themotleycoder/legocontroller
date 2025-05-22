import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App styling configuration
class AppStyle {
  // Prevent instantiation
  AppStyle._();

  /// Primary Colors
  static const Color primaryColor = Color(0xFF006CB7);      // Blue
  static const Color primaryLight = Color(0xFF64B5F6);      // Light Blue
  static const Color primaryDark = Color(0xFF006CB7);       // Dark Blue

  /// Secondary Colors
  static const Color secondaryColor = Color(0xFFFECD04);    // Green for success/connected states
  static const Color secondaryLight = Color(0xFFFFF579);    // Light Green
  static const Color secondaryDark = Color(0xFFFBAB18);     // Dark Green

  /// Accent Colors
  static const Color accentColor = Color(0xFF00B04E);       // Amber for warnings/connecting states
  static const Color errorColor = Color(0xFFDD1A22);        // Red for errors/disconnected states
  static const Color infoColor = Color(0xFF006CB7);         // Blue for information

  /// Neutral Colors
  static const Color background = Color(0xFFFFFFFF);        // White background
  static const Color surface = Color(0xFFF5F5F5);           // Light Gray surface
  static const Color divider = Color(0xFFE0E0E0);           // Gray divider

  /// Text Colors
  static const Color textPrimary = Color(0xFF212121);       // Dark Gray for primary text
  static const Color textSecondary = Color(0xFF757575);     // Medium Gray for secondary text
  static const Color textDisabled = Color(0xFFBDBDBD);      // Light Gray for disabled text

  /// Lego Colors
  static const Color legoGreen = Color(0xFF00B04E);         // Lego Green
  static const Color legoRed = Color(0xFFDD1A22);           // Lego Red
  static const Color legoYellow = Color(0xFFFECD04);        // Lego Amber
  static const Color legoBlue = Color(0xFF006CB7);          // Lego Blue

  /// Connection Status Colors
  static const Color connected = Color(0xFF00B04E);         // Lego Green
  static const Color disconnected = Color(0xFFDD1A22);      // Lego Red
  static const Color connecting = Color(0xFFFECD04);        // Lego Amber
  static const Color scanning = Color(0xFF006CB7);          // Lego Blue

  /// Custom Colors
  // Train Colors
  static const Color trainActive = Color(0xFF00B04E);       // Bright Green for active train
  static const Color trainInactive = Color(0xFF757575);     // Gray for inactive train
  static const Color trainError = Color(0xFFDD1A22);        // Deep Red for train errors
  static const Color trainWarning = Color(0xFFFECD04);      // Bright Yellow for warnings
  
  // Switch Colors
  static const Color switchOn = Color(0xFF00B04E);          // Light Green for switch on state
  static const Color switchOff = Color(0xFF616161);         // Dark Gray for switch off state
  static const Color switchTransition = Color(0xFF29B6F6);  // Light Blue for transition state
  
  // Control Panel Colors
  static const Color controlBackground = Color(0xFFF5F5F5); // Light Gray background
  static const Color controlBorder = Color(0xFFE0E0E0);     // Border color for controls
  static const Color controlHighlight = Color(0xFF42A5F5);  // Highlight color for active controls
  static const Color controlDisabled = Color(0xFFBDBDBD);   // Color for disabled controls

  /// Spacing Constants
  static const double spacing_xs = 4.0;
  static const double spacing_sm = 8.0;
  static const double spacing_md = 16.0;
  static const double spacing_lg = 24.0;
  static const double spacing_xl = 32.0;

  /// Border Radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;

  /// Font Sizes
  static const double fontSizeCaption = 12.0;
  static const double fontSizeBody = 14.0;
  static const double fontSizeSubheading = 16.0;
  static const double fontSizeHeading = 20.0;
  static const double fontSizeTitle = 24.0;

  /// Text Styles
  static final TextStyle headingStyle = GoogleFonts.inter(
    fontSize: fontSizeHeading,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static final TextStyle subheadingStyle = GoogleFonts.inter(
    fontSize: fontSizeSubheading,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static final TextStyle bodyStyle = GoogleFonts.inter(
    fontSize: fontSizeBody,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static final TextStyle captionStyle = GoogleFonts.inter(
    fontSize: fontSizeCaption,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  /// Device Card Style
  static final BoxDecoration deviceCardDecoration = BoxDecoration(
    color: background,
    borderRadius: BorderRadius.circular(borderRadiusMedium),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  /// App Theme
  static ThemeData get theme => ThemeData(
    primaryColor: primaryColor,
    primaryColorLight: primaryLight,
    primaryColorDark: primaryDark,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: surface,
    ),
    scaffoldBackgroundColor: background,
    dividerColor: divider,
    textTheme: TextTheme(
      headlineMedium: headingStyle,
      titleMedium: subheadingStyle,
      bodyMedium: bodyStyle,
      bodySmall: captionStyle,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      titleTextStyle: headingStyle.copyWith(
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: spacing_lg,
          vertical: spacing_md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(
          horizontal: spacing_lg,
          vertical: spacing_md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
      ),
    ),
  );
}
