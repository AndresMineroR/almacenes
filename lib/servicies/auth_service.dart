import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:almacenes/pages/homeI_page.dart';
import 'package:almacenes/pages/login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {

  Future<void> signup({
    required String email,
    required String password,
    required String nombre,
    required String numero,
    required BuildContext context,
    File? avatarFile
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      String? uid = userCredential.user?.uid;
      String avatarUrl = '';

      if (avatarFile != null) {
        final ref = FirebaseStorage.instance.ref().child('avatars').child('$uid.jpg');
        await ref.putFile(avatarFile);
        avatarUrl = await ref.getDownloadURL();
      }else{
        print('No se seleccionó un archivo para subir.');
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'Nombre': nombre,
        'Correo': email,
        'Telefono': numero,
        'avatarUrl': avatarUrl,
        'createdAt': FieldValue.serverTimestamp(), // Fecha de creación
      });

      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const HomeI()
          )
      );

    } on FirebaseAuthException catch(e) {
      print('FirebaseAuthException código: ${e.code}');
      String message = '';
      if (e.code == 'weak-password') {
        message = 'La contraseña en poco segura.';
      } else if (e.code == 'email-already-in-use') {
        message = 'El correo ya esta ligado a otra cuenta.';
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
    catch(e){
      Fluttertoast.showToast(
        msg: 'Ocurrió un error. Por favor, inténtalo de nuevo.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      print('Error no manejado: $e');
    }

  }

  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context
  }) async {
    try {
      FocusScope.of(context).unfocus();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await Future.delayed(const Duration(milliseconds: 1200));
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => const HomeI()),
      );

    } on FirebaseAuthException catch(e) {
      print('FirebaseAuthException código: ${e.code}');
      String message = 'Ambos campos son necesarios';
      if (e.code == 'user-no') {
        message = 'No existe un usuario con ese correo.';
      } else if (e.code == 'invalid-email') {
        message = 'El formato del correo es inválido.';
      } else if (e.code == 'invalid-password') {
        message = 'La contraseña proporcionada es incorrecta.';
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "Error inesperado, intenta de nuevo.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  Future<void> signout({
    required BuildContext context
  }) async {

    await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>Login()
        )
    );
  }
}