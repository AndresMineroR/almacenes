import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:almacenes/servicies/firebase_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import '../../main.dart';

/* archivo para pruebas
class ProductosAlmacen extends StatefulWidget {

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final Future<List<Map<String, dynamic>>> Function(String, String)? getProductos;

  const ProductosAlmacen({
    super.key,
    required this.auth,
    required this.firestore,
    this.getProductos,
  });

  @override
  State<ProductosAlmacen> createState() => _ProductosAlmacenState();
}

class _ProductosAlmacenState extends State<ProductosAlmacen> {
  String uidAlma = '';
  String nombreAlma = '';
  String UidUser = '';
  String? categoriaSeleccionada;
  List<Map<String, dynamic>> categorias = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String productName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'stock_channel',
      'Stock Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Stock Actualizado',
      'El producto \"$productName\" ya no está en stock bajo.',
      platformChannelSpecifics,
    );
  }

  Future<void> _loadUserData() async {
    try {
      User? user = widget.auth.currentUser;
      if (user != null) {
        setState(() {
          UidUser = user.uid;
        });
      }
    } catch (e) {
      print('Error cargando datos del usuario: $e');
    }
  }

  Future<void> cargarCategorias() async {
    final snapshot = await widget.firestore.collection('categorias').where('IdPropietario', isEqualTo: UidUser).get();
    setState(() {
      categorias = [
        {'id': 'todas', 'NombreCat': 'Todas'},
        ...snapshot.docs.map((doc) => {'id': doc.id, 'NombreCat': doc['NombreCat']}).toList(),
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
              future: widget.getProductos!(uidAlma,UidUser),
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  var productos = (categoriaSeleccionada != null &&
                      categoriaSeleccionada != 'todas')
                      ? (snapshot.data ?? [])
                      .where((producto) =>
                  producto['Categoria'] == categoriaSeleccionada)
                      .toList()
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
                                  borderRadius: BorderRadius.circular(
                                      12), // Bordes redondeados
                                  image: DecorationImage(
                                    image: NetworkImage(productos[index]
                                    ['ImagenProducto'] ??
                                        "https://firebasestorage.googleapis.com/v0/b/inventarioabarrotes-935f9.firebasestorage.app/o/productos%2FLa%20marca%20del%20producto%20Definici%C3%B3n%2C%20clasificaci%C3%B3n%2C%20c%C3%B3mo%20nacen%20y%20m%C3%A1s.jpg?alt=media&token=5f3ff423-6ab7-46d4-9387-e2bdab9a602c"),
                                    fit: BoxFit
                                        .cover, // Ajusta la imagen al tamaño del contenedor
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
                                    color: const Color.fromARGB(255, 20, 83, 21)
                                        .withOpacity(
                                        0.7), // Fondo oscuro con transparencia
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        productos[index]['Nombre'] ??
                                            'Sin Nombre',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Descripción: ${productos[index]['Descripcion'] ?? 'Sin Descripción'}\n'
                                            'Stock: ${productos[index]['Stock'] ?? 'Sin Stock'}\n'
                                            'CodigoBarras: ${productos[index]['CodigoBarras'] ?? 'Sin CodigoBarras'}',
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
                                  icon: const Icon(Icons.more_vert,
                                      color: Colors.white),
                                  onSelected: (String value) async {
                                    if (value == 'editar') {
                                      await Navigator.pushNamed(
                                          context, '/editProducto',
                                          arguments: {
                                            "Nombre": productos[index]
                                            ['Nombre'],
                                            "Descripcion": productos[index]
                                            ['Descripcion'],
                                            "Categoria": productos[index]
                                            ['Categoria'],
                                            "Precio": productos[index]
                                            ['Precio'],
                                            "Caducidad": productos[index]
                                            ['Caducidad'],
                                            "Lote": productos[index]['Lote'],
                                            "Stock": productos[index]['Stock'],
                                            "uid": productos[index]['uid'],
                                            'uidAlma': uidAlma,
                                            "ImagenProducto": productos[index]
                                            ['ImagenProducto'],
                                          });
                                      setState(() {});
                                    } else if (value == 'eliminar') {
                                      bool confirmDelete = await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                                'Confirmar eliminación'),
                                            content: const Text(
                                                '¿Estás seguro de que deseas eliminar este producto?'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(false);
                                                },
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(true);
                                                },
                                                child: const Text('Eliminar'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      if (confirmDelete == true) {
                                        await deleteProducto(
                                            productos[index]['uid']);
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
                          await Navigator.pushNamed(context, '/mostrarProducto',
                              arguments: {
                                "Nombre": productos[index]['Nombre'],
                                "Descripcion": productos[index]['Descripcion'],
                                "Categoria": productos[index]['Categoria'],
                                "Precio": productos[index]['Precio'],
                                "Caducidad": productos[index]['Caducidad'],
                                "Lote": productos[index]['Lote'],
                                "Stock": productos[index]['Stock'],
                                "ImagenProducto": productos[index]
                                ['ImagenProducto'],
                                "CodigoBarras": productos[index]
                                ['CodigoBarras'],
                                "Almacen": nombreAlma,
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
            MaterialPageRoute(builder: (context) => const SimpleBarcodeScannerPage()),
          );

          if (result != null && result != "-1") {
            String scannedCode = result.toString();
            QuerySnapshot query = await widget.firestore
                .collection('productos')
                .where('CodigoBarras', isEqualTo: scannedCode)
                .where('UidAlma', isEqualTo: uidAlma)
                .get();

            if (query.docs.isNotEmpty) {
              TextEditingController cantidadController = TextEditingController();
              bool? confirmUpdate = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Actualizar stock'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Ingrese la cantidad de artículos a agregar:'),
                        TextField(controller: cantidadController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Cantidad')),
                      ],
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Aceptar')),
                    ],
                  );
                },
              );

              if (confirmUpdate == true) {
                int cantidadAgregar = int.tryParse(cantidadController.text) ?? 0;
                if (cantidadAgregar > 0) {
                  DocumentSnapshot productoDoc = query.docs.first;
                  int stockActual = int.tryParse(productoDoc['Stock'].toString()) ?? 0;
                  int nuevoStock = stockActual + cantidadAgregar;

                  await widget.firestore.collection('productos').doc(productoDoc.id).update({'Stock': nuevoStock.toString()});

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stock actualizado a $nuevoStock')));

                  if (nuevoStock > 10) {
                    _showNotification(productoDoc['Nombre']);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingrese una cantidad válida')));
                }
              }
            } else {
              await Navigator.pushNamed(context, '/addProducto', arguments: {"uidProducto": scannedCode, "uidAlma": uidAlma});
              setState(() {});
            }
          }
        },
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),




    );
  }
}
aqui termina el codido de las pruebas.
*/

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
  String UidUser = '';
  String? categoriaSeleccionada;
  List<Map<String, dynamic>> categorias = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
      setState(() {
        uidAlma = arguments['uidAlma'];
        nombreAlma = arguments['NombreAlma'];
      });
      await cargarCategorias();
      setState(() {
        categoriaSeleccionada =
            categorias.isNotEmpty ? categorias.first['id'] : 'todas';
      });
    });
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String productName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'stock_channel',
      'Stock Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Stock Actualizado',
      'El producto "$productName" ya no está en stock bajo.',
      platformChannelSpecifics,
    );
  }


  Future<void> _loadUserData() async {
    try {
      // Obtener el usuario autenticado
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        setState(() {
          UidUser = user.uid ?? '';
        });
      }
    } catch (e) {
      print('Error cargando datos del usuario: $e');
    }
  }

  Future<void> cargarCategorias() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('categorias')
            .where('IdPropietario', isEqualTo: UidUser).get();
    setState(() {
      categorias = [
        {'id': 'todas', 'NombreCat': 'Todas'},
        ...snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'NombreCat': doc[
                      'NombreCat'], // Asegúrate de que el campo 'nombre' exista en la base de datos
                })
            .toList(),
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
              future: getProductosAlmacen(uidAlma,UidUser),
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  var productos = (categoriaSeleccionada != null &&
                          categoriaSeleccionada != 'todas')
                      ? (snapshot.data ?? [])
                          .where((producto) =>
                              producto['Categoria'] == categoriaSeleccionada)
                          .toList()
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
                                  borderRadius: BorderRadius.circular(
                                      12), // Bordes redondeados
                                  image: DecorationImage(
                                    image: NetworkImage(productos[index]
                                            ['ImagenProducto'] ??
                                        "https://firebasestorage.googleapis.com/v0/b/inventarioabarrotes-935f9.firebasestorage.app/o/productos%2FLa%20marca%20del%20producto%20Definici%C3%B3n%2C%20clasificaci%C3%B3n%2C%20c%C3%B3mo%20nacen%20y%20m%C3%A1s.jpg?alt=media&token=5f3ff423-6ab7-46d4-9387-e2bdab9a602c"),
                                    fit: BoxFit
                                        .cover, // Ajusta la imagen al tamaño del contenedor
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
                                    color: const Color.fromARGB(255, 20, 83, 21)
                                        .withOpacity(
                                            0.7), // Fondo oscuro con transparencia
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        productos[index]['Nombre'] ??
                                            'Sin Nombre',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Descripción: ${productos[index]['Descripcion'] ?? 'Sin Descripción'}\n'
                                        'Stock: ${productos[index]['Stock'] ?? 'Sin Stock'}\n'
                                        'CodigoBarras: ${productos[index]['CodigoBarras'] ?? 'Sin CodigoBarras'}',
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
                                  icon: const Icon(Icons.more_vert,
                                      color: Colors.white),
                                  onSelected: (String value) async {
                                    if (value == 'editar') {
                                      await Navigator.pushNamed(
                                          context, '/editProducto',
                                          arguments: {
                                            "Nombre": productos[index]
                                                ['Nombre'],
                                            "Descripcion": productos[index]
                                                ['Descripcion'],
                                            "Categoria": productos[index]
                                                ['Categoria'],
                                            "Precio": productos[index]
                                                ['Precio'],
                                            "Caducidad": productos[index]
                                                ['Caducidad'],
                                            "Lote": productos[index]['Lote'],
                                            "Stock": productos[index]['Stock'],
                                            "uid": productos[index]['uid'],
                                            'uidAlma': uidAlma,
                                            "ImagenProducto": productos[index]
                                                ['ImagenProducto'],
                                          });
                                      setState(() {});
                                    } else if (value == 'eliminar') {
                                      bool confirmDelete = await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                                'Confirmar eliminación'),
                                            content: const Text(
                                                '¿Estás seguro de que deseas eliminar este producto?'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(false);
                                                },
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(true);
                                                },
                                                child: const Text('Eliminar'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      if (confirmDelete == true) {
                                        await deleteProducto(
                                            productos[index]['uid']);
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
                          await Navigator.pushNamed(context, '/mostrarProducto',
                              arguments: {
                                "Nombre": productos[index]['Nombre'],
                                "Descripcion": productos[index]['Descripcion'],
                                "Categoria": productos[index]['Categoria'],
                                "Precio": productos[index]['Precio'],
                                "Caducidad": productos[index]['Caducidad'],
                                "Lote": productos[index]['Lote'],
                                "Stock": productos[index]['Stock'],
                                "ImagenProducto": productos[index]
                                    ['ImagenProducto'],
                                "CodigoBarras": productos[index]
                                    ['CodigoBarras'],
                                "Almacen": nombreAlma,
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
            MaterialPageRoute(builder: (context) => const SimpleBarcodeScannerPage()),
          );

          if (result != null && result != "-1") {
            String scannedCode = result.toString();
            QuerySnapshot query = await FirebaseFirestore.instance
                .collection('productos')
                .where('CodigoBarras', isEqualTo: scannedCode)
                .where('UidAlma', isEqualTo: uidAlma)
                .get();

            if (query.docs.isNotEmpty) {
              TextEditingController cantidadController = TextEditingController();
              bool? confirmUpdate = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Actualizar stock'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Ingrese la cantidad de artículos a agregar:'),
                        TextField(controller: cantidadController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Cantidad')),
                      ],
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Aceptar')),
                    ],
                  );
                },
              );

              if (confirmUpdate == true) {
                int cantidadAgregar = int.tryParse(cantidadController.text) ?? 0;
                if (cantidadAgregar > 0) {
                  DocumentSnapshot productoDoc = query.docs.first;
                  int stockActual = int.tryParse(productoDoc['Stock'].toString()) ?? 0;
                  int nuevoStock = stockActual + cantidadAgregar;

                  await FirebaseFirestore.instance.collection('productos').doc(productoDoc.id).update({'Stock': nuevoStock.toString()});

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stock actualizado a $nuevoStock')));

                  if (nuevoStock > 10) {
                    _showNotification(productoDoc['Nombre']);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingrese una cantidad válida')));
                }
              }
            } else {
              await Navigator.pushNamed(context, '/addProducto', arguments: {"uidProducto": scannedCode, "uidAlma": uidAlma});
              setState(() {});
            }
          }
        },
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),




    );
  }
}
