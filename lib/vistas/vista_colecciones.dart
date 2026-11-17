import 'package:flutter/material.dart';

import '../tema.dart';
import '../widgets/boton_coleccion.dart';

// La pantalla de Colecciones. Antes vivía dentro de pantalla_principal.dart;
// ahora tiene su propio archivo porque va a crecer.
class VistaColecciones extends StatelessWidget {
  const VistaColecciones({super.key});

  @override
  Widget build(BuildContext context) {
    // Column permite poner más cosas debajo de la cuadrícula en el futuro
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // GridView.count = una cuadrícula con un número fijo de columnas
        GridView.count(
          crossAxisCount: 2, // 2 columnas
          // shrinkWrap = "mide solo lo que necesitas, no todo el espacio disponible".
          // Es necesario porque esta cuadrícula vive dentro de otra lista que se desplaza.
          shrinkWrap: true,
          // La cuadrícula NO se desplaza por su cuenta; lo hace la pantalla completa
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero, // sin espacio extra alrededor
          mainAxisSpacing: 14, // espacio vertical entre recuadros
          crossAxisSpacing: 14, // espacio horizontal entre recuadros
          // Proporción ancho/alto de cada recuadro: 1.05 = casi cuadrado, un poco más ancho
          childAspectRatio: 1.05,
          children: [
            BotonColeccion(
              icono: Icons.photo_album_rounded,
              titulo: 'Álbumes',
              color: colorAcento, // tu color de marca
              alTocar: () {
                // Aquí irá la pantalla de álbumes
              },
            ),
            BotonColeccion(
              icono: Icons.delete_rounded,
              titulo: 'Papelera',
              color: const Color(0xFFFF5C7A), // coral
              alTocar: () {
                // Aquí irá la papelera
              },
            ),
            BotonColeccion(
              icono: Icons.star_rounded,
              titulo: 'Destacados',
              color: const Color(0xFFFFB020), // ámbar
              alTocar: () {
                // Aquí irán tus favoritos
              },
            ),
            // Para agregar un cuarto botón, copia uno de los de arriba y cambia sus datos.
            // La cuadrícula lo acomoda sola en el espacio libre.
          ],
        ),

        // Aquí abajo irá más contenido de Colecciones en el futuro
      ],
    );
  }
}