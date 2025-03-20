import 'package:flutter/material.dart';
import 'package:almacenes/servicies/firebase_service.dart';
import 'NuevaVenta_page.dart';


class VentaPage extends StatefulWidget {
  final String uidAlmacen;
  final String nombreAlmacen;// Recibir el almacén seleccionado

  const VentaPage({super.key, required this.uidAlmacen, required this.nombreAlmacen});

  @override
  State<VentaPage> createState() => _VentaPageState();
}

class _VentaPageState extends State<VentaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ventas - ${widget.nombreAlmacen}'),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NuevaVentaPage(uidAlmacen: widget.uidAlmacen, nombreAlmacen: widget.nombreAlmacen),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart, size: 50, color: Colors.blue),
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
