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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias de productos'),
      ),
      body: FutureBuilder(
          future: getCategoriasProducto(),
          builder: ((context, snapshot){
            if(snapshot.hasData){
              return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index){
                  return ListTile(
                      title: Text(snapshot.data?[index]['NombreCat']),
                  trailing: PopupMenuButton<String>(
                  onSelected: (String value) async {
                    if (value == 'editar') { // Página de edición
                        await Navigator.pushNamed(context, '/editCategoriaProducto', arguments: {
                          "NombreCat": snapshot.data?[index]['NombreCat'],
                          "DescripcionCat": snapshot.data?[index]['DescripcionCat'],
                          "uidCat": snapshot.data?[index]['uidCat'],
                        });
                        setState(() {});
                      } else if(value == 'eliminar') {
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
                        await deleteCategoriaProducto(snapshot.data?[index]['uidCat']);
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
                      ];
                    },
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
        child: const Icon(Icons.add),
      ),
    );
  }
}