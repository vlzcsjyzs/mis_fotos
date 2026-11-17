import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para la vibración (HapticFeedback)

// Envuelve cualquier widget y le da una animación al tocarlo:
// se encoge al presionar y rebota al soltar.
class Pulsable extends StatefulWidget {
  const Pulsable({
    super.key,
    required this.child,
    required this.alTocar,
    this.escala = 0.92, // qué tanto se encoge: 0.92 = al 92% de su tamaño
  });

  final Widget child;
  final VoidCallback alTocar;
  final double escala;

  @override
  State<Pulsable> createState() => _PulsableState();
}

class _PulsableState extends State<Pulsable> {
  bool _presionado = false; // true mientras el dedo está encima

  void _presionar() {
    setState(() => _presionado = true);
    HapticFeedback.lightImpact(); // vibración suave
  }

  void _soltar() {
    // Esperamos 90 milisegundos antes de volver al tamaño normal.
    // Sin esta pausa, un toque rápido terminaría tan veloz que no se notaría la animación.
    Future.delayed(const Duration(milliseconds: 90), () {
      // "mounted" = ¿el widget sigue en pantalla? Si ya se cerró, no hacemos nada.
      if (mounted) setState(() => _presionado = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _presionar(), // el dedo toca la pantalla
      onTapUp: (_) => _soltar(), // el dedo se levanta
      onTapCancel: _soltar, // el dedo se desliza fuera: cancelamos
      onTap: widget.alTocar, // el toque se completó: ejecutamos la acción
      // AnimatedScale cambia el tamaño con animación.
      // Curves.easeOutBack hace que "rebote": se pasa un poco y se acomoda.
      child: AnimatedScale(
        scale: _presionado ? widget.escala : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}