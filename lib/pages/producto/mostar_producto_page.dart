import 'package:flutter/material.dart';

class MostrarProducto extends StatefulWidget {
  @override
  State<MostrarProducto> createState() => _MostrarProductoState();
}

class _MostrarProductoState extends State<MostrarProducto> {

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    String nomCtrl = arguments['Nombre'];
    String descCtrl = arguments['Descripcion'];
    String catCtrl = arguments['Categoria'];
    String preCtrl = arguments['Precio'];
    String cadCtrl = arguments['Caducidad'];
    String ltCtrl = arguments['Lote'];
    String Stock = arguments['Stock'];
    return Scaffold(
        appBar: AppBar(
        title: const Text('Informacion del producto'),
    ),
      body:  Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            _buildInfoCard(
              "Nombre", nomCtrl,
              "Descripción", descCtrl,
              "Categoría", catCtrl,
              "Precio", preCtrl,
              "Caducidad", cadCtrl,
              "Lote", ltCtrl,
              "Stock", Stock,),

          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      String labNom, String nom,
      String labDes, String desc,
      String labCat, String cat,
      String labPre, String pre,
      String labCad, String cad,
      String labLt, String lt,
      String labSto, String sto,)
  {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Color.fromARGB(255, 237, 186, 186),
              size: 30,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    labNom,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 206, 148, 148),
                    ),
                  ),
                  Text(
                    nom,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    labDes,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 206, 148, 148),
                    ),
                  ),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    labCat,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 206, 148, 148),
                    ),
                  ),
                  Text(
                    cat,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    labPre,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 206, 148, 148),
                    ),
                  ),
                  Text(
                    '\$ '+pre,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    labCad,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 206, 148, 148),
                    ),
                  ),
                  Text(
                    cad,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    labLt,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 206, 148, 148),
                    ),
                  ),
                  Text(
                    lt,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    labSto,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 206, 148, 148),
                    ),
                  ),
                  Text(
                    sto,
                    style: TextStyle(
                      fontSize: 18,
                      color: int.parse(sto) <= 10 ? Colors.red : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
