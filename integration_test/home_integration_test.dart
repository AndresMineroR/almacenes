import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:almacenes/main_test.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Prueba de integración pantalla HomeI', (WidgetTester tester) async {
    app.main();

    // Aumenta la espera significativamente
    await tester.pumpAndSettle(const Duration(seconds: 15));

    // Ahora verifica nuevamente
    expect(find.text('Bienvenido'), findsOneWidget);

    // Verifica que el Dropdown de almacenes se cargue
    expect(find.byType(DropdownButton<String>), findsOneWidget);

    // Simula abrir el dropdown de almacenes
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    // Selecciona el primer almacén
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownMenuItem<String>).last);
    await tester.pumpAndSettle();

    // Verifica que las opciones del menú están visibles
    expect(find.text('Venta'), findsOneWidget);
    expect(find.text('Almacenes'), findsOneWidget);
    expect(find.text('Categorías'), findsOneWidget);
    expect(find.text('Productos'), findsOneWidget);

    // Verifica nuevamente que estés en HomeI
    expect(find.text('Bienvenido'), findsOneWidget);

    // Simula presionar el botón de notificaciones
    await tester.tap(find.byIcon(Icons.notifications));
    await tester.pumpAndSettle();
  });
}
