import 'package:clean_arquitectura/domain/entities/usuario.dart';
import 'package:clean_arquitectura/domain/repositories/usuario_repository.dart';
import 'package:clean_arquitectura/domain/usecases/obtener_usuarios_con_vocal.dart';
import 'package:flutter_test/flutter_test.dart';

class RepositorioFalso implements UsuarioRepository {
  @override
  Future<List<Usuario>> obtener() async => const [
    Usuario(id: 1, nombre: 'Ana', email: 'ana@example.com'),
    Usuario(id: 2, nombre: 'bruno', email: 'bruno@example.com'),
    Usuario(id: 3, nombre: ' elena', email: 'elena@example.com'),
    Usuario(id: 4, nombre: '', email: 'vacio@example.com'),
  ];
}

void main() {
  test('filtra nombres que empiezan con vocal sin Flutter', () async {
    final resultado = await ObtenerUsuariosConVocal(RepositorioFalso())();
    expect(resultado.map((usuario) => usuario.nombre), ['Ana', ' elena']);
  });
}
