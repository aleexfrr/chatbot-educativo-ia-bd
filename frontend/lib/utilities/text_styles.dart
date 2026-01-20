import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextStyles {
  /// Texto principal grande (titulares, encabezados)
  static final TextStyle headerLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  /// Texto de cuerpo normal (nombres, estado, contenido)
  static final TextStyle body = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );

  /// Texto de estado con color variable (por ejemplo: online/offline)
  static TextStyle status(Color color) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: color,
  );

  /// Texto para etiquetas o texto pequeño
  static final TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );

  /// Texto para títulos de secciones o encabezados secundarios
  static TextStyle sectionTitleStyle(BuildContext context) => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Theme.of(context).colorScheme.primary,
  );
}