import 'package:flutter/material.dart';

class MostrarProducto extends StatefulWidget {
  @override
  State<MostrarProducto> createState() => _MostrarProductoState();
}

class _MostrarProductoState extends State<MostrarProducto> {
  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Información del Producto'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        arguments['ImagenProducto'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildInfoTile("Nombre", arguments['Nombre']),
                  _buildInfoTile("Descripción", arguments['Descripcion']),
                  _buildInfoTile("Categoría", arguments['Categoria']),
                  _buildInfoTile("Precio", "\$${arguments['Precio']}"),
                  _buildInfoTile("Caducidad", arguments['Caducidad']),
                  _buildInfoTile("Lote", arguments['Lote']),
                  _buildInfoTile("Stock", arguments['Stock'],
                      stockColor: int.parse(arguments['Stock']) <= 10 ? Colors.red : Colors.black),
                  _buildInfoTile("Código de Barras", arguments['CodigoBarras']),
                  _buildInfoTile("Almacén", arguments['Almacen']),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, {Color stockColor = Colors.black}) {
    return Column(
      children: [
        ListTile(
          title: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          subtitle: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: stockColor,
            ),
          ),
        ),
        Divider(),
      ],
    );
  }
}
