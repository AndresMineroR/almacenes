import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:almacenes/servicies/firebase_service.dart';

class NuevaVentaPage extends StatefulWidget {
  final String uidAlmacen;
  final String nombreAlmacen;

  const NuevaVentaPage({
    Key? key,
    required this.uidAlmacen,
    required this.nombreAlmacen,
  }) : super(key: key);

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
      MaterialPageRoute(
        builder: (context) => const SimpleBarcodeScannerPage(),
      ),
    );

    if (result != null) {
      await verificarProducto(result.toString());
    }
  }

  Future<void> verificarProducto(String codigo) async {
    print("📌 Código escaneado: $codigo");
    print("📌 UID Almacén: ${widget.uidAlmacen}");

    try {
      var productoDoc = await baseInventarioP.collection('productos').doc(codigo).get();

      if (productoDoc.exists) {
        var producto = productoDoc.data();
        print("✅ Producto encontrado: $producto");

        // Validar que el producto pertenezca al almacén actual
        if (producto?['UidAlma'] == widget.uidAlmacen) {
          setState(() {
            int index = productos.indexWhere((p) => p['codigo'] == codigo);
            if (index != -1) {
              productos[index]['cantidad'] += 1;
              print("🔄 Se aumentó la cantidad del producto existente.");
            } else {
              // Convertir el precio y el stock
              double precio = 0.0;
              if (producto?['Precio'] is num) {
                precio = (producto?['Precio'] as num).toDouble();
              } else if (producto?['Precio'] is String) {
                precio = double.tryParse(producto?['Precio']) ?? 0.0;
              }

              int stock = 0;
              if (producto?['Stock'] is num) {
                stock = (producto?['Stock'] as num).toInt();
              } else if (producto?['Stock'] is String) {
                stock = int.tryParse(producto?['Stock']) ?? 0;
              }

              productos.add({
                "codigo": codigo,
                "nombre": producto?['Nombre'] ?? "Desconocido",
                "precio": precio,
                "cantidad": 1,
                "stock": stock,
              });
              print("🆕 Producto agregado a la lista.");
            }
            _calcularTotales();
          });
        } else {
          print("⚠️ Producto encontrado, pero no pertenece a este almacén.");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Este producto no pertenece a este almacén.")),
          );
        }
      } else {
        print("❌ Producto no encontrado en Firestore.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Producto no encontrado en este almacén")),
        );
      }
    } catch (e) {
      print("⚠️ Error en la consulta de Firestore: $e");
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
    // Validación: Si no hay productos, mostrar alerta y salir
    if (productos.isEmpty || totalVenta == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay productos en la venta.")),
      );
      return;
    }

    try {
      // Actualizar el stock de los productos mediante un batch
      var batch = baseInventario.batch();

      for (var producto in productos) {
        String codigo = producto['codigo'];
        int cantidadVendida = producto['cantidad'];

        var productoDoc = await baseInventario.collection('productos').doc(codigo).get();

        if (!productoDoc.exists) {
          print("❌ Producto con código $codigo no encontrado en la base de datos.");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("El producto ${producto['nombre']} no existe en Firestore.")),
          );
          return;
        }

        var productoData = productoDoc.data();
        int stockActual = 0;
        if (productoData?['Stock'] is num) {
          stockActual = (productoData?['Stock'] as num).toInt();
        } else if (productoData?['Stock'] is String) {
          stockActual = int.tryParse(productoData?['Stock']) ?? 0;
        }

        print("📦 Producto: ${producto['nombre']} | Stock actual: $stockActual | Vendiendo: $cantidadVendida");

        if (stockActual >= cantidadVendida) {
          batch.update(
            baseInventario.collection('productos').doc(codigo),
            {'Stock': ((stockActual - cantidadVendida)).toString()},
          );
        } else {
          print("⚠️ Stock insuficiente para ${producto['nombre']}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No hay suficiente stock para ${producto['nombre']}")),
          );
          return;
        }
      }

      // Ejecutar las actualizaciones en lote
      await batch.commit();

      // Preparar el detalle de productos vendido (array para Firestore)
      List<Map<String, dynamic>> productosDetalle = productos.map((producto) {
        return {
          'codigo': producto['codigo'],
          'nombre': producto['nombre'],
          'cantidad': producto['cantidad'],
          'precioUnitario': producto['precio'],
          'subtotal': producto['precio'] * producto['cantidad'],
        };
      }).toList();

      // Crear la venta en la colección "ventas" con campos extendidos para reportes
      await baseInventario.collection('ventas').add({
        'totalVenta': totalVenta,
        'fecha': DateTime.now(), // Fecha completa: día, hora, minutos y segundos
        'totalProductos': totalProductos,
        'productosDetalle': productosDetalle, // Array con el detalle de cada producto
        'uidAlmacen': widget.uidAlmacen,
        'nombreAlmacen': widget.nombreAlmacen,
        // Aquí podrías agregar más campos, como 'metodoPago', 'vendedor', 'descuentos', etc.
      });

      setState(() {
        productos.clear();
        totalVenta = 0.0;
        totalProductos = 0;
      });

      print("✅ Venta finalizada, stock actualizado y venta registrada.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Venta finalizada, stock actualizado y venta registrada.")),
      );

      Navigator.pop(context);
    } catch (e) {
      print("⚠️ Error en la finalización de la venta: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al finalizar la venta: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nueva Venta - ${widget.nombreAlmacen}"),
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
                            actualizarCantidad(index, productos[index]['cantidad'] - 1);
                          }
                        },
                      ),
                      Text("${productos[index]['cantidad']}"),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          actualizarCantidad(index, productos[index]['cantidad'] + 1);
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
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Productos escaneados: $totalProductos",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: finalizarVenta,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    "Finalizar Venta",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
