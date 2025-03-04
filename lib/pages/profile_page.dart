import 'package:flutter/material.dart';

class Perfil extends StatelessWidget {
  final String avatarUrl = 'https://scontent.fmex5-1.fna.fbcdn.net/v/t39.30808-1/463340676_8180933938683107_2949072671352150948_n.jpg?stp=dst-jpg_s160x160_tt6&_nc_cat=108&ccb=1-7&_nc_sid=e99d92&_nc_eui2=AeF1tNzyLluCG0gmeayxrNptlDbEmaP7vCqUNsSZo_u8KqtKc2MTcjSd9JBQYIT6kdASb4dxiW7HHYPp-_fRrHf8&_nc_ohc=LyTXzdmfLYkQ7kNvgF7YdO3&_nc_oc=AdhG53Kh4b3azedtpDti0jdreRdEi9hQQJWh93DBoP1jGreey6UeG5J6oQ-MEv1T2L2SQ0rebBIAXVVPSJ32EsAG&_nc_zt=24&_nc_ht=scontent.fmex5-1.fna&_nc_gid=AaMPBd-VCd2rwhzooJAZ1zf&oh=00_AYBnB5UxWBQYnOXZfFW_T7n4JswtRbpSmC3-9fZdJLRqBQ&oe=67CC56B6';
  final String nombre = 'Edgar Ortega';
  final String email = 'edgar220397@gmail.com';

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
              backgroundImage: NetworkImage(avatarUrl),
            ),
            SizedBox(height: 20),
            Text(
              nombre,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              email,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
