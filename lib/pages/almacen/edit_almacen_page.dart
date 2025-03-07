import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    nomCtrlAlma.text = arguments['NombreAlma'];
    descCtrlAlma.text = arguments['DescripcionAlma'];
    uidAlma.text = arguments['uidAlma'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Almacen'),
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
              controller: nomCtrlAlma,
              decoration: InputDecoration(
                labelText: 'Nombre del Almacen',
              ),
              keyboardType: TextInputType.text,
              //validator: validateName,
            )),

        formItemsDesign(
            Icons.abc,
            TextFormField(
              controller: descCtrlAlma,
              decoration: InputDecoration(
                labelText: 'Descripción del Almacen',
              ),
              keyboardType: TextInputType.text,
              //validator:,
            )),

        formItemsDesign(
            Icons.abc,
            TextFormField(
              controller: uidAlma,
              decoration: InputDecoration(
                labelText: 'Dueño del Almacen',
              ),
              keyboardType: TextInputType.text,
              //validator:,
            )),

          GestureDetector(
            onTap: () async {
              await updateAlmacen(
                  uidAlma.text,
                  nomCtrlAlma.text,
                  descCtrlAlma.text
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
