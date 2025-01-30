import 'package:flutter/material.dart';

class MVCMeasure extends StatelessWidget {
  const MVCMeasure({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medición de Fuerza Máxima"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Regresar al menú de resistencia
          },
          child: const Text("Regresar"),
        ),
      ),
    );
  }
}