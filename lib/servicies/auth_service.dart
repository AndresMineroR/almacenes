import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:almacenes/pages/homeI_page.dart';
import 'package:almacenes/pages/login/login.dart';

class AuthService {

  Future<void> signup({
    required String email,
    required String password,
    required BuildContext context
  }) async {

    try {

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

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
      // Ocultar el teclado antes de iniciar sesión
      FocusScope.of(context).unfocus();

      // Mostrar pantalla de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Intentar autenticación con Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Pequeño delay para mejorar la UX
      await Future.delayed(const Duration(milliseconds: 1200));

      // Cerrar el diálogo de carga
      Navigator.pop(context);

      // Navegar a la pantalla principal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => const HomeI()),
      );

<<<<<<< Updated upstream
    } on FirebaseAuthException catch (e) {
      // Cerrar el diálogo de carga en caso de error
      Navigator.pop(context);

      String message = '';
      if (e.code == 'user-not-found') {
        message = 'No se encontró un usuario con ese correo.';
      } else if (e.code == 'wrong-password') {
        message = 'La contraseña proporcionada es incorrecta.';
      } else {
        message = 'Error al iniciar sesión.';
=======
    } on FirebaseAuthException catch(e) {
      print('FirebaseAuthException código: ${e.code}');
      String message = 'Ambos campos son necesarios';
      if (e.code == 'user-no') {
        message = 'No existe un usuario con ese correo.';
      } else if (e.code == 'invalid-email') {
        message = 'El formato del correo es inválido.';
      } else if (e.code == 'invalid-password') {
        message = 'La contraseña proporcionada es incorrecta.';
>>>>>>> Stashed changes
      }

      // Mostrar mensaje de error con Toast
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } catch (e) {
      // Manejar errores generales
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
<<<<<<< Updated upstream
=======
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

>>>>>>> Stashed changes
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