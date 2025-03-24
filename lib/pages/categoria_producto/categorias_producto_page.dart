import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:almacenes/servicies/firebase_service.dart';

class CategoirasProducto extends StatefulWidget {
  const CategoirasProducto({
    super.key,
  });

  @override
  State<CategoirasProducto> createState() => _CategoirasProductoState();
}

class _CategoirasProductoState extends State<CategoirasProducto> {
  String UidUser = '';
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Obtener el usuario autenticado
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        setState(() {
          UidUser = user.uid;
          isLoading = false; // Usuario obtenido, se detiene la carga
        });
        print("UID del usuario obtenido: $UidUser");
      } else {
        print("No hay usuario autenticado.");
        setState(() {
          isLoading = false; // Detener carga aunque no haya usuario
        });
      }
    } catch (e) {
      print('Error cargando datos del usuario: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias de productos'),
      ),
      body: FutureBuilder(
          future: getCategoriasProducto(UidUser),
          builder: ((context, snapshot){
            if(snapshot.hasData){
              return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index){
                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        // Fondo con imagen
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12), // Bordes redondeados
                            image: DecorationImage(
                              image: NetworkImage(snapshot.data?[index]['ImagenCat'] ??
                                  "https://firebasestorage.googleapis.com/v0/b/inventarioabarrotes-935f9.firebasestorage.app/o/productos%2FLa%20marca%20del%20producto%20Definici%C3%B3n%2C%20clasificaci%C3%B3n%2C%20c%C3%B3mo%20nacen%20y%20m%C3%A1s.jpg?alt=media&token=5f3ff423-6ab7-46d4-9387-e2bdab9a602c"),
                              fit: BoxFit.cover, // Ajusta la imagen al tamaño del contenedor
                            ),
                          ),
                        ),
                        // Contenido de texto
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            width: double.infinity, // Ocupa todo el ancho del contenedor
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.6), // Fondo oscuro con opacidad
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data?[index]['NombreCat'] ?? 'Sin Nombre',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  snapshot.data?[index]['DescripcionCat'] ?? 'Sin Descripción',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Botón PopupMenu en la esquina superior derecha
                        Positioned(
                          top: 10,
                          right: 10,
                          child: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Colors.white),
                            onSelected: (String value) async {
                              if (value == 'editar') {
                                await Navigator.pushNamed(context, '/editCategoriaProducto', arguments: {
                                  "NombreCat": snapshot.data?[index]['NombreCat'],
                                  "DescripcionCat": snapshot.data?[index]['DescripcionCat'],
                                  "uidCat": snapshot.data?[index]['uidCat'],
                                });
                                setState(() {});
                              } else if (value == 'eliminar') {
                                bool confirmDelete = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Confirmar eliminación'),
                                      content: const Text('¿Estás seguro de que deseas eliminar este elemento?'),
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
                                  await deleteCategoriaProducto(snapshot.data?[index]['uidCat']);
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
                  );
                },);
            }
            else{
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          })),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/addCategoriaProducto');
          setState(() {});
        },

        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}