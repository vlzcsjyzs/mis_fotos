import 'package:flutter/material.dart';

import 'pantalla_principal.dart';
import 'tema.dart';

// main() es donde empieza TODA app de Flutter
void main() {
  runApp(const MisFotosApp());
}

class MisFotosApp extends StatelessWidget {
  const MisFotosApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder "escucha" la caja modoTema.
    // Cuando su valor cambia, vuelve a construir lo de adentro con el modo nuevo.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: modoTema,
      builder: (context, modo, _) {
        return MaterialApp(
          title: 'MisFotos',
          debugShowCheckedModeBanner: false, // quita la cinta roja "DEBUG"
          theme: temaClaro, // se usa en modo claro
          darkTheme: temaOscuro, // se usa en modo oscuro
          themeMode: modo, // cuál de los dos está activo
          home: const PantallaPrincipal(), // la primera pantalla
        );
      },
    );
  }
}