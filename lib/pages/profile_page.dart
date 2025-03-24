import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para obtener más datos del usuario
import 'package:flutter/material.dart';
import 'package:almacenes/servicies/auth_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class Perfil extends StatefulWidget {
  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  String avatarUrl = '';
  String nombre = '';
  String email = '';
  String telefono = '';

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
        email = user.email ?? '';

          // Obtener datos adicionales de Firestore
          DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userData.exists) {
            setState(() {
              nombre = userData.data()?['Nombre'] ?? 'Sin nombre';
              avatarUrl = userData.data()?['avatarUrl'] ?? '';
              telefono = userData.data()?['Telefono'] ?? 'Sin telefono';
            });
          }
        } else {
          print('No hay usuario autenticado.');
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
            Stack(
              children: [
                // El CircleAvatar
                CircleAvatar(
                  radius: 100,
                  backgroundImage: avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl) // Muestra el avatar si existe
                      : null,
                  child: avatarUrl.isEmpty
                      ? const Icon(Icons.person, size: 80, color: Colors.grey)
                      : null,
                ),
                // El ícono de edición
                Positioned(
                  bottom: 5,
                  right: 5, // Posicionar el ícono en la esquina inferior derecha
                  child: GestureDetector(
                    onTap: () async {
                      print('Editar imagen seleccionada');
                      // Seleccionar la imagen
                      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                      if (pickedImage != null) {
                        try {
                          // Subir la imagen a Firebase Storage
                          final storageRef = FirebaseStorage.instance.ref().child('avatars/$nombre.jpg');
                          await storageRef.putFile(File(pickedImage.path));

                          // Obtener la URL de descarga
                          final downloadUrl = await storageRef.getDownloadURL();
                          QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
                              .collection('users')
                              .where('Correo', isEqualTo: email)
                              .get();
                          String userId = querySnapshot.docs.first.id;

                          // Guardar la URL en Firestore
                          await FirebaseFirestore.instance.collection('users').doc(userId).update({
                            'avatarUrl': downloadUrl,
                          });

                          // Actualizar el estado con la nueva URL
                          setState(() {
                            avatarUrl = downloadUrl;
                          });
                          print('Imagen actualizada correctamente: $downloadUrl');
                        } catch (e) {
                          print('Error al subir la imagen: $e');
                        }
                      }
                    },
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Color.fromARGB(255, 236, 182, 182), // Fondo azul para el ícono
                      child: const Icon(
                        Icons.edit, // Ícono de edición
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
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
            const SizedBox(height: 10),
            Text(
              telefono.isNotEmpty ? telefono : 'Cargando...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await AuthService().signout(context: context);
                  },
                  child: const Text('Cerrar sesión'),
                ),
                ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true, // Permite ajustar la altura al abrir el teclado
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) {
                        TextEditingController nombreController = TextEditingController(text: nombre);
                        TextEditingController telefonoController = TextEditingController(text: telefono);

                        return Padding(
                          padding: EdgeInsets.only(
                            top: 20,
                            left: 20,
                            right: 20,
                            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Editar Perfil',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Campo para editar el nombre
                              FocusScope(
                                child: TextField(
                                  controller: nombreController,
                                  autofocus: true, // Se enfoca automáticamente
                                  decoration: InputDecoration(
                                    labelText: 'Nombre',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Campo para editar el teléfono
                              TextField(
                                controller: telefonoController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  labelText: 'Teléfono',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Botón para guardar cambios
                              ElevatedButton(
                                onPressed: () async {
                                  try {
                                    User? user = FirebaseAuth.instance.currentUser;
                                    if (user != null) {
                                      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                                        'Nombre': nombreController.text,
                                        'Telefono': telefonoController.text,
                                      });
                                      setState(() {
                                        nombre = nombreController.text;
                                        telefono = telefonoController.text;
                                      });
                                      Navigator.pop(context);
                                      print('Perfil actualizado correctamente.');
                                    }
                                  } catch (e) {
                                    print('Error al actualizar el perfil: $e');
                                  }
                                },
                                child: const Text('Guardar'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: const Text('Editar Perfil'),
                ),

              ],
            )
          ],
        ),
      ),
    );
  }
}
