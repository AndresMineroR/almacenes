import 'package:flutter/material.dart';
import 'package:almacenes/servicies/firebase_service.dart';

class Productos extends StatefulWidget {
  const Productos({
    super.key,
  });

  @override
  State<Productos> createState() => _ProductosState();
}

class _ProductosState extends State<Productos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
      ),
      body: FutureBuilder(
        future: getProductos(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.length,
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
                              image: NetworkImage(snapshot.data?[index]['ImagenProducto'] ??
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
                              color: const Color.fromARGB(255, 20, 83, 21).withOpacity(0.7), // Fondo oscuro con transparencia
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data?[index]['Nombre'] ?? 'Sin Nombre',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Descripción: ${snapshot.data?[index]['Descripcion'] ?? 'Sin Descripción'}\n'
                                      'Stock: ${snapshot.data?[index]['Stock'] ?? 'Sin Stock'}',
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
                        /*Positioned(
                          top: 10,
                          right: 10,
                          child: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Colors.white),
                            onSelected: (String value) async {
                              if (value == 'editar') {
                                await Navigator.pushNamed(context, '/editProducto', arguments: {
                                  "Nombre": snapshot.data?[index]['Nombre'],
                                  "Descripcion": snapshot.data?[index]['Descripcion'],
                                  "Categoria": snapshot.data?[index]['Categoria'],
                                  "Precio": snapshot.data?[index]['Precio'],
                                  "Caducidad": snapshot.data?[index]['Caducidad'],
                                  "Lote": snapshot.data?[index]['Lote'],
                                  "Stock": snapshot.data?[index]['Stock'],
                                  "ImagenProducto": snapshot.data?[index]['ImagenProducto'],
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
                                  await deleteProducto(snapshot.data?[index]['uidProducto']);
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
                        ),*/
                      ],
                    ),
                  ),
                  onTap: () async {
                    await Navigator.pushNamed(context, '/mostrarProducto', arguments: {
                      "Nombre": snapshot.data?[index]['Nombre'],
                      "Descripcion": snapshot.data?[index]['Descripcion'],
                      "Categoria": snapshot.data?[index]['Categoria'],
                      "Precio": snapshot.data?[index]['Precio'],
                      "Caducidad": snapshot.data?[index]['Caducidad'],
                      "Lote": snapshot.data?[index]['Lote'],
                      "Stock": snapshot.data?[index]['Stock'],
                      "ImagenProducto": snapshot.data?[index]['ImagenProducto'],
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
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/addProducto');
          setState(() {});
        },
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
