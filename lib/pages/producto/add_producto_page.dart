import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:almacenes/servicies/firebase_service.dart';
import 'package:date_field/date_field.dart'; // Asegúrate de que esté importado
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddProductoPage extends StatefulWidget {
  const AddProductoPage({super.key});

  @override
  State<AddProductoPage> createState() => _AddProductoPageState();
}

class _AddProductoPageState extends State<AddProductoPage> {
  GlobalKey<FormState> keyForm = GlobalKey();
  TextEditingController nomCtrl = TextEditingController(text: '');
  TextEditingController descCtrl = TextEditingController(text: '');
  TextEditingController catCtrl = TextEditingController(text: '');
  TextEditingController preCtrl = TextEditingController(text: '');
  TextEditingController cadCtrl = TextEditingController(text: '');
  TextEditingController ltCtrl = TextEditingController(text: '');
  TextEditingController cantCtrl = TextEditingController(text: '');
  // Este controlador contendrá el código escaneado (Código de Barras) que ahora se guarda en uidProducto
  TextEditingController uidProducto = TextEditingController(text: '');
  // uidAlma se mantiene si es requerido para otro propósito (por ejemplo, identificar el almacén)
  TextEditingController uidAlma = TextEditingController(text: '');

  List<dynamic> categorias = [];
  String? selectedCategoria;
  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    _loadCategorias();
  }

  _loadCategorias() async {
    var categoriasData = await getCategoriasProducto();
    setState(() {
      categorias = categoriasData;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments =
    ModalRoute.of(context)!.settings.arguments as Map<dynamic, dynamic>;
    // Asumimos que el código escaneado viene en el argumento 'uidProducto'
    uidProducto.text = arguments['uidProducto'];
    // uidAlma podría provenir de otro argumento o quedar vacío si no es necesario
    uidAlma.text = arguments['uidAlma'] ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Producto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          margin: const EdgeInsets.all(20.0),
          child: Form(
            key: keyForm,
            child: formUI(),
          ),
        ),
      ),
    );
  }

  formItemsDesign(icon, item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Card(
        child: ListTile(
          leading: Icon(icon),
          title: item,
        ),
      ),
    );
  }

  Widget formUI() {
    return Column(
      children: <Widget>[
        // Campo para mostrar el código escaneado (Código de Barras) usando uidProducto y solo lectura
        formItemsDesign(
            Icons.qr_code,
            TextFormField(
              controller: uidProducto,
              decoration: const InputDecoration(
                labelText: 'Código Escaneado',
              ),
              keyboardType: TextInputType.text,
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El código escaneado no puede estar vacío';
                }
                return null;
              },
            )),
        formItemsDesign(
            Icons.abc,
            TextFormField(
              controller: nomCtrl,
              decoration: InputDecoration(
                labelText: 'Nombre del producto',
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese la fecha de caducidad';
                }
                return null;
              },
            )),
        formItemsDesign(
            Icons.abc,
            TextFormField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: 'Descripción del producto',
              ),
              keyboardType: TextInputType.text,
            )),
        formItemsDesign(
          Icons.category,
          categorias.isNotEmpty
              ? DropdownButtonFormField<String>(
            value: selectedCategoria,
            decoration:
            const InputDecoration(labelText: 'Categoría del producto'),
            items: categorias.map<DropdownMenuItem<String>>((cat) {
              return DropdownMenuItem<String>(
                value: cat['uidCat'], // Aquí usamos el uid como valor
                child: Text(cat['NombreCat']),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedCategoria = newValue;
                catCtrl.text = selectedCategoria ?? ''; // Actualizamos el controlador
              });
            },
          )
              : const CircularProgressIndicator(), // Mostrar un cargador mientras no haya categorías
        ),
        formItemsDesign(
            Icons.attach_money,
            TextFormField(
              controller: preCtrl,
              decoration: const InputDecoration(
                labelText: 'Precio del producto',
              ),
              keyboardType: TextInputType.number,
            )),
        formItemsDesign(
          Icons.calendar_today,
          DateTimeFormField(
            decoration: const InputDecoration(
              labelText: 'Fecha de caducidad',
            ),
            firstDate: DateTime.now().add(const Duration(days: 10)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            initialPickerDateTime: DateTime.now().add(const Duration(days: 20)),
            onChanged: (DateTime? value) {
              if (value != null) {
                String formattedDate = DateFormat('yyyy-MM-dd').format(value);
                setState(() {
                  cadCtrl.text = formattedDate;
                });
              }
            },
          ),
        ),
        formItemsDesign(
            Icons.text_fields,
            TextFormField(
              controller: ltCtrl,
              decoration: const InputDecoration(
                labelText: 'Lote del producto',
              ),
              keyboardType: TextInputType.text,
            )),
        formItemsDesign(
            Icons.numbers,
            TextFormField(
              controller: cantCtrl,
              decoration: const InputDecoration(
                labelText: 'Stock del producto',
              ),
              keyboardType: TextInputType.number,
            )),
        formItemsDesign(
          Icons.image,
          Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  final pickedImage =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    try {
                      final file = File(pickedImage.path);

                      // Subir la imagen a Firebase Storage
                      final storageRef = FirebaseStorage.instance
                          .ref()
                          .child('almacenes/${nomCtrl.text}.jpg');

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
            ],
          ),
        ),
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
        GestureDetector(
          onTap: () async {
            await addProducto(
              uidProducto.text, // Código de barras (uidProducto) en solo lectura
              nomCtrl.text,
              descCtrl.text,
              catCtrl.text,
              preCtrl.text,
              cadCtrl.text,
              ltCtrl.text,
              uidAlma.text,
              cantCtrl.text,
              imageUrl,
            ).then((_) {
              Navigator.pop(context);
            });
          },
          child: Container(
            margin: const EdgeInsets.all(30.0),
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              gradient: const LinearGradient(
                colors: [Color(0xFFEAC8CD), Color(0xFFECB6B6)],
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
          ),
        ),
      ],
    );
  }

  String? validateName(String value) {
    String pattern = r'(^[a-zA-Z ]*$)';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return "El nombre es necesario";
    } else if (!regExp.hasMatch(value)) {
      return "El nombre debe de ser a-z y A-Z";
    }
    return null;
  }
}
