import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore baseInventario = FirebaseFirestore.instance;

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

//fubcion para guardar
Future<void> addProducto(String nom, String des, int cat, int pre, String cad, String lt) async{
  await baseInventario.collection('productos').add({
    'Nombre': nom,
    'Descripcion': des,
    'Categoria': cat,
    'Precio': pre,
    'Caducidad': cad,
    'Lote': lt
  });
}
//baseInventario.collection('porductos').doc(uId).set({'Nombre': newName})
//funcion para actualizar
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