import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore baseInventario = FirebaseFirestore.instance;

//función para traer los productos
Future<List> getProductos() async{
  List productos = [];
  try{
    QuerySnapshot queryProduct = await baseInventario.collection('productos').get();
    for (var doc in queryProduct.docs) {
      final Map< String, dynamic> data = doc.data() as Map< String, dynamic>;
      final pro = {
        "Nombre": data['Nombre'],
        "Descripcion": data['Descripcion'],
        "Categoria": data['Categoria'],
        "Precio": data['Precio'],
        "Caducidad": data['Caducidad'],
        "Lote": data['Lote'],
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
Future<void> addProducto(String uidProducto, String nom, String des,String cad, String lt) async{
  try {
  await baseInventario.collection('productos').doc(uidProducto).set({
    'Nombre': nom,
    'Descripcion': des,

    'Caducidad': cad,
    'Lote': lt
  });
  print("Producto agregado con éxito: $uidProducto");
  } catch (e) {
    print("Error al agregar producto: $e");
  }

}


//función para actualizar un producto
Future<void> updateProducto(String uId, String nomNew, String desNew, int catNew, int preNew, String cadNew, String ltNew) async {
  await baseInventario.collection('productos').doc(uId).set({
    'Nombre': nomNew,
    'Descripcion': desNew,
    'Categoria': catNew,
    'Precio': preNew,
    'Caducidad': cadNew,
    'Lote': ltNew
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
        "NombreCat": data['NombreCat']
      };
      cats.add(catPro);
    }
  } catch (e) {
    print('Error obteniendo las categorias de producto: $e');
  }
  return cats;
}