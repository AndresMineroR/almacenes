import 'package:flutter/material.dart';
import 'package:almacenes/servicies/firebase_service.dart';

class ProductosAlmacen extends StatefulWidget {
  const ProductosAlmacen({
    super.key,
  });

  @override
  State<ProductosAlmacen> createState() => _ProductosAlmacenState();
}

class _ProductosAlmacenState extends State<ProductosAlmacen> {
  late String uidAlma;
  void initState() {
    super.initState();
    // Obtén el uidAlma de los argumentos de la ruta
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
      setState(() {
        uidAlma = arguments['uidAlma'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
      ),
      body: FutureBuilder(
          future: getProductosAlmacen(uidAlma),
          builder: ((context, snapshot){
            if(snapshot.hasData){
              return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index){
                  return ListTile(
                      title: Text(snapshot.data?[index]['Nombre']),
                      trailing: PopupMenuButton<String>(
                        onSelected: (String value) async{
                          if (value == 'editar') { // Página de edición
                            await Navigator.pushNamed(context, '/editProducto', arguments: {
                              "Nombre": snapshot.data?[index]['Nombre'],
                              "Descripcion": snapshot.data?[index]['Descripcion'],
                              "Categoria": snapshot.data?[index]['Categoria'],
                              "Precio": snapshot.data?[index]['Precio'],
                              "Caducidad": snapshot.data?[index]['Caducidad'],
                              "Stock": snapshot.data?[index]['Stock'],
                              "Lote": snapshot.data?[index]['Lote'],
                              "uid": snapshot.data?[index]['uid'],
                              "UidAlma" : snapshot.data?[index]['UidAlma'],
                            });
                            setState(() {});
                          } else if(value == 'eliminar'){
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
                              await deleteProducto(snapshot.data?[index]['uid']);
                              setState(() {});
                            }
                          }else if (value == 'mostrar'){
                            await Navigator.pushNamed(context, '/mostrarProducto', arguments: {
                              "Nombre": snapshot.data?[index]['Nombre'],
                              "Descripcion": snapshot.data?[index]['Descripcion'],
                              "Categoria": snapshot.data?[index]['Categoria'],
                              "Precio": snapshot.data?[index]['Precio'],
                              "Caducidad": snapshot.data?[index]['Caducidad'],
                              "Lote": snapshot.data?[index]['Lote'],
                              "Stock": snapshot.data?[index]['Stock']
                            });
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
                              value: 'mostrar',
                              child: Text('Mostrar'),
                            ),
                          ];
                        },
                      ),
                      /*onTap: (() async {
                        await Navigator.pushNamed(context, '/editProducto', arguments: {
                          "Nombre": snapshot.data?[index]['Nombre'],
                          "Descripcion": snapshot.data?[index]['Descripcion'],
                          "Categoria": snapshot.data?[index]['Categoria'],
                          "Precio": snapshot.data?[index]['Precio'],
                          "Caducidad": snapshot.data?[index]['Caducidad'],
                          "Lote": snapshot.data?[index]['Lote'],
                          "uid": snapshot.data?[index]['uid'],
                        });
                        setState(() {});
                      })*/
                  );
                },);
            }
            else{
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          })),
    );
  }
}