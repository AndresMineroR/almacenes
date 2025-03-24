import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:almacenes/servicies/firebase_service.dart';
import 'package:image_picker/image_picker.dart'; // Para seleccionar la imagen
import 'package:firebase_storage/firebase_storage.dart'; // Para guardar la imagen
import 'dart:io';

class AddAlmacenPage extends StatefulWidget {
  const AddAlmacenPage({super.key});

  @override
  State<AddAlmacenPage> createState() => _AddAlmacenPageState();
}

class _AddAlmacenPageState extends State<AddAlmacenPage> {
  GlobalKey<FormState> keyForm = GlobalKey();
  TextEditingController nomCtrlAlma = TextEditingController(text: '');
  TextEditingController descCtrlAlma = TextEditingController(text: '');
  String imageUrl = '';
  String uidUser = '';
  String email ='';
  String uid = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Almacen'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          margin: EdgeInsets.all(20.0),
          child: Form(
            key: keyForm,
            child: formUI(), //Este método lo crearemos más adelante
          ),
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
              controller: nomCtrlAlma,
              decoration: const InputDecoration(
                labelText: 'Nombre del Almacen',
              ),
              keyboardType: TextInputType.text,
            )),

        formItemsDesign(
            Icons.description,
            TextFormField(
              controller: descCtrlAlma,
              decoration: const InputDecoration(
                labelText: 'Descripción del Almacen',
              ),
              keyboardType: TextInputType.text,
            )),

        // Botón para seleccionar imagen
        formItemsDesign(
          Icons.image,
          Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    try {
                      final file = File(pickedImage.path);

                      // Subir la imagen a Firebase Storage
                      final storageRef = FirebaseStorage.instance
                          .ref()
                          .child('almacenes/${nomCtrlAlma.text}.jpg');

                      await storageRef.putFile(file);

                      // Obtener URL de la imagen
                      final downloadUrl = await storageRef.getDownloadURL();
                      setState(() {
                        imageUrl = downloadUrl; // Guardar la URL de la imagen
                      });

                      print('Imagen subida correctamente: $downloadUrl');
                    } catch (e) {
                      print('Error al subir la imagen: $e');
                    }
                  } else {
                    print('No se seleccionó ninguna imagen.');
                  }
                },
                child: const Text('Seleccionar Imagen'),
              ),
              if (imageUrl.isNotEmpty)
                Image.network(imageUrl, height: 100, width: 100, fit: BoxFit.cover),
            ],
          ),
        ),

        // Botón Guardar
        GestureDetector(
            onTap: () async {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                email = user.email ?? '';
                QuerySnapshot<Map<String,
                    dynamic>> querySnapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .where('Correo', isEqualTo: email)
                    .get();
                String usId = querySnapshot.docs.first.id;
                await addAlmacen(
                  nomCtrlAlma.text,
                  descCtrlAlma.text,
                  imageUrl,
                  uidUser = usId,
                ).then((_) {
                  Navigator.pop(context);
                });
              }
            },
            child: Container(
              margin: const EdgeInsets.all(30.0),
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFEAC8CD),
                    Color(0xFFECB6B6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Text("Guardar",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500)),
              padding: const EdgeInsets.only(top: 16, bottom: 16),
            ))
      ],
    );
  }
}