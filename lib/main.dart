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
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:almacenes/config/theme/app_theme.dart';
import 'package:almacenes/pages/producto/add_producto_page.dart';
import 'package:almacenes/pages/producto/edit_producto_page.dart';
import 'package:almacenes/pages/home_page.dart';
import 'package:almacenes/pages/homeI_page.dart';
import 'package:almacenes/pages/producto/productos_page.dart';
import 'package:almacenes/pages/profile_page.dart';
import 'package:permission_handler/permission_handler.dart';
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

  await requestNotificationPermission(); // Solicita permisos antes de continuar

  await findSystemLocale();
  await initializeDateFormatting();

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
      debugPrint('Notification payload: ${notificationResponse.payload}');
    },
  );

  runApp(const MyApp());
}

Future<void> requestNotificationPermission() async {
  PermissionStatus status = await Permission.notification.status;

  if (status.isDenied || status.isPermanentlyDenied) {
    // Si está denegado, solicitar permisos
    status = await Permission.notification.request();
  }

  if (status.isGranted) {
    print("✅ Permisos de notificación concedidos.");
    await FirebaseMessaging.instance.requestPermission();
  } else {
    print("❌ Permisos de notificación denegados.");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme(selectedColor: 6).theme(),
      title: 'MaterialApp',
      home: AuthWrapper(),
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
            return Login();
          } else {
            return HomeI();
          }
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
