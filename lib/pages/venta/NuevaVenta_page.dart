import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:almacenes/servicies/firebase_service.dart';

class NuevaVentaPage extends StatefulWidget {
  final String uidAlmacen;
  final String nombreAlmacen;

  const NuevaVentaPage({
    super.key,
    required this.uidAlmacen,
    required this.nombreAlmacen,
  });

  @override
  State<NuevaVentaPage> createState() => _NuevaVentaPageState();
}

class _NuevaVentaPageState extends State<NuevaVentaPage> {
  List<Map<String, dynamic>> productos = [];
  double totalVenta = 0.0;
  int totalProductos = 0;

  Future<void> escanearCodigo() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SimpleBarcodeScannerPage()),
    );

    if (result != null) {
      await verificarProducto(result.toString());
    }
  }

  Future<void> verificarProducto(String codigo) async {
    var querySnapshot = await baseInventario
        .collection('productos')
        .where('uid', isEqualTo: codigo)
    //.where('UidAlma', isEqualTo: widget.uidAlmacen) // Validar que pertenece al almacén
        .limit(1) // Solo obtener un resultado
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var producto = querySnapshot.docs.first.data();

      setState(() {
        productos.add({
          "codigo": codigo,
          "nombre": producto['Nombre'] ?? "Desconocido",
          "precio": producto['Precio'] ?? 0.0,
          "cantidad": 1,
          "stock": producto['Stock'] ?? 0, // Agregar stock para actualizarlo
        });
        _calcularTotales();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Producto no encontrado en este almacén")),
      );
    }
  }


  void actualizarCantidad(int index, int nuevaCantidad) {
    setState(() {
      productos[index]['cantidad'] = nuevaCantidad;
      _calcularTotales();
    });
  }

  void _calcularTotales() {
    double nuevoTotal = 0.0;
    int nuevaCantidadTotal = 0;

    for (var producto in productos) {
      nuevoTotal += producto['precio'] * producto['cantidad'];
      nuevaCantidadTotal += (producto['cantidad'] as num).toInt();
    }

    setState(() {
      totalVenta = nuevoTotal;
      totalProductos = nuevaCantidadTotal;
    });
  }

  Future<void> finalizarVenta() async {
    for (var producto in productos) {
      String codigo = producto['codigo'];
      int cantidadVendida = producto['cantidad'];
      int stockActual = producto['stock'];

      if (stockActual >= cantidadVendida) {
        await baseInventario
            .collection('almacenes')
            .doc(widget.uidAlmacen)
            .collection('productos')
            .doc(codigo)
            .update({
          'Stock': stockActual - cantidadVendida,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "No hay suficiente stock para ${producto['nombre']}")),
        );
        return;
      }
    }

    setState(() {
      productos.clear();
      totalVenta = 0.0;
      totalProductos = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Venta finalizada y stock actualizado")),
    );

    Navigator.pop(context); // Regresar a la pantalla anterior
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nueva Venta - ${widget.nombreAlmacen}"), // ← Corrección aquí
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: escanearCodigo,
            child: const Text("Escanear Código de Barras"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(productos[index]['nombre']),
                  subtitle: Text("Precio: \$${productos[index]['precio']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (productos[index]['cantidad'] > 1) {
                            actualizarCantidad(
                                index, productos[index]['cantidad'] - 1);
                          }
                        },
                      ),
                      Text("${productos[index]['cantidad']}"),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          actualizarCantidad(
                              index, productos[index]['cantidad'] + 1);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Total: \$${totalVenta.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Productos escaneados: $totalProductos",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: finalizarVenta,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Finalizar Venta",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
