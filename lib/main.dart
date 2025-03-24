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
import 'package:almacenes/pages/venta/venta_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';



final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await findSystemLocale();
  await initializeDateFormatting();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    // Agrega iOS si lo necesitas
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
      // Aquí manejas el evento al presionar la notificación.
      debugPrint('Notification payload: ${notificationResponse.payload}');
    },
  );


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme(selectedColor: 6).theme(),
      title: 'MaterialApp',
      home: AuthWrapper(), // Usamos AuthWrapper para manejar la sesión
      routes: {
        '/venta': (context) => VentaPage(),
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

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return Login(); // Redirige al Login si no hay sesión activa
          } else {
            return HomeI(); // Redirige al HomeI si hay sesión activa
          }
        }
        return const Center(child: CircularProgressIndicator()); // Muestra un loading mientras verifica el estado
      },
     // onGenerateRoute: (settings) {
        // if (settings.name == '/venta') {
        //final args = settings.arguments as Map<String, dynamic>?;

        //if (args == null || !args.containsKey('uidAlmacen') ||
        //    !args.containsKey('nombreAlmacen')) {
        //  return MaterialPageRoute(builder: (context) =>
      //      Scaffold(
      //          appBar: AppBar(title: Text("Error")),
      //          body: Center(child: Text("Faltan argumentos para /venta")),
    //        ));
        //    }
//
      //        return MaterialPageRoute(
      //    builder: (context) =>
      //        VentaPage(
      //          uidAlmacen: args['uidAlmacen'],
      //          nombreAlmacen: args['nombreAlmacen'],
      //        ),
    //  );
    //  }
    //  return null;
      //},
    );
  }
}
