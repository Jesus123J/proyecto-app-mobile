class Transaccion {
  final String id;
  final String tipo;
  final double monto;
  final DateTime fecha;
  final String descripcion;

  Transaccion({
    required this.id,
    required this.tipo,
    required this.monto,
    required this.fecha,
    required this.descripcion,
  });
}
