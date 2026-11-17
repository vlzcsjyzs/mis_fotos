import 'package:flutter/material.dart';

import '../tema.dart';
import 'cristal.dart';
import 'pulsable.dart';

// Un recuadro de la cuadrícula de Colecciones
class BotonColeccion extends StatelessWidget {
  const BotonColeccion({
    super.key,
    required this.icono,
    required this.titulo,
    required this.color,
    required this.alTocar,
  });

  final IconData icono; // el dibujo del ícono
  final String titulo; // el nombre que se muestra
  final Color color; // color propio de este botón
  final VoidCallback alTocar; // qué hacer al tocarlo

  @override
  Widget build(BuildContext context) {
    final paleta = Paleta.de(context);

    // Pulsable le da la animación de encogerse y rebotar
    return Pulsable(
      alTocar: alTocar,
      escala: 0.94,
      // Cristal es nuestra tarjeta con desenfoque y transparencia
      child: Cristal(
        radio: 28,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // todo alineado a la izquierda
          // spaceBetween = separa los elementos: el primero arriba y el último abajo
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Círculo con el ícono. El fondo es el mismo color, pero muy transparente (16%)
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(icono, color: color, size: 24),
            ),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: paleta.texto,
              ),
            ),
          ],
        ),
      ),
    );
  }
}