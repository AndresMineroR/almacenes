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

  final PageController _pageController = PageController(viewportFraction: 0.33); // Ahora se ven 3 tarjetas por pantalla

  final List<Map<String, dynamic>> _menuItems = [
    {"icon": FontAwesomeIcons.cashRegister, "text": "Venta", "desc": "Realiza una venta fácilmente", "route": "/venta", "color": Colors.orange},
    {"icon": FontAwesomeIcons.boxOpen, "text": "Productos", "desc": "Consulta y gestiona tus productos", "route": "/productos", "color": Colors.green},
    {"icon": FontAwesomeIcons.warehouse, "text": "Almacenes", "desc": "Administra tus almacenes", "route": "/almacenes", "color": Colors.purple},
    {"icon": FontAwesomeIcons.layerGroup, "text": "Categorías", "desc": "Organiza tus productos por categorías", "route": "/categorias", "color": Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000)); // Duración de la animación aumentada para mejor visibilidad
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
    double cardWidth = MediaQuery.of(context).size.width * 0.3;
    double cardHeight = cardWidth * 1.5;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Bienvenido', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: FadeTransition(
        opacity: _animation,
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            Container(
              alignment: Alignment.center,
              height: 200,
              child: const Text(
                "Contenido superior",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Menú de opciones", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("Ver más →", style: TextStyle(fontSize: 16, color: Colors.blue)),
                ],
              ),
            ),
            SizedBox(
              height: cardHeight + 20,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _menuItems.length,
                physics: const BouncingScrollPhysics(),
                padEnds: false,
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, item["route"]);
                      },
                      child: Container(
                        width: cardWidth,
                        height: cardHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: item["color"],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white.withOpacity(0.7),
                              child: FaIcon(item["icon"], size: 30, color: item["color"]),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item["text"],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                item["desc"],
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12, color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
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
              child: const Center(
                child: Text("Contenido de la sección inferior", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {},
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.pushNamed(context, '/perfil'); // Redirigir a la página de perfil
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/venta'); // Redirigir a la página de ventas
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, size: 26, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
