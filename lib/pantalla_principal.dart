import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tema.dart';
import 'widgets/barra_flotante.dart';
import 'widgets/boton_principal.dart';
import 'widgets/cristal.dart';
import 'widgets/pulsable.dart';
import 'vistas/vista_colecciones.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _pestana = 0; // 0 = Fotos, 1 = Colecciones

  void _elegirPestana(int nueva) {
    // Si tocan la pestaña en la que ya estamos, no hacemos nada
    if (nueva == _pestana) return;
    setState(() {
      _pestana = nueva;
    });
  }

  void _cambiarTema(bool esOscuroAhora) {
    modoTema.value = esOscuroAhora ? ThemeMode.light : ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    final paleta = Paleta.de(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: paleta.oscuro ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            _Fondo(paleta: paleta),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Encabezado(
                      titulo: _pestana == 0 ? 'MisFotos' : 'Colecciones',
                      paleta: paleta,
                      alCambiarTema: () => _cambiarTema(paleta.oscuro),
                    ),
                    const SizedBox(height: 28),
                    Expanded(
                      // AnimatedSwitcher anima el cambio entre secciones.
                      // Ahora combinamos desvanecido + deslizamiento hacia arriba.
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        switchInCurve: Curves.easeOutCubic, // cómo ENTRA la sección nueva
                        switchOutCurve: Curves.easeInCubic, // cómo SALE la anterior
                        // transitionBuilder define el "efecto" de la animación
                        transitionBuilder: (child, animacion) {
                          return FadeTransition(
                            opacity: animacion, // de invisible a visible
                            child: SlideTransition(
                              // Empieza un 4% más abajo y sube hasta su lugar
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.04),
                                end: Offset.zero,
                              ).animate(animacion),
                              child: child,
                            ),
                          );
                        },
                        child: SingleChildScrollView(
                          key: ValueKey(_pestana),
                          padding: const EdgeInsets.only(bottom: 100),
                          child: SizedBox(
                            width: double.infinity,
                            child: _pestana == 0
                                ? const _VistaFotos()
                                : const VistaColecciones(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
                  child: BarraFlotante(
                    pestanaActual: _pestana,
                    alElegir: _elegirPestana,
                    alCrear: () {
                      // Aquí irán las opciones de crear (collage, álbum...). Después.
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Fondo: degradado + dos brillos de color (sin cambios)
class _Fondo extends StatelessWidget {
  const _Fondo({required this.paleta});

  final Paleta paleta;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [paleta.fondoArriba, paleta.fondoAbajo],
            ),
          ),
        ),
        const Positioned(top: -120, left: -120, child: _Brillo(color: colorAcento)),
        const Positioned(bottom: -120, right: -120, child: _Brillo(color: Color(0xFFFF7AC8))),
      ],
    );
  }
}

class _Brillo extends StatelessWidget {
  const _Brillo({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 360,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.40), color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({
    required this.titulo,
    required this.paleta,
    required this.alCambiarTema,
  });

  final String titulo;
  final Paleta paleta;
  final VoidCallback alCambiarTema;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            titulo,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: paleta.texto,
            ),
          ),
        ),
        // Pulsable en lugar del GestureDetector de antes: ahora tiene animación al tocar
        Pulsable(
          alTocar: alCambiarTema,
          escala: 0.88,
          child: Cristal(
            radio: 22,
            child: SizedBox(
              width: 44,
              height: 44,
              // AnimatedSwitcher: cuando el ícono cambia (luna ↔ sol),
              // el viejo sale y el nuevo entra con esta animación
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animacion) {
                  return RotationTransition(
                    // "turns" son vueltas: de 0.75 a 1.0 = un cuarto de vuelta
                    turns: Tween<double>(begin: 0.75, end: 1.0).animate(animacion),
                    child: ScaleTransition(scale: animacion, child: child),
                  );
                },
                child: Icon(
                  paleta.oscuro ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  // La "key" distinta le avisa a Flutter que es otro ícono y debe animar
                  key: ValueKey(paleta.oscuro),
                  color: paleta.texto,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VistaFotos extends StatelessWidget {
  const _VistaFotos();

  @override
  Widget build(BuildContext context) {
    final paleta = Paleta.de(context);

    return Cristal(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu galería está vacía',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: paleta.texto,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Agrega tu primera foto para empezar.',
            style: TextStyle(color: paleta.texto.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 18),
          BotonPrincipal(
            texto: 'Agregar foto',
            alTocar: () {
              // Aquí irá el código para elegir fotos
            },
          ),
        ],
      ),
    );
  }
}

