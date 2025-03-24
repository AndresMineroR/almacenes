import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:almacenes/servicies/firebase_service.dart';

class EditAlmacenPage extends StatefulWidget {
  const EditAlmacenPage({super.key});

  @override
  State<EditAlmacenPage> createState() => _EditAlmacenPageState();
}

class _EditAlmacenPageState extends State<EditAlmacenPage> {
  GlobalKey<FormState> keyForm = GlobalKey();
  TextEditingController nomCtrlAlma = TextEditingController();
  TextEditingController descCtrlAlma = TextEditingController();
  TextEditingController uidAlma = TextEditingController();
  String imagenU = ""; // Almacena la URL de la imagen cargada
  String imageUrl = "";
  bool isUploading = false;
  String UidUser = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Obtener el usuario autenticado
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        setState(() {
          UidUser = user.uid ?? '';
        });
      }
    } catch (e) {
      print('Error cargando datos del usuario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    nomCtrlAlma.text = arguments['NombreAlma'];
    descCtrlAlma.text = arguments['DescripcionAlma'];
    uidAlma.text = arguments['uidAlma'];
    imageUrl = arguments['ImagenAlma'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Almacen'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(children: [
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
                        .child('almacenes/${uidAlma.text}.jpg');
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
            margin: const EdgeInsets.all(20.0),
            child: Form(
              key: keyForm,
              child: formUI(),
            ),
          ),
        ]),
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
              decoration: InputDecoration(
                labelText: 'Nombre del Almacen',
              ),
              keyboardType: TextInputType.text,
            )),
        formItemsDesign(
            Icons.description,
            TextFormField(
              controller: descCtrlAlma,
              decoration: InputDecoration(
                labelText: 'Descripción del Almacen',
              ),
              keyboardType: TextInputType.text,
            )),
        GestureDetector(
          onTap: () async {
            String finalURL = imagenU.isNotEmpty ? imagenU : imageUrl;
            await updateAlmacen(
              uidAlma.text,
              nomCtrlAlma.text,
              descCtrlAlma.text,
              finalURL, // Actualizar la URL de la imagen en Firestore
              UidUser,
            ).then((_) {
              Navigator.pop(context);
            });
          },
          child: Container(
            margin: EdgeInsets.all(30.0),
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
            child: const Text(
              "Actualizar",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            padding: const EdgeInsets.only(top: 16, bottom: 16),
          ),
        ),
      ],
    );
  }
}
