import 'package:flutter/material.dart';

import 'domain/use_cases/calcular_division.dart';
import 'data/strategies/redondeo_exacto.dart';
import 'data/strategies/redondeo_hacia_arriba.dart';
import 'presentation/pages/divisor_cuenta_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final CalcularDivision _calcularDivision = CalcularDivision();
  final RedondeoExacto _redondeoExacto = const RedondeoExacto();
  final RedondeoHaciaArriba _redondeoHaciaArriba =
      const RedondeoHaciaArriba();

  @override
  Widget build(BuildContext context) {
    const colorPrincipal = Color(0xFF17365D);

    return MaterialApp(
      title: 'Divisor de cuenta',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: colorPrincipal),
        appBarTheme: const AppBarTheme(
          backgroundColor: colorPrincipal,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF7F9FC),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: colorPrincipal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      home: DivisorCuentaPage(
        calcularDivision: _calcularDivision,
        redondeoExacto: _redondeoExacto,
        redondeoHaciaArriba: _redondeoHaciaArriba,
      ),
    );
  }
}
