import 'package:almacenes/servicies/firebase_service.dart';
import 'package:almacenes/pages/venta/venta_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeI extends StatefulWidget {
  final AnimationController? animationController;
  const HomeI({super.key, this.animationController});

  @override
  State<HomeI> createState() => _HomeState();
}

class _HomeState extends State<HomeI> with SingleTickerProviderStateMixin {
  String UidUser = '';
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
  late AnimationController _controller;
  late Animation<double> _animation;
  final PageController _pageController = PageController(viewportFraction: 0.33);
  int _startHour = 5;
  int _endHour = 24;

  // Para el dropdown de almacenes
  String? _selectedAlmacen;

  // Para filtrar la gráfica por período
  String _selectedTimeFilter = "day"; // Valores: "day", "week", "month"

  final List<Map<String, dynamic>> _menuItems = [
    {
      "icon": FontAwesomeIcons.cashRegister,
      "text": "Venta",
      "desc": "Realiza una venta fácilmente",
      "route": "/venta",
      "color": Colors.orange
    },
    {
      "icon": FontAwesomeIcons.warehouse,
      "text": "Almacenes",
      "desc": "Administra tus almacenes",
      "route": "/almacenes",
      "color": Colors.purple
    },
    {
      "icon": FontAwesomeIcons.layerGroup,
      "text": "Categorías",
      "desc": "Organiza tus productos por categorías",
      "route": "/categorias",
      "color": Colors.red
    },
    {
      "icon": FontAwesomeIcons.boxOpen,
      "text": "Productos",
      "desc": "Consulta y gestiona tus productos",
      "route": "/productos",
      "color": Colors.green
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _animation,
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            _buildTopSection(), // Sección de gráfica y filtros
            _buildMenuTitle(),
            _buildMenuOptions(),
            _buildBottomSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAppBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Bienvenido',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Sección superior que muestra:
  /// - Un título.
  /// - Un Dropdown para seleccionar el almacén.
  /// - Un conjunto de ChoiceChips para elegir el filtro por día, semana o mes.
  Widget _buildTimeRangeSelector() {
    if (_selectedTimeFilter != "day") return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Rango de horas (AM): $_startHour - ${_endHour == 24 ? '12' : _endHour.toString()}",
          style: const TextStyle(fontSize: 12),
        ),
        RangeSlider(
          min: 0,
          max: 24,
          divisions: 24,
          values: RangeValues(_startHour.toDouble(), _endHour.toDouble()),
          onChanged: (RangeValues values) {
            setState(() {
              _startHour = values.start.round();
              _endHour = values.end.round();
            });
          },
          labels: RangeLabels(
            _startHour.toString(),
            _endHour == 24 ? "12" : _endHour.toString(),
          ),
        ),
      ],
    );
  }
  /// - La gráfica de ventas según el filtro.
  Widget _buildTopSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 450,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ventas recientes",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildWarehouseDropdown(),
          const SizedBox(height: 10),
          _buildTimeFilter(),
          // Mostrar el selector de rango solo cuando el filtro sea "día"
          _buildTimeRangeSelector(),
          const SizedBox(height: 10),
          Expanded(child: _buildSalesChart()),
        ],
      ),
    );
  }



  /// Dropdown para seleccionar el almacén.
  Widget _buildWarehouseDropdown() {
    return FutureBuilder<List>(
      future: getAlmacenes(UidUser),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return const Text("Error cargando almacenes");
        }
        List almacenes = snapshot.data ?? [];
        if (almacenes.isEmpty) {
          return const Text("No hay almacenes disponibles");
        }
        // Seleccionar el primer almacén por defecto
        _selectedAlmacen ??= almacenes[0]['uidAlma'];
        return DropdownButton<String>(
          value: _selectedAlmacen,
          items: almacenes.map<DropdownMenuItem<String>>((almacen) {
            return DropdownMenuItem<String>(
              value: almacen['uidAlma'],
              child: Text(almacen['NombreAlma']),
            );
          }).toList(),
          onChanged: (newVal) {
            setState(() {
              _selectedAlmacen = newVal;
            });
          },
        );
      },
    );
  }

  /// ChoiceChips para seleccionar el filtro de la gráfica.
  Widget _buildTimeFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: const Text("Día"),
          selected: _selectedTimeFilter == "day",
          onSelected: (selected) {
            setState(() {
              _selectedTimeFilter = "day";
            });
          },
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text("Semana"),
          selected: _selectedTimeFilter == "week",
          onSelected: (selected) {
            setState(() {
              _selectedTimeFilter = "week";
            });
          },
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text("Mes"),
          selected: _selectedTimeFilter == "month",
          onSelected: (selected) {
            setState(() {
              _selectedTimeFilter = "month";
            });
          },
        ),
      ],
    );
  }

  /// Gráfica de ventas filtradas según el almacén y el período seleccionado.
  /// Se consulta Firestore por las ventas que ocurran a partir de una fecha calculada
  /// y se agrupan por día para mostrar un total por fecha.
  Widget _buildSalesChart() {
    if (_selectedAlmacen == null) {
      return const Center(child: Text("Seleccione un almacén"));
    }
    // Determinar la fecha de inicio según el filtro seleccionado
    DateTime now = DateTime.now();
    DateTime startDate;
    if (_selectedTimeFilter == "day") {
      startDate = DateTime(now.year, now.month, now.day);
    } else if (_selectedTimeFilter == "week") {
      startDate = now.subtract(const Duration(days: 7));
    } else {
      startDate = now.subtract(const Duration(days: 30));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: baseInventario
          .collection('ventas')
          .where('uidAlmacen', isEqualTo: _selectedAlmacen)
          .where('fecha', isGreaterThanOrEqualTo: startDate)
          .orderBy('fecha', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text("No hay ventas registradas"));
        }

        // Filtro "día": agrupar las ventas por hora usando el rango seleccionado
        if (_selectedTimeFilter == "day") {
          // Crear una lista de ventas individuales que ocurren dentro del rango seleccionado
          List<Map<String, dynamic>> salesList = [];
          for (var doc in docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            Timestamp ts = data['fecha'];
            DateTime saleDate = ts.toDate();
            // Solo consideramos ventas dentro del rango seleccionado (_startHour a _endHour)
            if (saleDate.hour >= _startHour && saleDate.hour <= _endHour) {
              double saleTotal = 0.0;
              if (data['totalVenta'] is num) {
                saleTotal = (data['totalVenta'] as num).toDouble();
              } else if (data['totalVenta'] is String) {
                saleTotal = double.tryParse(data['totalVenta'].toString()) ?? 0.0;
              }
              salesList.add({
                'date': saleDate,
                'total': saleTotal,
              });
            }
          }

          // Ordenar las ventas por fecha
          salesList.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

          // Crear barras individuales para cada venta
          List<BarChartGroupData> barGroups = [];
          for (int i = 0; i < salesList.length; i++) {
            double total = salesList[i]['total'] as double;
            barGroups.add(
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: total,
                    width: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            );
          }

          // Calcular el máximo para el eje Y
          double maxY = 0;
          if (barGroups.isNotEmpty) {
            maxY = barGroups
                .map((group) => group.barRods.first.toY)
                .reduce((a, b) => a > b ? a : b) *
                1.2;
          }
          if (maxY == 0) maxY = 100;

          double totalVentasPeriodo = salesList.fold(0.0, (prev, sale) => prev + (sale['total'] as double));
          double step = maxY / 10;
          if (step < 1) step = 1;

          // Definir el widget para las etiquetas en el eje X (solo en la parte inferior)
          SideTitles bottomTitles = SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              if (index < 0 || index >= salesList.length) return Container();
              // Para evitar saturar, mostramos la etiqueta solo para cada 2do elemento
              if (index % 2 != 0) return Container();
              DateTime saleDate = salesList[index]['date'] as DateTime;
              String label = "${saleDate.hour.toString().padLeft(2, '0')}:${saleDate.minute.toString().padLeft(2, '0')}";
              return Text(
                label,
                style: const TextStyle(fontSize: 10),
              );
            },
          );

          // Envolver el gráfico en un SingleChildScrollView para permitir scroll horizontal
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    // Ajusta el ancho según la cantidad de ventas individuales
                    width: barGroups.length * 30.0,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxY,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(

                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              // Verifica que el índice esté en el rango de salesList
                              if (groupIndex < 0 || groupIndex >= salesList.length) return null;
                              final sale = salesList[groupIndex];
                              final saleTotal = sale['total'] as double;
                              final saleDate = sale['date'] as DateTime;
                              final formattedTime =
                                  "${saleDate.hour.toString().padLeft(2, '0')}:${saleDate.minute.toString().padLeft(2, '0')}";
                              return BarTooltipItem(
                                "\$${saleTotal.toStringAsFixed(2)}\n$formattedTime",
                                const TextStyle(color: Colors.white),
                              );
                            },
                          ),
                        ),

                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: bottomTitles,
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: step,
                              getTitlesWidget: (value, meta) {
                                int closedValue = (value.toInt() ~/ 10) * 10;
                                return Text(
                                  closedValue.toString(),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: barGroups,
                      ),
                    ),
                  ),

                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Hora (HH:mm)", style: TextStyle(fontSize: 12)),
                  Text(
                    "Total de Ventas del Día: \$${totalVentasPeriodo.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          );

        }


        else {
          // ... Lógica para "week" y "month" (se mantiene igual)
          // (Puedes dejar tu código actual para esos casos)

          // Agrupar las ventas por día (clave: "día/mes/año")
          Map<String, double> aggregatedData = {};
          for (var doc in docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            Timestamp ts = data['fecha'];
            DateTime date = ts.toDate();
            String key = "${date.day}/${date.month}/${date.year}";
            double total = 0.0;
            if (data['totalVenta'] is num) {
              total = (data['totalVenta'] as num).toDouble();
            } else if (data['totalVenta'] is String) {
              total = double.tryParse(data['totalVenta'].toString()) ?? 0.0;
            }
            aggregatedData[key] = (aggregatedData[key] ?? 0) + total;
          }

          // Ordenar las claves (fechas) de forma ascendente
          List<String> sortedKeys = aggregatedData.keys.toList();
          sortedKeys.sort((a, b) {
            List<String> partsA = a.split('/');
            List<String> partsB = b.split('/');
            DateTime dateA = DateTime(
              int.parse(partsA[2]),
              int.parse(partsA[1]),
              int.parse(partsA[0]),
            );
            DateTime dateB = DateTime(
              int.parse(partsB[2]),
              int.parse(partsB[1]),
              int.parse(partsB[0]),
            );
            return dateA.compareTo(dateB);
          });

          // Crear grupos de barras para la gráfica
          List<BarChartGroupData> barGroups = [];
          for (int i = 0; i < sortedKeys.length; i++) {
            double total = aggregatedData[sortedKeys[i]]!;
            barGroups.add(
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: total,
                    width: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            );
          }

          double maxY = barGroups
              .map((group) => group.barRods.first.toY)
              .reduce((a, b) => a > b ? a : b) * 1.2;
          double totalVentasPeriodo = aggregatedData.values.fold(0.0, (prev, element) => prev + element);
          double step = maxY / 10;
          if (step < 1) step = 1;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Permite desplazamiento horizontal
                  child: SizedBox(
                    width: barGroups.length * 50.0, // Ajusta el ancho dinámicamente según la cantidad de barras
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxY,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false), // Oculta los títulos en el eje X superior
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index < 0 || index >= sortedKeys.length) return Container();
                                return Text(
                                  sortedKeys[index].split('/').sublist(0, 2).join('/'),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: step,
                              getTitlesWidget: (value, meta) {
                                int closedValue = (value.toInt() ~/ 10) * 10;
                                return Text(
                                  closedValue.toString(),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: barGroups,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Fecha (día/mes)", style: TextStyle(fontSize: 12)),
                  Text(
                    _selectedTimeFilter == "week"
                        ? "Total de Ventas de la Semana: \$${totalVentasPeriodo.toStringAsFixed(2)}"
                        : "Total de Ventas del Mes: \$${totalVentasPeriodo.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          );


        }
      },
    );
  }



  Widget _buildMenuTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Menú de opciones",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text("", style: TextStyle(fontSize: 16, color: Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildMenuOptions() {
    return SizedBox(
      height: MediaQuery.of(context).size.width * 0.52,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _menuItems.length,
        physics: const BouncingScrollPhysics(),
        padEnds: false,
        itemBuilder: (context, index) {
          final item = _menuItems[index];
          return _buildMenuItem(item, index);
        },
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item, int index) {
    return GestureDetector(
      onTap: () {
        if (item["route"] == '/venta') {
          _navigateToVenta(context);
        } else {
          Navigator.pushNamed(context, item["route"]);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: item["color"],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Hero(
              tag: "hero-item-$index",
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.7),
                child: FaIcon(item["icon"], size: 30, color: item["color"]),
              ),
            ),
            const SizedBox(height: 10),
            Text(item["text"],
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(item["desc"],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    if (_selectedAlmacen == null) {
      return const Center(child: Text('Seleccione un almacén primero'));
    }

    return Container(
      padding: const EdgeInsets.all(10),
      child: FutureBuilder(
        future: Future.wait([
          getProductosMasVendidos(_selectedAlmacen!),
          getProductosMenorStock(_selectedAlmacen!),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final masVendidos = snapshot.data![0];
          final menosStock = snapshot.data![1];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text("Reportes del Almacén",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text("Más vendidos",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...masVendidos.take(3).map((prod) => Container(
                      width: 100,
                      margin: EdgeInsets.all(5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("🔥", style: TextStyle(fontSize: 24)),
                          SizedBox(height: 5),
                          Text(prod['nombre'], overflow: TextOverflow.ellipsis, textAlign: TextAlign.center)
                        ],
                      ),
                    )),
                    GestureDetector(
                      onTap: () => _mostrarMas(context, masVendidos, "🔥"),
                      child: Container(
                        width: 100,
                        alignment: Alignment.center,
                        child: Text("Ver más", style: TextStyle(color: Colors.blue)),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text("Poco Stock",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...menosStock.take(3).map((prod) => Container(
                      width: 100,
                      margin: EdgeInsets.all(5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("⚠️", style: TextStyle(fontSize: 24)),
                          SizedBox(height: 5),
                          Text(prod['nombre'], overflow: TextOverflow.ellipsis, textAlign: TextAlign.center)
                        ],
                      ),
                    )),
                    GestureDetector(
                      onTap: () => _mostrarMas(context, menosStock, "⚠️"),
                      child: Container(
                        width: 100,
                        alignment: Alignment.center,
                        child: Text("Ver más", style: TextStyle(color: Colors.blue)),
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  void _mostrarMas(BuildContext context, List<Map<String, dynamic>> productos, String emoji) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(10),
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: productos.length,
          itemBuilder: (context, index) => Container(
            width: 120,
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: TextStyle(fontSize: 24)),
                SizedBox(height: 5),
                Text(productos[index]['nombre'], overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                SizedBox(height: 5),
                Text(emoji == "🔥"
                    ? "${productos[index]['cantidadVendida']} vendidos"
                    : "Stock: ${productos[index]['stock']}",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildBottomAppBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
          const SizedBox(width: 40),
          IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => Navigator.pushNamed(context, '/perfil')),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _navigateToVenta(context),
      backgroundColor: Colors.blue,
      child: const Icon(Icons.add, size: 26, color: Colors.white),
    );
  }

  void _navigateToVenta(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const VentaPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
