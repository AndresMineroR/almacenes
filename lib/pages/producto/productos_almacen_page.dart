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
        nombreAlma = arguments['NombreAlma'];
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
      print(categorias);
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
                  var productos = (categoriaSeleccionada != null && categoriaSeleccionada != 'todas')
                      ? (snapshot.data ?? []).where((producto) =>
                  producto['Categoria'] == categoriaSeleccionada).toList()
                      : (snapshot.data ?? []);
                  print('seleccionada $categoriaSeleccionada');
                  return ListView.builder(
                    itemCount: productos.length ?? 0,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              // Imagen como fondo
                              Container(
                                height: 180, // Ajusta la altura de la tarjeta
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12), // Bordes redondeados
                                  image: DecorationImage(
                                    image: NetworkImage(productos[index]['ImagenProducto'] ??
                                        "https://firebasestorage.googleapis.com/v0/b/inventarioabarrotes-935f9.firebasestorage.app/o/productos%2FLa%20marca%20del%20producto%20Definici%C3%B3n%2C%20clasificaci%C3%B3n%2C%20c%C3%B3mo%20nacen%20y%20m%C3%A1s.jpg?alt=media&token=5f3ff423-6ab7-46d4-9387-e2bdab9a602c"),
                                    fit: BoxFit.cover, // Ajusta la imagen al tamaño del contenedor
                                  ),
                                ),
                              ),
                              // Contenedor de texto en la parte inferior
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  width: double.infinity, // Ocupa todo el ancho
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 20, 83, 21).withOpacity(0.7), // Fondo oscuro con transparencia
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        productos[index]['Nombre'] ?? 'Sin Nombre',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Descripción: ${productos[index]['Descripcion'] ?? 'Sin Descripción'}\n'
                                            'Stock: ${productos[index]['Stock'] ?? 'Sin Stock'}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // PopupMenuButton en la esquina superior derecha
                              Positioned(
                                top: 10,
                                right: 10,
                                child: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, color: Colors.white),
                                  onSelected: (String value) async {
                                    if (value == 'editar') {
                                      await Navigator.pushNamed(context, '/editProducto', arguments: {
                                        "Nombre": productos[index]['Nombre'],
                                        "Descripcion": productos[index]['Descripcion'],
                                        "Categoria": productos[index]['Categoria'],
                                        "Precio": productos[index]['Precio'],
                                        "Caducidad": productos[index]['Caducidad'],
                                        "Lote": productos[index]['Lote'],
                                        "Stock": productos[index]['Stock'],
                                        "uid": productos[index]['uid'],
                                        'uidAlma': uidAlma,
                                        "ImagenProducto": productos[index]['ImagenProducto'],
                                      });
                                      setState(() {});
                                    } else if (value == 'eliminar') {
                                      bool confirmDelete = await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Confirmar eliminación'),
                                            content: const Text('¿Estás seguro de que deseas eliminar este producto?'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop(false);
                                                },
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop(true);
                                                },
                                                child: const Text('Eliminar'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      if (confirmDelete == true) {
                                        await deleteProducto(productos[index]['uid']);
                                        setState(() {});
                                      }
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return [
                                      const PopupMenuItem<String>(
                                        value: 'editar',
                                        child: Text('Editar'),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'eliminar',
                                        child: Text('Eliminar'),
                                      ),
                                    ];
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () async {
                          await Navigator.pushNamed(context, '/mostrarProducto', arguments: {
                            "Nombre": productos[index]['Nombre'],
                            "Descripcion": productos[index]['Descripcion'],
                            "Categoria": productos[index]['Categoria'],
                            "Precio": productos[index]['Precio'],
                            "Caducidad": productos[index]['Caducidad'],
                            "Lote": productos[index]['Lote'],
                            "Stock": productos[index]['Stock'],
                            "ImagenProducto": productos[index]['ImagenProducto'],
                          });
                        },
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
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
