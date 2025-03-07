import 'package:flutter/material.dart';
import 'package:almacenes/servicies/firebase_service.dart';

class AddCategoriaProductoPage extends StatefulWidget {
  const AddCategoriaProductoPage({super.key});


  @override
  State<AddCategoriaProductoPage> createState() => _AddCategoriaProductoPageState();
}
class _AddCategoriaProductoPageState extends State<AddCategoriaProductoPage> {
  GlobalKey<FormState> keyForm = GlobalKey();
  TextEditingController nomCtrlCat = TextEditingController(text: '');
  TextEditingController descCtrlCat = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar categoría de producto'),
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
              controller: nomCtrlCat,
              decoration: InputDecoration(
                labelText: 'Nombre de la categoría',
              ),
              keyboardType: TextInputType.text,
              //validator: validateName,
            )),

        formItemsDesign(
            Icons.abc,
            TextFormField(
              controller: descCtrlCat,
              decoration: InputDecoration(
                labelText: 'Descripción de la categoría',
              ),
              keyboardType: TextInputType.text,
              //validator:,
            )),

        /*formItemsDesign(
            Icons.numbers,
            TextFormField(
              controller: catCtrl,
              decoration: InputDecoration(
                labelText: 'Categoría del producto',
              ),
              keyboardType: TextInputType.number,
              //validator: validateName(catCtrl),
            )
        ),*/

               GestureDetector(
                  onTap: () async {
                    await addCategoriaProducto(
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

  String? validateName(String value) {
    String pattern = r'(^[a-zA-Z ]*$)';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return "El nombre es necesario";
    } else if (!regExp.hasMatch(value)) {
      return "El nombre debe de ser a-z y A-Z";
    }
    return null;
  }

}
