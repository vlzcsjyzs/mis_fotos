import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // El paquete que acabamos de instalar

const Color colorAcento = Color(0xFF5B6CFF);

final ValueNotifier<ThemeMode> modoTema = ValueNotifier(ThemeMode.system);

// AQUÍ ELIGES LA FUENTE de toda la app. Cambia solo la palabra después del punto:
//   GoogleFonts.outfitTextTheme   → geométrica y redondeada (la más parecida a Pixel)
//   GoogleFonts.nunitoTextTheme   → letras con puntas muy redondeadas
//   GoogleFonts.figtreeTextTheme  → limpia y moderna
//   GoogleFonts.quicksandTextTheme → la más "redondita" de todas
// "TextTheme Function([TextTheme?])" significa "una función que devuelve un estilo de texto".
final TextTheme Function([TextTheme?]) _fuente = GoogleFonts.outfitTextTheme;

// Función que arma un tema completo para un modo (claro u oscuro).
// Así no repetimos el mismo código dos veces.
ThemeData _construirTema(Brightness brillo) {
  // Primero creamos el tema base, con los colores de siempre
  final base = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: colorAcento,
    brightness: brillo,
  );

  // copyWith = "copia el tema base, pero cambia SOLO esto".
  // Aquí reemplazamos los estilos de texto por los de nuestra fuente.
  return base.copyWith(textTheme: _fuente(base.textTheme));
}

final ThemeData temaClaro = _construirTema(Brightness.light);
final ThemeData temaOscuro = _construirTema(Brightness.dark);

class Paleta {
  Paleta(this.oscuro);

  final bool oscuro;

  Color get fondoArriba => oscuro ? const Color(0xFF0F1117) : const Color(0xFFFFFFFF);
  Color get fondoAbajo => oscuro ? const Color(0xFF1B1F2E) : const Color(0xFFEEF1FA);
  Color get vidrio => Colors.white.withValues(alpha: oscuro ? 0.10 : 0.70);
  Color get borde => oscuro
      ? Colors.white.withValues(alpha: 0.20)
      : Colors.black.withValues(alpha: 0.08);
  Color get texto => oscuro ? const Color(0xFFF2F2F7) : const Color(0xFF1C1C1E);

  static Paleta de(BuildContext context) {
    return Paleta(Theme.of(context).brightness == Brightness.dark);
  }
}