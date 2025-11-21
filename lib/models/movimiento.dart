class Movimiento {
  final String id;
  final String dniOrigen;
  final String dniDestino;
  final double monto;
  final String mensaje;
  final String codigoTransferencia;
  final String fechaHora;
  final String? contacto;

  Movimiento({
    required this.id,
    required this.dniOrigen,
    required this.dniDestino,
    required this.monto,
    required this.mensaje,
    required this.codigoTransferencia,
    required this.fechaHora,
    this.contacto,
  });

  factory Movimiento.fromJson(Map<String, dynamic> json) {
    return Movimiento(
      id: json['id']?.toString() ?? '',
      dniOrigen: json['dniOrigen']?.toString() ?? '',
      dniDestino: json['dniDestino']?.toString() ?? '',
      monto: json['monto'] != null ? double.tryParse(json['monto'].toString()) ?? 0.0 : 0.0,
      mensaje: json['mensaje']?.toString() ?? '',
      codigoTransferencia: json['codigoTransferencia']?.toString() ?? '',
      fechaHora: json['fechaHora']?.toString() ?? '',
      contacto: json['contacto']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dniOrigen': dniOrigen,
      'dniDestino': dniDestino,
      'monto': monto,
      'mensaje': mensaje,
      'codigoTransferencia': codigoTransferencia,
      'fechaHora': fechaHora,
      'contacto': contacto,
    };
  }
}
