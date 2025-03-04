import 'package:flutter/material.dart';
import 'package:almacenes/servicies/firebase_service.dart';

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
  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    nomCtrl.text = arguments['Nombre'];
    descCtrl.text = arguments['Descripcion'];
    catCtrl.text = arguments['Categoria'].toString();
    preCtrl.text = arguments['Precio'].toString();
    cadCtrl.text = arguments['Caducidad'];
    ltCtrl.text = arguments['Lote'];
    uid.text = arguments['uid'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          margin: EdgeInsets.all(20.0),
          child: Form(
            key: keyForm,
            child: formUI(), //Este metodo lo crearemos mas adelante
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
            Icons.numbers,
            TextFormField(
              controller: catCtrl,
              decoration: InputDecoration(
                labelText: 'Categoría del producto',
              ),
              keyboardType: TextInputType.number,
              //validator: validateName(catCtrl),
            )),

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
            Icons.calendar_month,
            TextFormField(
              controller: cadCtrl,
              decoration: InputDecoration(
                labelText: 'Caducidad del producto',
              ),
              keyboardType: TextInputType.datetime,
              //validator:,
            )),

        formItemsDesign(
            Icons.abc,
            TextFormField(
              controller: ltCtrl,
              decoration: InputDecoration(
                labelText: 'Lote del producto',
              ),
              keyboardType: TextInputType.text,
              //validator:,
            )),

        GestureDetector(
            onTap: () async {
              await updateProducto(
                  uid.text,
                  nomCtrl.text,
                  descCtrl.text,
                  int.parse(catCtrl.text),
                  int.parse(preCtrl.text),
                  cadCtrl.text,
                  ltCtrl.text
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
          child: Text("Guardar",
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
