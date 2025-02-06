import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Styles {
  Styles._();

  static const appBgColor = Color(0xFF002CC8);
  static const bodyTextColor = Color(0xFF002CC8);
  static const bottomNavBgColor = Color(0xFF002CC8);
  static var chipBodyColor = Colors.blue[400];
  static var chipTextColor = Colors.white;
  static var activeColor = Colors.green[400];
  static var bodyContentColor = Colors.grey[600];
  static var btnBackgroundColor = Color(0xFF002CC8);
  static var btnForegroundColor = Colors.white;
  static var inputFillColor = Colors.grey[200];

  static Color get categoryIcon => Color(0xFF002CC8);
  static Color get subCategoryIcon => Color(0xFF002CC8);

  static Color get dialogCancelButtonBgColor => Colors.red.shade300;
  static Color get dialogSaveButtonBgColor => Colors.green.shade500;

  static TextStyle get logo => GoogleFonts.aclonica(
        color: Color(0xFF002CC8),
        fontSize: 24.0, //22.0
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      );
  static TextStyle get splashBody => GoogleFonts.montserrat(
        color: bodyTextColor,
        // height: 1.5,
        fontSize: 13.0,
        letterSpacing: 1.0,
        fontWeight: FontWeight.normal,
      );
  static TextStyle get links => GoogleFonts.montserrat(
        fontSize: 16.0,
        letterSpacing: 1.0,
        color: Color(0xFF002CC8),
      );
  static TextStyle get button => GoogleFonts.montserrat(
      fontSize: 16.0, letterSpacing: 1.0, fontWeight: FontWeight.bold);

  static TextStyle get smallButton => GoogleFonts.montserrat(
        fontSize: 16.0,
        letterSpacing: 1.0,
        color: Color(0xFF002CC8),
      );

  static ButtonStyle get cancelButtonStyle => ButtonStyle(
        backgroundColor: WidgetStateColor.resolveWith((states) => Colors.grey),
        foregroundColor: WidgetStateColor.resolveWith((states) => Colors.white),
      );

  static ButtonStyle get deleteButtonStyle => ButtonStyle(
        backgroundColor: WidgetStateColor.resolveWith((states) => Colors.red),
        foregroundColor: WidgetStateColor.resolveWith((states) => Colors.white),
      );

  static TextStyle get headingLinks => GoogleFonts.montserrat(
      fontSize: 16.0,
      letterSpacing: 1.0,
      color: Colors.green[400],
      fontWeight: FontWeight.bold);

  static TextStyle get dialogHeading => GoogleFonts.montserrat(
        fontSize: 16.0,
        letterSpacing: 1.0,
        color: Color(0xFF002CC8),
        fontWeight: FontWeight.bold,
      );

  static TextStyle get dialogButton => GoogleFonts.montserrat(
      fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white);

  static TextStyle get heading => GoogleFonts.aclonica(
        color: Color(0xFF002CC8),
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      );

  static TextStyle get subHeading => GoogleFonts.aclonica(
        color: Color(0xFF002CC8),
        fontSize: 24.0,
        letterSpacing: 1.0,
      );
  static TextStyle get subHeadingSmall => GoogleFonts.aclonica(
        color: Color(0xFF002CC8),
        fontSize: 16.0,
        letterSpacing: 1.0,
      );
  static TextStyle get errorText => GoogleFonts.montserrat(
        color: Color.fromARGB(255, 200, 0, 17),
        height: 1.5,
        fontSize: 14.0,
        letterSpacing: 1.0,
      );
  static TextStyle get body => GoogleFonts.montserrat(
        color: bodyTextColor,
        height: 1.5,
        fontSize: 16.0,
        letterSpacing: 1.0,
      );
  static TextStyle get bodyContnt => GoogleFonts.montserrat(
        color: bodyContentColor,
        height: 1.5,
        fontSize: 14.0,
        letterSpacing: 1.0,
      );

  static TextStyle get chip => GoogleFonts.montserrat(
        color: bodyTextColor,
        height: 1.5,
        fontSize: 12.0, //12.0
        letterSpacing: 1.0,
      );
  static TextStyle get footer => GoogleFonts.montserrat(
        color: bodyTextColor,
        height: 1.5,
        fontSize: 12.0, //12.0
        letterSpacing: 1.0,
      );
  static TextStyle get categoryName => GoogleFonts.montserrat(
        color: Color(0xFF002CC8),
        fontSize: 14.0, //12.0
        letterSpacing: 1.0,
      );
  static TextStyle get subCategoryName => GoogleFonts.montserrat(
        color: Color(0xFF002CC8),
        fontSize: 14.0, //12.0
        letterSpacing: 1.0,
      );
  static TextStyle get categoryHeading => GoogleFonts.montserrat(
        color: Color(0xFF002CC8),
        fontSize: 20.0, //12.0
        letterSpacing: 1.0,
        fontWeight: FontWeight.bold,
      );

  // static TextStyle get categoryIcon => {
  //       color: Color(0xFF002CC8),
  //     };
}
