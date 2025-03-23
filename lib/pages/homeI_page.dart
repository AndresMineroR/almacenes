import 'package:almacenes/servicies/firebase_service.dart';
import 'package:almacenes/pages/venta/venta_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  late AnimationController _controller;
  late Animation<double> _animation;
  final PageController _pageController = PageController(viewportFraction: 0.33);

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
      "icon": FontAwesomeIcons.boxOpen,
      "text": "Productos",
      "desc": "Consulta y gestiona tus productos",
      "route": "/productos",
      "color": Colors.green
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
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);
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
  /// - La gráfica de ventas según el filtro.
  Widget _buildTopSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 350,
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
          const SizedBox(height: 10),
          Expanded(child: _buildSalesChart()),
          // Etiquetas explicativas para los ejes
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Fecha (día/mes)", style: TextStyle(fontSize: 12)),
              Text(
                _selectedTimeFilter == "day"
                    ? "Total de Ventas  (\$)"
                    : _selectedTimeFilter == "week"
                    ? "Total de Ventas  (\$)"
                    : "Total de Ventas  (\$)",
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),

        ],
      ),
    );
  }

  /// Dropdown para seleccionar el almacén.
  Widget _buildWarehouseDropdown() {
    return FutureBuilder<List>(
      future: getAlmacenes(),
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

        // Calcular el máximo para el eje Y
        double maxY = barGroups
            .map((group) => group.barRods.first.toY)
            .reduce((a, b) => a > b ? a : b) * 1.2;

        // Calcular el total de ventas del período (sumando los totales por día)
        double totalVentasPeriodo = aggregatedData.values.fold(0.0, (prev, element) => prev + element);

        return Column(
          children: [
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
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
                        interval: 100,
                        getTitlesWidget: (value, meta) {
                          if (value % 100 == 0) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return Container();
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
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Fecha (día/mes)", style: TextStyle(fontSize: 12)),
                Text(
                  _selectedTimeFilter == "day"
                      ? "Total de Ventas del Día: \$${totalVentasPeriodo.toStringAsFixed(2)}"
                      : _selectedTimeFilter == "week"
                      ? "Total de Ventas de la Semana: \$${totalVentasPeriodo.toStringAsFixed(2)}"
                      : "Total de Ventas del Mes: \$${totalVentasPeriodo.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        );
      },
    );
  }




  Widget _buildMenuTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Menú de opciones", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text("Ver más →", style: TextStyle(fontSize: 16, color: Colors.blue)),
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text("Sección Inferior Adicional", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        Container(
          height: 150,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(child: Text("Contenido de la sección inferior", style: TextStyle(fontSize: 16))),
        ),
      ],
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
          IconButton(icon: const Icon(Icons.person), onPressed: () => Navigator.pushNamed(context, '/perfil')),
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
        pageBuilder: (context, animation, secondaryAnimation) => const VentaPage(),
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
