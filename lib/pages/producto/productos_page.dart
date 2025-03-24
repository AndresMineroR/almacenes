import 'package:flutter/material.dart';
import 'package:almacenes/servicies/firebase_service.dart';

class Productos extends StatefulWidget {
  const Productos({super.key});

  @override
  State<Productos> createState() => _ProductosState();
}

class _ProductosState extends State<Productos> {
  Map<String, String> almacenesMap = {}; // uidAlma -> NombreAlma
  bool almacenesCargados = false;
  // Variable para almacenar el almacén seleccionado; "all" indica que se muestran todos
  String selectedAlmacen = "all";

  @override
  void initState() {
    super.initState();
    _cargarAlmacenes();
  }

  Future<void> _cargarAlmacenes() async {
    var almacenesData = await getAlmacenes();
    setState(() {
      almacenesMap = {
        for (var almacen in almacenesData)
          almacen['uidAlma'].trim(): almacen['NombreAlma']
      };
      almacenesCargados = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
      ),
      body: almacenesCargados
          ? Column(
        children: [
          // Dropdown para filtrar por almacén
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedAlmacen,
              icon: const Icon(Icons.arrow_downward),
              isExpanded: true,
              items: [
                const DropdownMenuItem(
                  value: "all",
                  child: Text("Todos los almacenes"),
                ),
                ...almacenesMap.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  selectedAlmacen = value!;
                });
              },
            ),
          ),
          // Lista de productos filtrados
          Expanded(
            child: FutureBuilder(
              future: getProductos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasData) {
                  List productos = snapshot.data ?? [];
                  // Filtrar según el almacén seleccionado (si no es "all")
                  List productosFiltrados = selectedAlmacen == "all"
                      ? productos
                      : productos.where((p) {
                    String uid = p['UidAlma']?.trim() ?? "";
                    return uid == selectedAlmacen;
                  }).toList();

                  if (productosFiltrados.isEmpty) {
                    return const Center(
                        child:
                        Text("No hay productos para el almacén seleccionado"));
                  }

                  return ListView.builder(
                    itemCount: productosFiltrados.length,
                    itemBuilder: (context, index) {
                      String uidAlmaProd =
                          productosFiltrados[index]['UidAlma']?.trim() ?? '';
                      String nombreAlmacen = almacenesMap[uidAlmaProd] ??
                          'Almacén no encontrado';

                      return ListTile(
                        title: Card(
                          elevation: 5,
                          margin:
                          const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        productosFiltrados[index]
                                        ['ImagenProducto'] ??
                                            "https://firebasestorage.googleapis.com/v0/b/inventarioabarrotes-935f9.firebasestorage.app/o/productos%2FLa%20marca%20del%20producto%20Definici%C3%B3n%2C%20clasificaci%C3%B3n%2C%20c%C3%B3mo%20nacen%20y%20m%C3%A1s.jpg?alt=media&token=5f3ff423-6ab7-46d4-9387-e2bdab9a602c"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  width: double.infinity,
                                  padding:
                                  const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 20, 83, 21)
                                        .withOpacity(0.7),
                                    borderRadius:
                                    const BorderRadius.only(
                                      bottomLeft:
                                      Radius.circular(12),
                                      bottomRight:
                                      Radius.circular(12),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        productosFiltrados[index]
                                        ['Nombre'] ??
                                            'Sin Nombre',
                                        style:
                                        const TextStyle(
                                          fontSize: 20,
                                          fontWeight:
                                          FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Descripción: ${productosFiltrados[index]['Descripcion'] ?? 'Sin Descripción'}\n'
                                            'Stock: ${productosFiltrados[index]['Stock'] ?? 'Sin Stock'}\n'
                                            'Almacén: $nombreAlmacen',
                                        style:
                                        const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () async {
                          await Navigator.pushNamed(
                              context, '/mostrarProducto',
                              arguments: {
                                "Nombre": productosFiltrados[index]
                                ['Nombre'],
                                "Descripcion":
                                productosFiltrados[index]
                                ['Descripcion'],
                                "Categoria":
                                productosFiltrados[index]
                                ['Categoria'],
                                "Precio": productosFiltrados[index]
                                ['Precio'],
                                "Caducidad":
                                productosFiltrados[index]
                                ['Caducidad'],
                                "Lote": productosFiltrados[index]
                                ['Lote'],
                                "Stock": productosFiltrados[index]
                                ['Stock'],
                                "ImagenProducto":
                                productosFiltrados[index]
                                ['ImagenProducto'],
                                "CodigoBarras":
                                productosFiltrados[index]
                                ['CodigoBarras'],
                                "Almacen": nombreAlmacen,
                              });
                        },
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),

    );
  }
}
