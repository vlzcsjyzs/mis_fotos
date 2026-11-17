import 'dart:ui'; // Para ImageFilter (el desenfoque)

import 'package:flutter/material.dart';

import '../tema.dart';
import 'cristal.dart';
import 'pulsable.dart';

// Describe una opción del menú: su ícono, su nombre y su color
class _Opcion {
  const _Opcion(this.icono, this.titulo, this.color);

  final IconData icono;
  final String titulo;
  final Color color;
}

// LISTA DE OPCIONES. Para agregar una nueva, añade una línea aquí.
// El orden es de ARRIBA hacia ABAJO.
const List<_Opcion> _opciones = [
  _Opcion(Icons.photo_album_rounded, 'Álbum', colorAcento),
  _Opcion(Icons.auto_awesome_mosaic_rounded, 'Collage', Color(0xFFFF7AC8)),
  _Opcion(Icons.slideshow_rounded, 'Presentación', Color(0xFF2EC4B6)),
];

// El menú completo: un fondo difuminado + la lista de botones
class MenuCrear extends StatefulWidget {
  const MenuCrear({super.key, required this.abierto, required this.alCerrar});

  final bool abierto; // true = el menú debe estar abierto
  final VoidCallback alCerrar; // se ejecuta para pedir que se cierre

  @override
  State<MenuCrear> createState() => _MenuCrearState();
}

// "with SingleTickerProviderStateMixin" le da a este estado un "reloj" (ticker),
// que es lo que necesita un AnimationController para saber cuándo dibujar el siguiente fotograma
class _MenuCrearState extends State<MenuCrear> with SingleTickerProviderStateMixin {
  // AnimationController = el "director" de la animación: va de 0.0 (cerrado) a 1.0 (abierto)
  late final AnimationController _controlador;

  // Una animación por cada botón, para que no aparezcan todos a la vez
  late final List<CurvedAnimation> _animaciones;

  @override
  void initState() {
    super.initState();

    _controlador = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650), // abrir: lento, para ver el rebote
      reverseDuration: const Duration(milliseconds: 250), // cerrar: rápido
    );

    final total = _opciones.length;

    // List.generate crea una lista repitiendo una función "total" veces.
    // "i" es el número de cada botón: 0 (el de arriba), 1, 2...
    _animaciones = List.generate(total, (i) {
      // El botón de ABAJO (el más cerca del +) arranca primero; los de arriba, después.
      // Cada botón espera 0.14 (14% del tiempo total) más que el anterior.
      final inicio = (total - 1 - i) * 0.14;
      final fin = inicio + 0.58; // y dura 58% del tiempo total

      return CurvedAnimation(
        parent: _controlador,
        // Interval = "esta animación solo ocurre entre el momento inicio y el momento fin".
        // easeOutBack = se pasa un poco del tamaño final y regresa: el REBOTE suave
        curve: Interval(inicio, fin, curve: Curves.easeOutBack),
        // Al cerrar usamos una curva sin rebote: se esconde rápido y limpio
        reverseCurve: Interval(inicio, fin, curve: Curves.easeInCubic),
      );
    });
  }

  // didUpdateWidget se ejecuta cuando la pantalla nos manda un valor nuevo.
  // Aquí revisamos si "abierto" cambió, y si sí, abrimos o cerramos la animación.
  @override
  void didUpdateWidget(MenuCrear anterior) {
    super.didUpdateWidget(anterior);

    if (widget.abierto != anterior.abierto) {
      if (widget.abierto) {
        _controlador.forward(); // reproducir hacia adelante (abrir)
      } else {
        _controlador.reverse(); // reproducir hacia atrás (cerrar)
      }
    }
  }

  // dispose = limpiar cuando el widget desaparece, para no gastar memoria
  @override
  void dispose() {
    for (final animacion in _animaciones) {
      animacion.dispose();
    }
    _controlador.dispose();
    super.dispose();
  }

  // Envuelve un botón con su animación: crece y sube desde el botón +
  Widget _itemAnimado(int i) {
    final animacion = _animaciones[i];

    // Los botones de arriba viajan más lejos, porque están más lejos del +
    final distancia = (_opciones.length - i) * 30.0;

    // AnimatedBuilder vuelve a dibujar lo de adentro en cada fotograma de la animación
    return AnimatedBuilder(
      animation: animacion,
      // "hijo" es el botón ya construido (así no se reconstruye en cada fotograma)
      builder: (context, hijo) {
        final valor = animacion.value; // 0.0 → 1.0 (y un poquito más por el rebote)

        // Transform.translate mueve el botón. Cuando valor = 1, ya llegó a su lugar.
        return Transform.translate(
          offset: Offset(0, (1 - valor) * distancia),
          // Transform.scale lo agranda: con valor = 0 es invisible (tamaño cero)
          child: Transform.scale(
            scale: valor,
            alignment: Alignment.bottomCenter, // crece desde su parte de abajo
            child: hijo,
          ),
        );
      },
      child: _ItemMenu(opcion: _opciones[i], alTocar: widget.alCerrar),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Distancia desde el borde de abajo hasta justo ARRIBA de la barra flotante:
    // zona segura del sistema + margen de la barra (14) + altura de la barra (56) + espacio (14)
    final inferior = MediaQuery.of(context).padding.bottom + 84;

    return AnimatedBuilder(
      animation: _controlador,
      builder: (context, _) {
        // Si el menú está totalmente cerrado, no dibujamos nada
        if (_controlador.isDismissed) return const SizedBox.shrink();

        final v = _controlador.value; // 0.0 → 1.0

        // IgnorePointer: mientras se está cerrando, no aceptamos más toques
        return IgnorePointer(
          ignoring: !widget.abierto,
          child: Stack(
            children: [
              // CAPA 1: el "telón" que difumina y oscurece un poco lo de atrás.
              // Al tocarlo, se cierra el menú.
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.alCerrar,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8 * v, sigmaY: 8 * v),
                    child: ColoredBox(color: Colors.black.withValues(alpha: 0.18 * v)),
                  ),
                ),
              ),

              // CAPA 2: los botones, centrados y pegados arriba de la barra
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: inferior),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // la columna mide solo lo necesario
                    children: [
                      // "for dentro de una lista": genera un botón por cada opción
                      for (var i = 0; i < _opciones.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10), // espacio entre botones
                        _itemAnimado(i),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Un botón del menú: círculo con ícono + nombre, sobre cristal
class _ItemMenu extends StatelessWidget {
  const _ItemMenu({required this.opcion, required this.alTocar});

  final _Opcion opcion;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final paleta = Paleta.de(context);

    return Pulsable(
      alTocar: () {
        // Por ahora solo cerramos el menú.
        // Aquí irá la acción de cada opción (crear álbum, collage...). Después.
        alTocar();
      },
      escala: 0.94,
      child: SizedBox(
        width: 210,
        child: Cristal(
          radio: 26,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: opcion.color.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(opcion.icono, color: opcion.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  opcion.titulo,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: paleta.texto,
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