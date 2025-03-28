import 'package:almacenes/pages/homeI_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> _setupTestData() async {
  final firestore = FirebaseFirestore.instance;

  await firestore.collection('ventas').add({
    'uidAlmacen': 'test_almacen',
    'fecha': Timestamp.now(),
    'totalVenta': 50.0, // Agrega una venta para que BarChart tenga datos
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAlzmnokIyiFZSTPehKSY95jgj7bou7Yps',
      appId: '1:378760610898:android:bbad022394458135400b8b',
      messagingSenderId: '378760610898',
      projectId: 'inventarioabarrotes-935f9',
      storageBucket: 'inventarioabarrotes-935f9.firebasestorage.app', // Si aplica
    ),
  );
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: 'gminerolm@gmail.com',
    password: '123456',
  );


  await _setupTestData(); // Agrega datos de prueba

  runApp(const TestMyApp());
}

class TestMyApp extends StatelessWidget {
  const TestMyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeI(),
    );
  }
}
