// lib/domain/usuario_repository.dart
import 'usuario.dart';

abstract class UsuarioRepository {
  Future> obtenerUsuarios();
}