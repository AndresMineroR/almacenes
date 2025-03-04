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
          builder: ((context, snapshot){
            if(snapshot.hasData){
              return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index){
                  return ListTile(
                      title: Text(snapshot.data?[index]['Nombre']),
                      onTap: (() async {
                        await Navigator.pushNamed(context, '/edit', arguments: {
                          "Nombre": snapshot.data?[index]['Nombre'],
                          "Descripcion": snapshot.data?[index]['Descripcion'],
                          "Categoria": snapshot.data?[index]['Categoria'],
                          "Precio": snapshot.data?[index]['Precio'],
                          "Caducidad": snapshot.data?[index]['Caducidad'],
                          "Lote": snapshot.data?[index]['Lote'],
                          "uid": snapshot.data?[index]['uid'],
                        });
                        setState(() {});
                      }));
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
          await Navigator.pushNamed(context, '/add');
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}