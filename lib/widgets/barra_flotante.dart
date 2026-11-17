import 'package:flutter/material.dart';

import '../tema.dart';
import 'cristal.dart';
import 'pulsable.dart';

class BarraFlotante extends StatelessWidget {
  const BarraFlotante({
    super.key,
    required this.pestanaActual,
    required this.menuAbierto, // NUEVO: ¿el menú del + está abierto?
    required this.alElegir,
    required this.alCrear,
  });

  final int pestanaActual; // 0 = Fotos, 1 = Colecciones
  final bool menuAbierto;
  final ValueChanged<int> alElegir;
  final VoidCallback alCrear;

  @override
  Widget build(BuildContext context) {
    return Cristal(
      radio: 30,
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: _Pestana(
              icono: Icons.image_outlined,
              iconoActivo: Icons.image_rounded,
              texto: 'Fotos',
              activa: pestanaActual == 0,
              alTocar: () => alElegir(0),
            ),
          ),
          const SizedBox(width: 4),
          _BotonCrear(alTocar: alCrear, abierto: menuAbierto),
          const SizedBox(width: 4),
          Expanded(
            child: _Pestana(
              icono: Icons.grid_view_outlined,
              iconoActivo: Icons.grid_view_rounded,
              texto: 'Colecciones',
              activa: pestanaActual == 1,
              alTocar: () => alElegir(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pestana extends StatelessWidget {
  const _Pestana({
    required this.icono,
    required this.iconoActivo,
    required this.texto,
    required this.activa,
    required this.alTocar,
  });

  final IconData icono;
  final IconData iconoActivo;
  final String texto;
  final bool activa;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final paleta = Paleta.de(context);

    // Color final de esta pestaña: de marca si está activa, apagado si no
    final colorFinal = activa ? colorAcento : paleta.texto.withValues(alpha: 0.55);

    return Pulsable(
      alTocar: alTocar,
      // AnimatedContainer anima el fondo de la "píldora" al cambiar de pestaña.
      // easeOutCubic arranca rápido y frena suave: se siente fluido.
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        height: 44, // altura fija de cada pestaña
        decoration: BoxDecoration(
          color: activa ? colorAcento.withValues(alpha: 0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        // TweenAnimationBuilder anima UN valor (aquí un color) de su valor anterior al nuevo.
        // Así el ícono y el texto cambian de color con transición, no de golpe.
        child: TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: colorFinal),
          duration: const Duration(milliseconds: 350),
          builder: (context, colorAnimado, _) {
            return Center(
              // FittedBox reduce el contenido si no cabe, para evitar que se desborde
              child: FittedBox(
                fit: BoxFit.scaleDown,
                // Row = ícono y texto lado a lado (antes eran Column: uno sobre otro)
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(activa ? iconoActivo : icono, color: colorAnimado, size: 22),
                    const SizedBox(width: 6),
                    Text(
                      texto,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorAnimado,
                        fontWeight: activa ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BotonCrear extends StatelessWidget {
  const _BotonCrear({required this.alTocar, required this.abierto});

  final VoidCallback alTocar;
  final bool abierto; // true = el menú está abierto

  @override
  Widget build(BuildContext context) {
    return Pulsable(
      alTocar: alTocar,
      escala: 0.85,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: colorAcento,
          shape: BoxShape.circle,
        ),
        // AnimatedRotation gira su contenido con animación.
        // 0.125 vueltas = 45 grados: un "+" girado 45° se ve como una "×"
        child: AnimatedRotation(
          turns: abierto ? 0.125 : 0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack, // con un pequeño rebote al girar
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}