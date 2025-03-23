import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para obtener más datos del usuario
import 'package:flutter/material.dart';
import 'package:almacenes/servicies/auth_service.dart';

class Perfil extends StatefulWidget {
  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  String avatarUrl = '';
  String nombre = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Cargar datos del usuario al iniciar el widget
  }

  Future<void> _loadUserData() async {
    try {
      // Obtener el usuario autenticado
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Obtener el correo directamente de FirebaseAuth
        email = user.email ?? '';

        // Si tienes datos adicionales en Firestore
        DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userData.exists) {
          setState(() {
            nombre = userData.data()?['Nombre'] ?? 'Sin nombre'; // Obtiene el campo 'name'
            avatarUrl = userData.data()?['avatarUrl'] ?? '';  // Obtiene el campo 'avatarUrl'
          });
        }
      }
    } catch (e) {
      print('Error cargando datos del usuario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl) // Muestra el avatar si existe
                  : null,
              child: avatarUrl.isEmpty
                  ? const Icon(Icons.person, size: 50, color: Colors.grey)
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              nombre.isNotEmpty ? nombre : 'Cargando...',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              email.isNotEmpty ? email : 'Cargando...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                await AuthService().signout(context: context);
              },
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
