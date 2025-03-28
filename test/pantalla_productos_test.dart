import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:almacenes/pages/producto/productos_almacen_page.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = null;
  });
  testWidgets('Verifica carga correcta de ProductosAlmacen',
          (WidgetTester tester) async {
        final user = MockUser(uid: 'test_uid');
        final auth = MockFirebaseAuth(mockUser: user);
        final firestore = FakeFirebaseFirestore();

        await firestore.collection('categorias').add({
          'IdPropietario': 'test_uid',
          'NombreCat': 'Electrónica',
        });

        Future<List<Map<String, dynamic>>> mockGetProductos(String uidAlma,
            String uidUser) async {
          return [
            {
              'Nombre': 'Laptop',
              'Descripcion': 'Laptop potente',
              'Categoria': 'todas',
              'Stock': '5',
              'UidAlma': uidAlma,
              'CodigoBarras': '1234567890',
              'ImagenProducto': 'https://example.com/image.jpg'
            }
          ];
        }

        await tester.pumpWidget(MaterialApp(
          initialRoute: '/',
          onGenerateRoute: (RouteSettings settings) {
            if (settings.name == '/') {
              return MaterialPageRoute(
                builder: (context) =>
                    ProductosAlmacen(
                       /* auth: auth,
                        firestore: firestore,
                        getProductos: mockGetProductos *descomentar esto para la prueba*/),
                settings: RouteSettings(arguments: {
                  'uidAlma': 'almacen123',
                  'NombreAlma': 'Almacen Principal',
                }),
              );
            }
            return null;
          },
        ));

        await tester.pumpAndSettle();

        expect(find.text('Productos Almacen Principal'), findsOneWidget);
        expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
        expect(find.text('Laptop'), findsOneWidget);
        expect(find.textContaining('Laptop potente'), findsOneWidget);
        expect(find.textContaining('Stock: 5'), findsOneWidget);
      });
}
