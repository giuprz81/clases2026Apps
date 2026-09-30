import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';

class UsuarioMemoria implements UsuarioRepository {
  @override
  Future<List<Usuario>> obtener() async => const [
    Usuario(id: 1, nombre: 'Ana', email: 'ana@example.com'),
    Usuario(id: 2, nombre: 'Bruno', email: 'bruno@example.com'),
    Usuario(id: 3, nombre: 'Elena', email: 'elena@example.com'),
  ];
}
