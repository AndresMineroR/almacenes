import 'package:flutter/material.dart';
import '../NuevaVenta_page.dart';
import 'package:almacenes/servicies/firebase_service.dart';

import 'NuevaVenta_page.dart'; // Importar servicio de Firebase

class VentaPage extends StatefulWidget {
  const VentaPage({super.key});

  @override
  State<VentaPage> createState() => _VentaPageState();
}

class _VentaPageState extends State<VentaPage> {
  Future<void> _seleccionarAlmacen() async {
    List almacenes = await getAlmacenes(); // Obtener lista de almacenes

    if (almacenes.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text("Selecciona un almacén"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: almacenes.map((almacen) {
                return ListTile(
                  title: Text(almacen['NombreAlma'] ?? 'Sin nombre'),
                  onTap: () {
                    String uidAlmacen = almacen['uidAlma'] ?? '';
                    String nombreAlmacen = almacen['NombreAlma'] ?? 'Desconocido';

                    Navigator.pop(context); // Cerrar el diálogo
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NuevaVentaPage(
                          uidAlmacen: uidAlmacen,
                          nombreAlmacen: nombreAlmacen,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay almacenes disponibles")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas Usuario'),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
          child: InkWell(
            onTap: _seleccionarAlmacen, // Llama a la función para seleccionar almacén
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shopping_cart, size: 50, color: Colors.blue),
                  const SizedBox(height: 10),
                  const Text(
                    "Venta Nueva",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
