import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PantallaUsuarios extends StatefulWidget {
  @override
  _PantallaUsuariosState createState() => _PantallaUsuariosState();
}

class _PantallaUsuariosState extends State {
  List usuarios = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    obtenerUsuarios();
  }

  // TODO EL TRABAJO EN EL MISMO ARCHIVO
  Future obtenerUsuarios() async {
    final url = Uri.parse('https://jsonplaceholder.typicode.com/users');
    final respuesta = await http.get(url);

    if (respuesta.statusCode == 200) {
      setState(() {
        usuarios = jsonDecode(respuesta.body);
        cargando = false;
      });
    } else {
      throw Exception('Error al cargar usuarios');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Usuarios (Monolito)')),
      body: cargando
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final usuario = usuarios[index];
                return ListTile(
                  title: Text(usuario['name']),
                  subtitle: Text(usuario['email']),
                );
              },
            ),
    );
  }
}
