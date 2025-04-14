import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:sgames/providers/bluetooth_manager.dart';


class MVCMeasure extends StatefulWidget {
  final String miniJuegoId; // Identificador del mini juego para saber a cuál guardar el maxForce.
  final ValueChanged<double> onMaxForceSaved; // Callback para guardar maxForce
  final VoidCallback? onExit; // Callback opcional para manejar la salida

  const MVCMeasure({
    super.key,
    required this.miniJuegoId,
    required this.onMaxForceSaved,
    this.onExit});


  @override
  State<MVCMeasure> createState() => _MVCMeasureState();
}

class _MVCMeasureState extends State<MVCMeasure> {
  BluetoothManager? _bluetoothManager;
  double maxForce = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bluetoothManager = Provider.of<BluetoothManager>(context, listen: false);
      _bluetoothManager?.startReceivingMeasurements();
    });
  }

  @override
  void dispose() {
    final device = _bluetoothManager?.connectedDevice;
    if (device != null) {
      _bluetoothManager?.stopReceivingMeasurements(device);
    }
    super.dispose();
  }

  void _handleExit() {
    if (widget.onExit != null) {
      widget.onExit!();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fuerza Máxima Voluntaria"),
        leading: IconButton(
            onPressed: _handleExit,
            icon: const Icon(Icons.arrow_back)),
      ),
      body: Consumer<BluetoothManager>(
        builder: (context, bluetoothManager, child) {
          // Obtén el peso actual (si está disponible)
          double currentWeight = bluetoothManager.currentWeight ?? 0.0;

          // Actualiza el valor máximo
          if (currentWeight > maxForce) {
              maxForce = currentWeight;
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Gráfico de fuerza máxima
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        getDrawingHorizontalLine: (value) {
                          // Dibuja una línea roja para maxForce
                          if (value == maxForce) {
                            return FlLine(
                              color: Colors.red, // Línea roja para maxForce
                              strokeWidth: 2,
                            );
                          }
                          return FlLine(
                            color: Colors.black12, // Línea gris para el resto
                            strokeWidth: 0.5,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: true),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: currentWeight, // Valor actual de la fuerza
                              color: currentWeight == maxForce
                                  ? Colors.green // Color verde si es el máximo
                                  : Colors.blue, // Color azul para los demás valores
                              width: 80,
                              borderRadius: BorderRadius.zero,
                            ),
                          ],
                        ),
                      ],
                      minY: 0,
                      maxY: 100, // Configurar el eje Y de 0 a 120 kg
                    ),
                  ),
                ),
              ),
              // Mostrar el peso máximo alcanzado
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Fuerza máxima alcanzada: ${maxForce.toStringAsFixed(2)} kg',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              // Botón "Usar MVC"
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () {
                    double truncatedMaxForce = double.parse(maxForce.toStringAsFixed(2));
                    widget.onMaxForceSaved(truncatedMaxForce);
                    _handleExit();
                  },
                  child: const Text("Usar MVC", style: TextStyle(fontSize: 22)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}