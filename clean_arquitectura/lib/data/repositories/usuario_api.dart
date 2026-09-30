import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';

class UsuarioApi implements UsuarioRepository {
  static const _url = 'https://jsonplaceholder.typicode.com/users';

  @override
  Future<List<Usuario>> obtener() async {
    final respuesta = await http.get(Uri.parse(_url));
    if (respuesta.statusCode != 200) {
      throw Exception('Error al cargar usuarios desde la API');
    }
    final datosJson = jsonDecode(respuesta.body) as List<dynamic>;
    return datosJson.map((json) {
      final datos = json as Map<String, dynamic>;
      return Usuario(id: datos['id'] as int, nombre: datos['name'] as String, email: datos['email'] as String);
    }).toList();
  }
}
