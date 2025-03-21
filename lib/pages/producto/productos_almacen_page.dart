import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:almacenes/servicies/firebase_service.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class ProductosAlmacen extends StatefulWidget {
  const ProductosAlmacen({
    super.key,
  });

  @override
  State<ProductosAlmacen> createState() => _ProductosAlmacenState();
}

class _ProductosAlmacenState extends State<ProductosAlmacen> {
  late String uidAlma;
  late String nombreAlma;
  String? categoriaSeleccionada;
  List<Map<String, dynamic>> categorias = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
      setState(() {
        uidAlma = arguments['uidAlma'];
        nombreAlma = arguments['nombreAlma'];
      });
      await cargarCategorias();
      setState(() {
        categoriaSeleccionada = categorias.isNotEmpty ? categorias.first['id'] : 'todas';
      });
    });
  }

  Future<void> cargarCategorias() async {
    final snapshot = await FirebaseFirestore.instance.collection('categorias').get();
    setState(() {
      categorias = [
    {'id': 'todas', 'NombreCat': 'Todas'},
      ...snapshot.docs.map((doc) => {
        'id': doc.id,
        'NombreCat': doc['NombreCat'], // Asegúrate de que el campo 'nombre' exista en la base de datos
      }).toList(),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos ' + nombreAlma),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: categoriaSeleccionada,
              items: categorias.map((categoria) {
                return DropdownMenuItem<String>(
                  value: categoria['id'],
                  child: Text(categoria['NombreCat']),
                );
              }).toList(),
              onChanged: (String? nuevaSeleccion) {
                setState(() {
                  categoriaSeleccionada = nuevaSeleccion;
                });
              },
              decoration: InputDecoration(
                labelText: 'Selecciona una categoría',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: getProductosAlmacen(uidAlma),
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  var productos = categoriaSeleccionada != null && categoriaSeleccionada != 'todas'
                      ? snapshot.data?.where((producto) =>
                  producto['Categoria'] == categoriaSeleccionada).toList()
                      : snapshot.data;

                  return ListView.builder(
                    itemCount: productos?.length ?? 0,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Card(
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Producto',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(255, 206, 148, 148),
                                        ),
                                      ),
                                      Text(
                                        'Nombre: ' +
                                            productos?[index]['Nombre'] +
                                            '\nDescripción: ' +
                                            productos?[index]['Descripcion'] +
                                            '\nStock: ' +
                                            productos?[index]['Stock'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (String value) async {
                                    if (value == 'editar') {
                                      await Navigator.pushNamed(context, '/editProducto', arguments: {
                                        "Nombre": productos?[index]['Nombre'],
                                        "Descripcion": productos?[index]['Descripcion'],
                                        "Categoria": productos?[index]['Categoria'],
                                        "Precio": productos?[index]['Precio'],
                                        "Caducidad": productos?[index]['Caducidad'],
                                        "Stock": productos?[index]['Stock'],
                                        "Lote": productos?[index]['Lote'],
                                        "uid": productos?[index]['uid'],
                                        "UidAlma": productos?[index]['UidAlma'],
                                      });
                                    } else if (value == 'eliminar') {
                                      bool confirmDelete = await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Confirmar eliminación'),
                                            content: Text(
                                                '¿Estás seguro de que deseas eliminar este elemento?'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop(false);
                                                },
                                                child: Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop(true);
                                                },
                                                child: Text('Eliminar'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      if (confirmDelete == true) {
                                        await deleteProducto(productos?[index]['uid']);
                                      }
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return [
                                      PopupMenuItem<String>(
                                        value: 'editar',
                                        child: Text('Editar'),
                                      ),
                                      PopupMenuItem<String>(
                                        value: 'eliminar',
                                        child: Text('Eliminar'),
                                      ),
                                    ];
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SimpleBarcodeScannerPage(),
            ),
          );
          if (result != null && result != "-1") {
            await Navigator.pushNamed(
              context,
              '/addProducto',
              arguments: {
                "uidProducto": result.toString(),
                'uidAlma': uidAlma
              },
            );
            setState(() {});
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
