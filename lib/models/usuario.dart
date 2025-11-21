class Usuario {
  final String contacto;
  final String nombre;
  final String? email;
  final double? saldo;
  final String? numeroTarjeta;
  final String? ccv;
  final String? fechaVencimiento;
  final String? pin;

  Usuario({
    required this.contacto,
    required this.nombre,
    this.email,
    this.saldo,
    this.numeroTarjeta,
    this.ccv,
    this.fechaVencimiento,
    this.pin,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      contacto: json['contacto']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      email: json['email']?.toString(),
      saldo: json['saldo'] != null ? double.tryParse(json['saldo'].toString()) : null,
      numeroTarjeta: json['numeroTarjeta']?.toString(),
      ccv: json['ccv']?.toString(),
      fechaVencimiento: json['fechaVencimiento']?.toString(),
      pin: json['pin']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contacto': contacto,
      'nombre': nombre,
      'email': email,
      'saldo': saldo,
      'numeroTarjeta': numeroTarjeta,
      'ccv': ccv,
      'fechaVencimiento': fechaVencimiento,
      'pin': pin,
    };
  }
}
