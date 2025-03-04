import 'package:flutter/material.dart';

//importaciones de FireBase
import 'package:firebase_core/firebase_core.dart';
import 'package:almacenes/config/theme/app_theme.dart';
import 'package:almacenes/pages/add_producto_page.dart';
import 'package:almacenes/pages/edit_producto_page.dart';
import 'package:almacenes/pages/home_page.dart';
import 'package:almacenes/pages/productos_page.dart';
import 'package:almacenes/pages/profile_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme( selectedColor: 6).theme(),
    title: 'MaterialApp',
    initialRoute: '/',
    routes: {
        '/': (context) => Home(),
        '/profil': (context) => Perfil(),
        '/productos': (context) => Productos(),
        '/add': (context) => AddProductoPage(),
        '/edit': (context) => EditProductoPage(),
    },
    );
  }
}
