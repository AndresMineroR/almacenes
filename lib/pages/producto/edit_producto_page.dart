import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:almacenes/servicies/firebase_service.dart';
import 'package:image_picker/image_picker.dart';

class EditProductoPage extends StatefulWidget {
  const EditProductoPage({super.key});

  @override
  State<EditProductoPage> createState() => _EditProductoPageState();
}

class _EditProductoPageState extends State<EditProductoPage> {
  GlobalKey<FormState> keyForm = GlobalKey();
  TextEditingController nomCtrl = TextEditingController();
  TextEditingController descCtrl = TextEditingController();
  TextEditingController catCtrl = TextEditingController();
  TextEditingController preCtrl = TextEditingController();
  TextEditingController cadCtrl = TextEditingController();
  TextEditingController ltCtrl = TextEditingController();
  TextEditingController uid = TextEditingController();
  TextEditingController cantidadCtrl = TextEditingController();
  String imagenU = ""; // Almacena la URL de la imagen cargada
  String imageUrl = "";
  bool isUploading = false;
  String uidAlma = '';
  List<dynamic> categorias = [];
  String? selectedCategoria;
  String UidUser = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    Future.microtask((){
      final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
      setState((){
        nomCtrl.text = arguments['Nombre'];
        descCtrl.text = arguments['Descripcion'];
        catCtrl.text = arguments['Categoria'];
        preCtrl.text = arguments['Precio'];
        cadCtrl.text = arguments['Caducidad'];
        ltCtrl.text = arguments['Lote'];
        uid.text = arguments['uid'];
        selectedCategoria = catCtrl.text;
        cantidadCtrl.text = arguments['Stock'];
        imageUrl = arguments['ImagenProducto'];
        uidAlma = arguments['uidAlma'];
      });
    });
  }

  Future<void> _loadUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        setState(() {
          UidUser = user.uid;
        });
        print("UID del usuario obtenido: $UidUser");

        // 🔥 Cargar categorías SOLO después de obtener `UidUser`
        _loadCategorias(UidUser);
      } else {
        print("No hay usuario autenticado.");
      }
    } catch (e) {
      print('Error cargando datos del usuario: $e');
    }
  }



  Future<void> _loadCategorias(String idUser) async {
    if (idUser.isNotEmpty) { // Verificar que `UidUser` no está vacío
      print("Cargando categorías para UID: $idUser");

      var categoriasData = await getCategoriasProducto(idUser);
      setState(() {
        categorias = categoriasData;
      });

      print("Categorías cargadas correctamente: $categoriasData");
    } else {
      print("No se pueden cargar categorías: UidUser está vacío.");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            if (imageUrl.isNotEmpty)
              Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Image.network(
                    imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: () async {
                final pickedImage =
                await ImagePicker().pickImage(source: ImageSource.gallery);
                if (pickedImage != null) {
                  setState(() {
                    isUploading = true;
                  });
                  try {
                    final file = File(pickedImage.path);
                    final storageRef = FirebaseStorage.instance
                        .ref()
                        .child('productos/${uid.text}.jpg');
                    await storageRef.putFile(file);

                    final downloadUrl = await storageRef.getDownloadURL();
                    setState(() {
                      imagenU = downloadUrl;
                      imageUrl = imagenU;
                      isUploading = false;
                    });
                    print('Imagen actualizada correctamente: $downloadUrl');
                  } catch (e) {
                    setState(() {
                      isUploading = false;
                    });
                    print('Error al subir la imagen: $e');
                  }
                }
                Text ('Cambiar Imagen');
              },
              child: isUploading
                  ? const CircularProgressIndicator(
                  color: Colors.black)
                  : const Text('Cambiar Imagen'),
            ),
            Container(
              margin: EdgeInsets.all(20.0),
              child: Form(
                key: keyForm,
                child: formUI(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  formItemsDesign(icon, item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7),
      child: Card(child: ListTile(leading: Icon(icon), title: item)),
    );
  }

  Widget formUI() {
    return Column(
      children: <Widget>[
        formItemsDesign(
            Icons.abc,
            TextFormField(
              controller: nomCtrl,
              decoration: InputDecoration(
                labelText: 'Nombre del producto',
              ),
              keyboardType: TextInputType.text,
              //validator: validateName,
            )),

        formItemsDesign(
            Icons.abc,
            TextFormField(
              controller: descCtrl,
              decoration: InputDecoration(
                labelText: 'Descripción del producto',
              ),
              keyboardType: TextInputType.text,
              //validator:,
            )),

        formItemsDesign(
          Icons.category,
          categorias.isNotEmpty
              ? DropdownButtonFormField<String>(
            value: selectedCategoria ?? catCtrl.text,
            decoration: const InputDecoration(labelText: 'Categoría del producto'),
            items: categorias.map<DropdownMenuItem<String>>((cat) {
              print("Mostrando categoría en dropdown: ${cat['NombreCat']}"); // 🔥 Depuración
              return DropdownMenuItem<String>(
                value: cat['uidCat'],
                child: Text(cat['NombreCat']),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedCategoria = newValue;
                catCtrl.text = selectedCategoria ?? '';
              });
            },
          )
              : const Center(child: CircularProgressIndicator()), // Cargar mientras se obtiene la lista
        ),


        formItemsDesign(
            Icons.attach_money,
            TextFormField(
              controller: preCtrl,
              decoration: InputDecoration(
                labelText: 'Precio del producto',
              ),
              keyboardType: TextInputType.number,
            )),

        formItemsDesign(
            Icons.calendar_today,
            TextFormField(
              controller: cadCtrl,
              decoration: InputDecoration(
                labelText: 'Caducidad del producto',
              ),
              keyboardType: TextInputType.datetime,
              //validator:,
            )),

        formItemsDesign(
            Icons.text_fields,
            TextFormField(
              controller: ltCtrl,
              decoration: InputDecoration(
                labelText: 'Lote del producto',
              ),
              keyboardType: TextInputType.text,
              //validator:,
            )),

        formItemsDesign(
            Icons.numbers,
            TextFormField(
              controller: cantidadCtrl,
              decoration: InputDecoration(
                labelText: 'Stock del producto',
              ),
              keyboardType: TextInputType.number,
            )),

        GestureDetector(
            onTap: () async {
              String finalURL = imagenU.isNotEmpty ? imagenU : imageUrl;
              await updateProducto(
                  uid.text,
                  nomCtrl.text,
                  descCtrl.text,
                  selectedCategoria ?? catCtrl.text,
                  preCtrl.text,
                  cadCtrl.text,
                  ltCtrl.text,
                  cantidadCtrl.text,
                  uidAlma,
                  finalURL,
                  UidUser
              ).then((_){
                Navigator.pop(context);
              });
            }, child: Container(
          margin: EdgeInsets.all(30.0),
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            gradient: LinearGradient(colors: [
              Color(0xFFEAC8CD),
              Color(0xFFECB6B6),
            ],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Text("Actualizar",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500)),
          padding: EdgeInsets.only(top: 16, bottom: 16),
        )
        )
      ],
    );
  }

}
