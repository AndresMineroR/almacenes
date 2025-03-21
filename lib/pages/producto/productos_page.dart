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
                                    'Nombre: '+snapshot.data?[index]['Nombre']+'\n'+
                                    'Descripción: '+snapshot.data?[index]['Descripcion']+'\n'+
                                    'Stock: '+snapshot.data?[index]['Stock'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: (() async {
                      await Navigator.pushNamed(context, '/mostrarProducto', arguments: {
                        "Nombre": snapshot.data?[index]['Nombre'],
                        "Descripcion": snapshot.data?[index]['Descripcion'],
                        "Categoria": snapshot.data?[index]['Categoria'],
                        "Precio": snapshot.data?[index]['Precio'],
                        "Caducidad": snapshot.data?[index]['Caducidad'],
                        "Lote": snapshot.data?[index]['Lote'],
                        "Stock": snapshot.data?[index]['Stock']
                      });
                      setState(() {});
                    }),
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