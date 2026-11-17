import 'package:flutter/material.dart';

import '../tema.dart';
import 'pulsable.dart';

// Botón grande del color de tu marca, con animación al tocar
class BotonPrincipal extends StatelessWidget {
  const BotonPrincipal({super.key, required this.texto, required this.alTocar});

  final String texto;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Pulsable(
      alTocar: alTocar,
      escala: 0.96, // los botones anchos se encogen menos
      child: Container(
        height: 52,
        width: double.infinity, // ocupa todo el ancho
        alignment: Alignment.center, // texto centrado
        decoration: BoxDecoration(
          color: colorAcento,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          texto,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}