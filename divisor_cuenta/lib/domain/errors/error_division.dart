enum ErrorDivision {
  montoInvalido('Monto invalido'),
  montoNegativo('El monto no puede ser negativo'),
  personasInsuficientes('Debe haber al menos una persona'),
  personasNoEnteras('El número de personas debe ser un entero'),
  propinaInvalida('Propina invalida'),
  propinaFueraDeRango('La propina debe estar entre 0 y 100');

  const ErrorDivision(this.mensaje);

  final String mensaje;
}
