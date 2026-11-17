import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tema.dart';
import 'vistas/vista_colecciones.dart';
import 'widgets/barra_flotante.dart';
import 'widgets/boton_principal.dart';
import 'widgets/cristal.dart';
import 'widgets/menu_crear.dart';
import 'widgets/pulsable.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _pestana = 0; // 0 = Fotos, 1 = Colecciones
  bool _menuAbierto = false; // ¿está abierto el menú del botón +?

  void _elegirPestana(int nueva) {
    setState(() {
      _menuAbierto = false; // al cambiar de pestaña, el menú se cierra
      _pestana = nueva;
    });
  }

  // Abre el menú si está cerrado, y lo cierra si está abierto
  void _alternarMenu() {
    setState(() {
      _menuAbierto = !_menuAbierto;
    });
  }

  void _cerrarMenu() {
    setState(() {
      _menuAbierto = false;
    });
  }

  void _cambiarTema(bool esOscuroAhora) {
    modoTema.value = esOscuroAhora ? ThemeMode.light : ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    final paleta = Paleta.de(context);

    // PopScope controla el botón "atrás" de Android.
    // Si el menú está abierto, "atrás" lo cierra en vez de salir de la app.
    return PopScope(
      canPop: !_menuAbierto,
      onPopInvokedWithResult: (seSalio, resultado) {
        if (!seSalio) _cerrarMenu();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: paleta.oscuro ? Brightness.light : Brightness.dark,
        ),
        child: Scaffold(
          body: Stack(
            children: [
              // CAPA 1: fondo
              _Fondo(paleta: paleta),

              // CAPA 2: título + contenido
              SafeArea(
                // Ya no hay espacio a los lados aquí: cada vista maneja el suyo.
                // Así la tira de Colecciones puede llegar de borde a borde.
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _Encabezado(
                          titulo: _pestana == 0 ? 'MisFotos' : 'Colecciones',
                          paleta: paleta,
                          alCambiarTema: () => _cambiarTema(paleta.oscuro),
                        ),
                      ),
                      const SizedBox(height: 20), // antes 28: ahora el contenido sube un poco
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animacion) {
                            return FadeTransition(
                              opacity: animacion,
                              child: SlideTransition(
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
                            padding: const EdgeInsets.only(bottom: 110),
                            child: SizedBox(
                              width: double.infinity,
                              child: _pestana == 0
                                  // Fotos necesita su espacio lateral aquí
                                  ? const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 24),
                                      child: _VistaFotos(),
                                    )
                                  // Colecciones maneja su propio espacio lateral
                                  : const VistaColecciones(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // CAPA 3: el menú del botón + (va ANTES de la barra, para que la barra
              // quede encima y el botón + siga siendo tocable)
              Positioned.fill(
                child: MenuCrear(
                  abierto: _menuAbierto,
                  alCerrar: _cerrarMenu,
                ),
              ),

              // CAPA 4: la barra flotante
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
                    child: BarraFlotante(
                      pestanaActual: _pestana,
                      menuAbierto: _menuAbierto,
                      alElegir: _elegirPestana,
                      alCrear: _alternarMenu,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
        Pulsable(
          alTocar: alCambiarTema,
          escala: 0.88,
          child: Cristal(
            radio: 22,
            child: SizedBox(
              width: 44,
              height: 44,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animacion) {
                  return RotationTransition(
                    turns: Tween<double>(begin: 0.75, end: 1.0).animate(animacion),
                    child: ScaleTransition(scale: animacion, child: child),
                  );
                },
                child: Icon(
                  paleta.oscuro ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
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