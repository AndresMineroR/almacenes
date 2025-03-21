import 'package:almacenes/pages/almacen/add_almacen_page.dart';
import 'package:almacenes/pages/almacen/almacenes_page.dart';
import 'package:almacenes/pages/almacen/edit_almacen_page.dart';
import 'package:almacenes/pages/categoria_producto/add_categoria_producto_page.dart';
import 'package:almacenes/pages/categoria_producto/categorias_producto_page.dart';
import 'package:almacenes/pages/categoria_producto/edit_categoria_producto_page.dart';
import 'package:almacenes/pages/login/login.dart';
import 'package:almacenes/pages/producto/mostar_producto_page.dart';
import 'package:almacenes/pages/producto/productos_almacen_page.dart';
import 'package:almacenes/pages/scan_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:almacenes/config/theme/app_theme.dart';
import 'package:almacenes/pages/producto/add_producto_page.dart';
import 'package:almacenes/pages/producto/edit_producto_page.dart';
import 'package:almacenes/pages/home_page.dart';
import 'package:almacenes/pages/homeI_page.dart';
import 'package:almacenes/pages/producto/productos_page.dart';
import 'package:almacenes/pages/profile_page.dart';
import 'firebase_options.dart';
import 'package:intl/intl_standalone.dart' if (dart.library.html) 'package:intl/intl_browser.dart';
import 'package:intl/date_symbol_data_local.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await findSystemLocale();
  await initializeDateFormatting();
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
        '/': (context) => Login(),
        '/scan_code_bar': (context) => ScanCode(),
        '/perfil': (context) => Perfil(),
        '/productos': (context) => Productos(),
        '/addProducto': (context) => AddProductoPage(),
        '/editProducto': (context) => EditProductoPage(),
        '/mostrarProducto': (context) => MostrarProducto(),
        '/almacenes': (context) => Almacenes(),
        '/addAlmacen': (context) => AddAlmacenPage(),
        '/editAlmacen': (context) => EditAlmacenPage(),
        '/productosAlmacen': (context) => ProductosAlmacen(),
        '/categorias': (context) => CategoirasProducto(),
        '/addCategoriaProducto': (context) => AddCategoriaProductoPage(),
        '/editCategoriaProducto': (context) => EditCategoriaProductoPage(),
    },
    );
  }
}
