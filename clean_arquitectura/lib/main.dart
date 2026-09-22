import 'package:flutter/material.dart';

import 'pantalla_usuarios.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Arquitectura',
      home: PantallaUsuarios(),
    );
  }
}
