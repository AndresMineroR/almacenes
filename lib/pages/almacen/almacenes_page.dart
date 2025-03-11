import 'package:flutter/material.dart';
import 'package:almacenes/servicies/firebase_service.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class Almacenes extends StatefulWidget {
  const Almacenes({
    super.key,
  });

  @override
  State<Almacenes> createState() => _AlmacenesState();
}

class _AlmacenesState extends State<Almacenes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Almacenes'),
      ),
      body: FutureBuilder(
        future: getAlmacenes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data?[index]['NombreAlma']),
                  trailing: PopupMenuButton<String>(
                    onSelected: (String value) async {
                      if (value == 'editar') { // Página de edición
                        await Navigator.pushNamed(context, '/editAlmacen', arguments: {
                          "NombreAlma": snapshot.data?[index]['NombreAlma'],
                          "DescripcionAlma": snapshot.data?[index]['DescripcionAlma'],
                          "uidAlma": snapshot.data?[index]['uidAlma'],
                        });
                        setState(() {});
                      } else if (value == 'eliminar') {
                        bool confirmDelete = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Confirmar eliminación'),
                              content: Text('¿Estás seguro de que deseas eliminar este elemento?'),
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
                          await deleteAlmacen(snapshot.data?[index]['uidAlma']);
                          setState(() {});
                        }
                      } else if (value == 'agregar') {
                        var result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SimpleBarcodeScannerPage(),
                          ),
                        );

                        if (result != null && result != "-1") {
                          // Si el usuario escaneó un código válido, ir a la pantalla de agregar producto
                          await Navigator.pushNamed(
                            context,
                            '/addProducto',
                            arguments: {
                              "uidAlma": result.toString(), // Pasar el código escaneado

                            },
                          );
                          setState(() {});
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
                        PopupMenuItem<String>(
                          value: 'agregar',
                          child: Text('Agregar Productos'),
                        ),
                      ];
                    },
                  ),
                  /*onTap: () async {
                    await Navigator.pushNamed(context, '/editAlmacen', arguments: {
                      "NombreAlma": snapshot.data?[index]['NombreAlma'],
                      "DescripcionAlma": snapshot.data?[index]['DescripcionAlma'],
                      "uidAlma": snapshot.data?[index]['uidAlma'],
                    });
                    setState(() {});
                  },*/
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
          await Navigator.pushNamed(context, '/addAlmacen');
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}