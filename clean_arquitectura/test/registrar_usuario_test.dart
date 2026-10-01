import 'package:clean_arquitectura/domain/entities/perfil.dart';
import 'package:clean_arquitectura/domain/repositories/auth_repository.dart';
import 'package:clean_arquitectura/domain/repositories/perfiles_repository.dart';
import 'package:clean_arquitectura/domain/usecases/registrar_usuario.dart';
import 'package:flutter_test/flutter_test.dart';

class AuthFalso implements AuthRepository {
  @override
  Future<void> ingresar(String correo, String clave) async {}

  @override
  String? obtenerIdActual() => 'id-1';

  @override
  Future<String> registrar(String correo, String clave) async => 'id-1';

  @override
  Future<void> salir() async {}
}

class PerfilesFalso implements PerfilesRepository {
  String? idCreado;
  String? nombreCreado;

  @override
  Future<void> crear(String id, String nombre) async {
    idCreado = id;
    nombreCreado = nombre;
  }

  @override
  Future<List<Perfil>> obtenerTodos() async => [];
}

void main() {
  test('registra la cuenta y después crea el perfil con su id', () async {
    final perfiles = PerfilesFalso();
    await RegistrarUsuario(AuthFalso(), perfiles)('ana@usfq.edu.ec', 'clave', 'Ana');

    expect(perfiles.idCreado, 'id-1');
    expect(perfiles.nombreCreado, 'Ana');
  });
}
