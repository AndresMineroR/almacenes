import 'package:almacenes/pages/login/signup.dart';
import 'package:almacenes/servicies/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: _signup(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100,
       /* leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.only(left: 10),
            decoration: const BoxDecoration(
                color: Color(0xffF7F7F9),
                shape: BoxShape.circle
            ),
            child: const Center(
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.black,
              ),
            ),
          ),
        ),*/
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: Image.asset(
                    'lib/assets/logo.jpg',
                    height: 100,
                    fit: BoxFit.cover, // Ajustar cómo se muestra la imagen
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Bienvenido a Invent0taly',
                  style: GoogleFonts.raleway(
                      textStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 24
                      )
                  ),
                ),
              ),
              const SizedBox(height: 80,),
              _emailAddress(),
              const SizedBox(height: 20,),
              _password(),
              const SizedBox(height: 50,),
              _signin(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emailAddress() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Correo electrónico',
          style: GoogleFonts.raleway(
              textStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 16
              )
          ),
        ),
        const SizedBox(height: 16,),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
              filled: true,
              hintText: 'ejemplo@gmail.com',
              hintStyle: const TextStyle(
                  color: Color(0xff6A6A6A),
                  fontWeight: FontWeight.normal,
                  fontSize: 14
              ),
              fillColor: const Color(0xffF7F7F9) ,
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(14)
              )
          ),
          keyboardType: TextInputType.emailAddress,
        )
      ],
    );
  }

  Widget _password() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contraseña',
          style: GoogleFonts.raleway(
              textStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 16
              )
          ),
        ),
        const SizedBox(height: 16,),
        TextField(
          obscureText: true,
          controller: _passwordController,
          decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xffF7F7F9) ,
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(14)
              )
          ),
        )
      ],
    );
  }

  Widget _signin(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffecb6b6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        minimumSize: const Size(double.infinity, 60),
        elevation: 0,
        textStyle: TextStyle(color: Colors.black), // Establecer el color del texto
      ),
      onPressed: () async {
        await AuthService().signin(
            email: _emailController.text,
            password: _passwordController.text,
            context: context
        );
      },
      child: const Text("Acceder"),
    );
  }

  Widget _signup(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              children: [
                const TextSpan(
                  text: "¿Usuario nuevo? ",
                  style: TextStyle(
                      color: Color(0xff6A6A6A),
                      fontWeight: FontWeight.normal,
                      fontSize: 16
                  ),
                ),
                TextSpan(
                    text: "Crea una cuenta",
                    style: const TextStyle(
                        color: Color(0xff1A1D1E),
                        fontWeight: FontWeight.normal,
                        fontSize: 16
                    ),
                    recognizer: TapGestureRecognizer()..onTap = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Signup()
                        ),
                      );
                    }
                ),
              ]
          )
      ),
    );
  }
}