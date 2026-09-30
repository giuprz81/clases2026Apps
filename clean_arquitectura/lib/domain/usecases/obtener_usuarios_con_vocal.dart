import '../entities/usuario.dart';
import '../repositories/usuario_repository.dart';

class ObtenerUsuariosConVocal {
  final UsuarioRepository _repositorio;

  const ObtenerUsuariosConVocal(this._repositorio);

  Future<List<Usuario>> call() async {
    final usuarios = await _repositorio.obtener();
    return usuarios.where((usuario) {
      final nombre = usuario.nombre.trim();
      return nombre.isNotEmpty && 'AEIOU'.contains(nombre[0].toUpperCase());
    }).toList();
  }
}
