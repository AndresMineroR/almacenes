import 'package:flutter/material.dart';
import 'package:almacenes/servicies/firebase_service.dart';

class EditCategoriaProductoPage extends StatefulWidget {
  const EditCategoriaProductoPage({super.key});

  @override
  State<EditCategoriaProductoPage> createState() => _EditCategoriaProductoPageState();
}

class _EditCategoriaProductoPageState extends State<EditCategoriaProductoPage> {
  GlobalKey<FormState> keyForm = GlobalKey();
  TextEditingController nomCtrlCat = TextEditingController();
  TextEditingController descCtrlCat = TextEditingController();
  TextEditingController uidCat = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    nomCtrlCat.text = arguments['NombreCat'];
    descCtrlCat.text = arguments['DescripcionCat'];
    uidCat.text = arguments['uidCat'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar categoría de producto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          margin: EdgeInsets.all(20.0),
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
              controller: nomCtrlCat,
              decoration: InputDecoration(
                labelText: 'Nombre de la categoría de producto',
              ),
              keyboardType: TextInputType.text,
              //validator: validateName,
            )),

        formItemsDesign(
            Icons.abc,
            TextFormField(
              controller: descCtrlCat,
              decoration: InputDecoration(
                labelText: 'Descripción de la categoria de producto',
              ),
              keyboardType: TextInputType.text,
              //validator:,
            )),


          GestureDetector(
            onTap: () async {
              await updateCategoriaProducto(
                  uidCat.text,
                  nomCtrlCat.text,
                  descCtrlCat.text
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
