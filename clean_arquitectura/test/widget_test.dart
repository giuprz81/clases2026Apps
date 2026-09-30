import 'package:clean_arquitectura/domain/entities/usuario.dart';
import 'package:clean_arquitectura/domain/repositories/usuario_repository.dart';
import 'package:clean_arquitectura/domain/usecases/obtener_usuarios_con_vocal.dart';
import 'package:clean_arquitectura/presentation/pantalla_usuarios.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeUsuarioRepository implements UsuarioRepository {
  @override
  Future<List<Usuario>> obtener() async => const [
    Usuario(id: 1, nombre: 'Ana', email: 'ana@example.com'),
  ];
}

void main() {
  testWidgets('muestra los usuarios devueltos por el caso de uso', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: PantallaUsuarios(
        obtenerUsuariosConVocal: ObtenerUsuariosConVocal(FakeUsuarioRepository()),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Usuarios (Clean Architecture)'), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);
  });
}
