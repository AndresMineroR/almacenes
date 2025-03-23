import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

FirebaseFirestore baseInventario = FirebaseFirestore.instance;
FirebaseFirestore baseInventarioP = FirebaseFirestore.instance;

//función para traer los productos
Future<List> getProductos() async{
  List productos = [];
  try{
    QuerySnapshot queryProduct = await baseInventarioP.collection('productos').get();
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
Future<List> getProductosAlmacen(String uidAlma) async{
  List productos = [];
  debugPrint('Categoría seleccionada: $uidAlma');
  try{
    QuerySnapshot queryProduct = await baseInventario.collection('productos').where('UidAlma', isEqualTo: uidAlma ).get();
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
Future<void> addProducto(String uidProducto, String nom, String des, String cat, String pre, String cad, String lt, String uidAlma, String stock) async{
  try {
  await baseInventario.collection('productos').doc(uidProducto).set({
    'Nombre': nom,
    'Descripcion': des,
    'Categoria' : cat,
    'Precio' : pre,
    'Caducidad': cad,
    'Lote': lt,
    'UidAlma': uidAlma,
    'Stock': stock
  });
  print("Producto agregado con éxito: $uidProducto");
  } catch (e) {
    print("Error al agregar producto: $e");
  }

}


//función para actualizar un producto
Future<void> updateProducto(String uId, String nomNew, String desNew, String catNew, String preNew, String cadNew, String ltNew, String stock, String uidalma) async {
  await baseInventario.collection('productos').doc(uId).set({
    'Nombre': nomNew,
    'Descripcion': desNew,
    'Categoria': catNew,
    'Precio': preNew,
    'Caducidad': cadNew,
    'Lote': ltNew,
    'Stock': stock,
    'UidAlma': uidalma
  });
}
//función para borrar un producto
Future<void> deleteProducto(String uid) async{
  await baseInventario.collection('productos').doc(uid).delete();
}

//función para traer los almacenes
Future<List> getAlmacenes() async{
  List Almacenes = [];
  try{
    QuerySnapshot queryAlmacenes = await baseInventario.collection('almacenes').get();
    for (var doc in queryAlmacenes.docs) {
      final Map< String, dynamic> data = doc.data() as Map< String, dynamic>;
      final alma = {
        "NombreAlma": data['NombreAlma'],
        "DescripcionAlma": data['DescripcionAlma'],
        "IdPropietario": data['IdPropietario'],
        "uidAlma": doc.id,
      };
      Almacenes.add(alma);
    }
  }catch(e){
    print('Error obteniendo almacenes: $e');
  }
  return Almacenes;
}
//función para guardar un almacen
Future<void> addAlmacen(String nomAlm, String desAlm, String uidAlm) async{
  await baseInventario.collection('almacenes').add({
    'NombreAlma': nomAlm,
    'DescripcionAlma': desAlm,
    'IdPropietario': uidAlm
  });
}
//función para actualizar un almacen
Future<void> updateAlmacen(String uidAlm, String nomNewAlm, String desNewAlm) async {
  await baseInventario.collection('almacenes').doc(uidAlm).set({
    'NombreAlma': nomNewAlm,
    'DescripcionAlma': desNewAlm,
    'uidAlma': uidAlm
  });
}
//función para borrar un almacen
Future<void> deleteAlmacen(String uidAlm) async{
  await baseInventario.collection('almacenes').doc(uidAlm).delete();
}

//función para traer las actegorías de producto
Future<List> getCategoriasProducto() async{
  List categorias = [];
  try{
    QuerySnapshot queryCategorias = await baseInventario.collection('categorias').get();
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
Future<void> addCategoriaProducto(String nomCat, String desCat) async{
  await baseInventario.collection('categorias').add({
    'NombreCat': nomCat,
    'DescripcionCat': desCat,
  });
}
//función para actualizar una categoría de producto
Future<void> updateCategoriaProducto(String uidCat, String nomNewCat, String desNewCat) async {
  await baseInventario.collection('categorias').doc(uidCat).set({
    'NombreCat': nomNewCat,
    'DescripcionCat': desNewCat,
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

