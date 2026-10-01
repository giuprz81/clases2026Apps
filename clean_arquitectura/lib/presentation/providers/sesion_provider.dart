import 'package:flutter/foundation.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/registrar_usuario.dart';

class SesionProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final RegistrarUsuario _registrarUsuario;

  SesionProvider(this._authRepository, this._registrarUsuario)
      : idUsuario = _authRepository.obtenerIdActual();

  String? idUsuario;
  bool cargando = false;
  String? error;

  Future<void> registrar(String correo, String clave, String nombre) async {
    await _ejecutar(() async {
      await _registrarUsuario(correo, clave, nombre);
      idUsuario = _authRepository.obtenerIdActual();
    });
  }

  Future<void> ingresar(String correo, String clave) async {
    await _ejecutar(() async {
      await _authRepository.ingresar(correo, clave);
      idUsuario = _authRepository.obtenerIdActual();
    });
  }

  Future<void> salir() async {
    await _ejecutar(() async {
      await _authRepository.salir();
      idUsuario = null;
    });
  }

  Future<void> _ejecutar(Future<void> Function() operacion) async {
    cargando = true;
    error = null;
    notifyListeners();
    try {
      await operacion();
    } catch (e) {
      error = e.toString();
    } finally {
      cargando = false;
      notifyListeners();
    }
  }
}
