import 'package:flutter/material.dart';

import '../tema.dart';
import '../widgets/boton_coleccion.dart';
import '../widgets/cristal.dart';
import '../widgets/pulsable.dart';

// Describe un atajo de la tira: su ícono, su nombre y su color
class _Atajo {
  const _Atajo(this.icono, this.titulo, this.color);

  final IconData icono;
  final String titulo;
  final Color color;
}

// LISTA DE ATAJOS. Para agregar uno nuevo, añade una línea aquí
// y aparecerá solo en la tira, antes del botón "+".
const List<_Atajo> _atajos = [
  _Atajo(Icons.photo_album_rounded, 'Álbumes', colorAcento),
  _Atajo(Icons.delete_rounded, 'Papelera', Color(0xFFFF5C7A)),
  _Atajo(Icons.star_rounded, 'Destacados', Color(0xFFFFB020)),
];

class VistaColecciones extends StatelessWidget {
  const VistaColecciones({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // LA TIRA: una lista horizontal con altura fija
        SizedBox(
          height: 124,
          child: ListView.separated(
            scrollDirection: Axis.horizontal, // se mueve de izquierda a derecha
            // Clip.none = no recortar lo que se sale (así se ven las sombras completas)
            clipBehavior: Clip.none,
            // 24 de espacio a los lados: la tira empieza alineada con el título,
            // pero al desplazarse llega hasta el borde de la pantalla
            padding: const EdgeInsets.symmetric(horizontal: 24),
            // Rebote suave al llegar al final de la tira
            physics: const BouncingScrollPhysics(),
            // +1 porque al final va el botón "+"
            itemCount: _atajos.length + 1,
            // Lo que se dibuja ENTRE cada elemento: un espacio de 12
            separatorBuilder: (context, indice) => const SizedBox(width: 12),
            // itemBuilder construye cada elemento según su número (indice)
            itemBuilder: (context, indice) {
              // El último número corresponde al botón "+"
              if (indice == _atajos.length) return const _BotonAgregarAtajo();

              final atajo = _atajos[indice];
              return SizedBox(
                width: 132, // ancho fijo de cada recuadro
                child: BotonColeccion(
                  icono: atajo.icono,
                  titulo: atajo.titulo,
                  color: atajo.color,
                  alTocar: () {
                    // Aquí irá la pantalla de cada atajo
                  },
                ),
              );
            },
          ),
        ),

        // Aquí abajo irá más contenido de Colecciones en el futuro.
        // Recuerda envolverlo en Padding(horizontal: 24) para que quede alineado.
      ],
    );
  }
}

// El botón pequeño "+" al final de la tira
class _BotonAgregarAtajo extends StatelessWidget {
  const _BotonAgregarAtajo();

  @override
  Widget build(BuildContext context) {
    final paleta = Paleta.de(context);

    // Center lo coloca en el medio de la altura de la tira
    return Center(
      child: Pulsable(
        alTocar: () {
          // Aquí irá el selector para agregar nuevos atajos
        },
        escala: 0.85,
        child: Cristal(
          radio: 26,
          child: SizedBox(
            width: 52,
            height: 52,
            child: Icon(
              Icons.add_rounded,
              color: paleta.texto.withValues(alpha: 0.7),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}