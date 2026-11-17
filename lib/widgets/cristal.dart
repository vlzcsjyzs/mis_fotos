import 'dart:ui'; // Aquí vive ImageFilter, que hace el desenfoque

import 'package:flutter/material.dart';

import '../tema.dart'; // ".." = sube una carpeta (salimos de "widgets")

// Tarjeta de cristal reutilizable: la usaremos en la barra y en las tarjetas.
// StatelessWidget = un widget que no cambia por sí mismo (solo muestra lo que recibe).
class Cristal extends StatelessWidget {
  const Cristal({
    super.key,
    required this.child, // "required" = es obligatorio pasarlo
    this.radio = 28, // redondez de las esquinas (valor por defecto: 28)
    this.padding = EdgeInsets.zero, // espacio interno (por defecto, ninguno)
  });

  final Widget child; // lo que va dentro de la tarjeta
  final double radio;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final paleta = Paleta.de(context);
    final forma = BorderRadius.circular(radio);

    // DecoratedBox dibuja la sombra por fuera
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: forma,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 12), // la sombra cae 12 píxeles hacia abajo
          ),
        ],
      ),
      // ClipRRect recorta lo de adentro con esquinas redondas.
      // Sin esto, el desenfoque se aplicaría a un rectángulo con esquinas cuadradas.
      child: ClipRRect(
        borderRadius: forma,
        // BackdropFilter desenfoca TODO lo que está DETRÁS de este widget.
        // Ese es el efecto "cristal esmerilado".
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // a más número, más borroso
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: paleta.vidrio, // blanco semitransparente
              borderRadius: forma,
              border: Border.all(color: paleta.borde), // borde fino
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}