import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

FirebaseFirestore baseInventario = FirebaseFirestore.instance;
FirebaseFirestore baseInventarioP = FirebaseFirestore.instance;

//producto mas vendido
// Producto más vendido


Future<void> updateStock(Map<String, dynamic> args, String text, String uidAlma) async {
  // Extraemos los argumentos enviados desde la ruta
  final String uId = args['uidProducto'];
  final String uidAlma = args['uidAlma'];

  // Opcional: se obtiene el documento para verificar que coincida el almacén
  final docRef = baseInventario.collection('productos').doc(uId);
  final docSnapshot = await docRef.get();

  if (docSnapshot.exists) {
    final data = docSnapshot.data() as Map<String, dynamic>;
    // Verifica que el almacén del documento coincida con el enviado
    if (data['UidAlma'] == uidAlma) {
      await docRef.update({
        'Nombre': args['nomNew'],
        'Descripcion': args['desNew'],
        'Categoria': args['catNew'],
        'Precio': args['preNew'],
        'Caducidad': args['cadNew'],
        'Lote': args['ltNew'],
        'Stock': args['stock'],
        'ImagenProducto': args['url'],
      });
    } else {
      // Puedes manejar el caso en que no coincida el almacén, por ejemplo:
      print('El almacén no coincide. No se actualiza el stock.');
    }
  } else {
    print('El producto no existe.');
  }
}




// Producto más vendido
Future<List<Map<String, dynamic>>> getProductosMasVendidos(String uidAlmacen) async {
  Map<String, int> ventasPorProducto = {};

  final ventasSnapshot = await FirebaseFirestore.instance
      .collection('ventas')
      .where('uidAlmacen', isEqualTo: uidAlmacen)
      .get();

  for (var ventaDoc in ventasSnapshot.docs) {
    List productos = ventaDoc.data()['productosDetalle'] ?? [];
    for (var producto in productos) {
      String codigo = producto['codigoBarras'];
      int cantidad = producto['cantidad'];
      ventasPorProducto[codigo] = (ventasPorProducto[codigo] ?? 0) + cantidad;
    }
  }

  // Ordenar de mayor a menor cantidad vendida
  var sortedEntries = ventasPorProducto.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  List<Map<String, dynamic>> resultado = [];
  for (var entry in sortedEntries) {
    // Obtener nombre desde el último documento de venta disponible
    String nombreProducto = '';
    for (var ventaDoc in ventasSnapshot.docs) {
      List productos = ventaDoc.data()['productosDetalle'];
      var encontrado = productos.firstWhere((p) => p['codigoBarras'] == entry.key, orElse: () => null);
      if (encontrado != null) {
        nombreProducto = encontrado['nombre'];
        break;
      }
    }
    resultado.add({
      'codigo': entry.key,
      'nombre': nombreProducto,
      'cantidadVendida': entry.value,
    });
  }

  return resultado;
}


//Producto con menos stock

Future<List<Map<String, dynamic>>> getProductosMenorStock(String uidAlmacen, {int limite = 10}) async {
  // Traer todos los productos del almacén
  final snapshot = await FirebaseFirestore.instance
      .collection('productos')
      .where('UidAlma', isEqualTo: uidAlmacen)
      .get();

  List<Map<String, dynamic>> productos = [];

  for (var doc in snapshot.docs) {
    final data = doc.data();
    // Convertir el valor de 'Stock' a entero, asumiendo que viene como string.
    final stock = int.tryParse(data['Stock'].toString()) ?? 0;
    // Si el stock es menor a 10, se considera de poco stock.
    if (stock < limite) {
      productos.add({
        'nombre': data['Nombre'],
        'stock': stock,
      });
    }
  }

  // Ordenar los productos de menor a mayor stock
  productos.sort((a, b) => a['stock'].compareTo(b['stock']));

  return productos;
}




//función para traer los productos
Future<List> getProductos(String uidUser) async{
  List productos = [];
  try{
    QuerySnapshot queryProduct = await baseInventarioP.collection('productos')
        .where('UidUser', isEqualTo: uidUser).get();
    for (var doc in queryProduct.docs) {
      final Map< String, dynamic> data = doc.data() as Map< String, dynamic>;
      final pro = {
        "Nombre": data['Nombre'],
        "Descripcion": data['Descripcion'],
        "Categoria": data['Categoria'],
        "Precio": data['Precio'],
        "Caducidad": data['Caducidad'],
        "Lote": data['Lote'],
        "Stock": data['Stock'],
        "UidAlma": data['UidAlma'],
        "ImagenProducto": data['ImagenProducto'],
        "CodigoBarras": data['CodigoBarras'],
        "uid": doc.id,
      };
      productos.add(pro);
    }
  }catch(e){
    print('Error obteniendo productos: $e');
  }
  return productos;
}

//función para traer los productos de un almacen
Future<List> getProductosAlmacen(String uidAlma, String uidUser) async{
  print(uidAlma+'+++++++++++++++'+uidUser);
  List productos = [];
  try{
    QuerySnapshot queryProduct = await baseInventario.collection('productos')
        .where('UidAlma', isEqualTo: uidAlma )
        .where('UidUser', isEqualTo: uidUser)
        .get();
    for (var doc in queryProduct.docs) {
      final Map< String, dynamic> data = doc.data() as Map< String, dynamic>;
      final pro = {
        "Nombre": data['Nombre'],
        "Descripcion": data['Descripcion'],
        "Categoria": data['Categoria'],
        "Precio": data['Precio'],
        "Caducidad": data['Caducidad'],
        "Lote": data['Lote'],
        "UidAlma": data['UidAlma'],
        "Stock": data['Stock'],
        "ImagenProducto": data['ImagenProducto'],
        "CodigoBarras": data['CodigoBarras'],
        "uid": doc.id,
      };
      productos.add(pro);
    }
  }catch(e){
    print('Error obteniendo productos: $e');
  }
  return productos;
}

//función para guardar un producto
Future<void> addProducto(
    String codigoBarras, // Ahora el código de barras es solo un atributo
    String nom,
    String des,
    String cat,
    String pre,
    String cad,
    String lt,
    String uidAlma,
    String stock,
    String url,
    String uidUser
    ) async {
  try {
    DocumentReference docRef = await baseInventario.collection('productos').add({
      'CodigoBarras': codigoBarras, // Se guarda como propiedad del producto
      'Nombre': nom,
      'Descripcion': des,
      'Categoria': cat,
      'Precio': pre,
      'Caducidad': cad,
      'Lote': lt,
      'UidAlma': uidAlma,
      'Stock': stock,
      'ImagenProducto': url,
      'UidUser': uidUser
    });

    print("Producto agregado con éxito: ${docRef.id}"); // ID generado automáticamente
  } catch (e) {
    print("Error al agregar producto: $e");
  }
}



//función para actualizar un producto
Future<void> updateProducto(String uId, String nomNew, String desNew, String catNew, String preNew, String cadNew, String ltNew, String stock, String uidalma, String url, String uidUser) async {
  await baseInventario.collection('productos').doc(uId).update({
    'Nombre': nomNew,
    'Descripcion': desNew,
    'Categoria': catNew,
    'Precio': preNew,
    'Caducidad': cadNew,
    'Lote': ltNew,
    'Stock': stock,
    'UidAlma': uidalma,
    'ImagenProducto': url,
    'UidUser': uidUser
  });
}
//función para borrar un producto
Future<void> deleteProducto(String uid) async{
  await baseInventario.collection('productos').doc(uid).delete();
}

//función para traer los almacenes
Future<List> getAlmacenes(String uidUser) async{
  print(' ++++++++++++++++++++++++++++'+uidUser);
  List Almacenes = [];
  try{
    QuerySnapshot queryAlmacenes = await baseInventario.collection('almacenes')
        .where('IdPropietario', isEqualTo: uidUser).get();
    for (var doc in queryAlmacenes.docs) {
      final Map< String, dynamic> data = doc.data() as Map< String, dynamic>;
      final alma = {
        "NombreAlma": data['NombreAlma'],
        "DescripcionAlma": data['DescripcionAlma'],
        "IdPropietario": data['IdPropietario'],
        "uidAlma": doc.id,
        "ImagenAlma": data['ImagenAlma'],
      };
      Almacenes.add(alma);
    }
  }catch(e){
    print('Error obteniendo almacenes: $e');
  }
  return Almacenes;
}
//función para guardar un almacen
Future<void> addAlmacen(String nomAlm, String desAlm, String imagenUrl, String usId) async{
  await baseInventario.collection('almacenes').add({
    'NombreAlma': nomAlm,
    'DescripcionAlma': desAlm,
    'ImagenAlma': imagenUrl,
    'IdPropietario': usId,
  });
}
//función para actualizar un almacen
Future<void> updateAlmacen(String uidAlm, String nomNewAlm, String desNewAlm, String url, String uidUser) async {
  await baseInventario.collection('almacenes').doc(uidAlm).set({
    'uidAlma': uidAlm,
    'NombreAlma': nomNewAlm,
    'DescripcionAlma': desNewAlm,
    'ImagenAlma': url,
    'IdPropietario': uidUser
  });
}
//función para borrar un almacen
Future<void> deleteAlmacen(String uidAlm) async{
  await baseInventario.collection('almacenes').doc(uidAlm).delete();
}

//función para traer las actegorías de producto
Future<List> getCategoriasProducto(String uidUser) async{
  List categorias = [];
  try{
    QuerySnapshot queryCategorias = await baseInventario.collection('categorias')
        .where('IdPropietario', isEqualTo: uidUser).get();
    for (var doc in queryCategorias.docs) {
      final Map< String, dynamic> data = doc.data() as Map< String, dynamic>;
      final catPro = {
        "NombreCat": data['NombreCat'],
        "DescripcionCat": data['DescripcionCat'],
        "uidCat": doc.id,
      };
      categorias.add(catPro);
    }
  }catch(e){
    print('Error obteniendo las categorias de producto: $e');
  }
  return categorias;
}
//función para guardar una categoría de producto
Future<void> addCategoriaProducto(String nomCat, String desCat, String uidUser) async{
  await baseInventario.collection('categorias').add({
    'NombreCat': nomCat,
    'DescripcionCat': desCat,
    'IdPropietario': uidUser
  });
}
//función para actualizar una categoría de producto
Future<void> updateCategoriaProducto(String uidCat, String nomNewCat, String desNewCat, String uidUser) async {
  await baseInventario.collection('categorias').doc(uidCat).set({
    'NombreCat': nomNewCat,
    'DescripcionCat': desNewCat,
    'IdPropietario': uidUser
  });
}
//función para borrar una categoría de producto
Future<void> deleteCategoriaProducto(String uidAlm) async{
  await baseInventario.collection('categorias').doc(uidAlm).delete();
}

Future<List> getNombreCategorias() async {
  List cats = [];
  try {
    QuerySnapshot queryCategorias = await baseInventario.collection(
        'categorias').get();
    for (var doc in queryCategorias.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      final catPro = {
        'uidCat': doc.id,
        "NombreCat": data['NombreCat']
      };
      cats.add(catPro);
    }
  } catch (e) {
    print('Error obteniendo las categorias de producto: $e');
  }
  return cats;
}

String? nombreCategoria;

Future<String?> obtenerNombreCategoria(String categoriaId) async {
  final doc = await FirebaseFirestore.instance.collection('categorias').doc(categoriaId).get();
  if (doc.exists) {
      nombreCategoria = doc['nombre']; // Asume que 'nombre' es el campo con el nombre de la categoría
    ;
  } else {
      nombreCategoria = 'Categoría no encontrada';;
  }
  return nombreCategoria;
}

