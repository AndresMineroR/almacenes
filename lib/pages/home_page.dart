import 'package:flutter/material.dart';
import 'package:almacenes/servicies/firebase_service.dart';

class Home extends StatefulWidget {
  const Home({super.key,});

  @override
  State<Home> createState() => _HomeState();
}
class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio',
        style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder(
        future: getProductos(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Text(
                    'Mayor Stock',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(snapshot.data?[index]['Nombre']),
                        onTap: (() async {
                          await Navigator.pushNamed(
                            context,
                            '/edit',
                            arguments: {
                              "Nombre": snapshot.data?[index]['Nombre'],
                              "Descripcion": snapshot.data?[index]['Descripcion'],
                              "Categoria": snapshot.data?[index]['Categoria'],
                              "Precio": snapshot.data?[index]['Precio'],
                              "Caducidad": snapshot.data?[index]['Caducidad'],
                              "Lote": snapshot.data?[index]['Lote'],
                              "uid": snapshot.data?[index]['uid'],
                            },
                          );
                          setState(() {});
                        }),
                      );
                    },
                  ),
                  Text(
                    'Menor Stock',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(snapshot.data?[index]['Nombre']),
                        onTap: (() async {
                          await Navigator.pushNamed(
                            context,
                            '/edit',
                            arguments: {
                              "Nombre": snapshot.data?[index]['Nombre'],
                              "Descripcion": snapshot.data?[index]['Descripcion'],
                              "Categoria": snapshot.data?[index]['Categoria'],
                              "Precio": snapshot.data?[index]['Precio'],
                              "Caducidad": snapshot.data?[index]['Caducidad'],
                              "Lote": snapshot.data?[index]['Lote'],
                              "uid": snapshot.data?[index]['uid'],
                            },
                          );
                          setState(() {});
                        }),
                      );
                    },
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFEAC8CD),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('https://scontent.fmex36-1.fna.fbcdn.net/v/t39.30808-6/481279571_8936295913146902_5690452786226202700_n.jpg?_nc_cat=106&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeE59ClkHnLcj5bTGLLfHVEZkGC5bHlK0XqQYLlseUrReh9GRgf0a0wZCbqJ6RPlvx-7rMHe5S53B9qnYA6mGBxw&_nc_ohc=R-xRpkpQvD8Q7kNvgEQs6IA&_nc_oc=Adha-fsoTg4CV3sLXwpJBe2wExUciWJcxSN17sXc3QJV1-17Lm-gLgF4qNvW1xIOdsnvOVj7XNCVl6en3Y_JsjSI&_nc_zt=23&_nc_ht=scontent.fmex36-1.fna&_nc_gid=Ar2-A3wYiNzCkPdB_HzxwPC&oh=00_AYBqTt9E5aLausW9Yfx4TN8fH3_NTuAz6DEZUuLDtVIsGg&oe=67CC8DBD'),
              ),
              Text(
                'Invent0taly', // Corregí la ortografía de 'Invet0taly' a 'Invent0taly'
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                ),
              ),
              ]
              )
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Perfil'),
              onTap: () {
                Navigator.pushNamed(context, '/profil');
              },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Productos'),
              onTap: () {
                Navigator.pushNamed(context, '/productos');
              },
            ),
          ],
        ),
      ),
    );
  }
}