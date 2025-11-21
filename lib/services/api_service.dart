import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import '../models/movimiento.dart';
import '../models/wallet.dart';

class ApiService {
  static const String baseUrl = 'https://api.clinicagovision.com/api';

  Future<Map<String, dynamic>> registrarUsuario({
    required String dni,
    required String nombre,
    required String contacto,
    required String pin,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/usuarios');

      final body = {
        'dni': dni,
        'nombre': nombre,
        'contacto': contacto,
        'pin': pin,
        'saldo': 100.0,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Usuario registrado exitosamente',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error al registrar usuario',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> login(String contacto, String pin) async {
    try {
      final url = Uri.parse('$baseUrl/auth/login/contacto/$contacto/$pin');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Credenciales incorrectas',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> transferir({
    required String origen,
    required String destino,
    required double monto,
    required String mensaje,
    required String pin,
    required String topAppName,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/externo/transferir');

      final body = {
        'origen': origen,
        'destino': destino,
        'monto': monto,
        'mensaje': mensaje,
        'pin': pin,
        'topAppName': topAppName,
      };

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-API-Token': 'sk_yata_b7c8d9e0f1g2h3i4',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Transferencia exitosa',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? errorData,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  Future<List<Usuario>> obtenerUsuariosDisponibles() async {
    try {
      final url = Uri.parse('$baseUrl/externo/transferir');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Usuario.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<Movimiento>> obtenerMovimientos(String numerocelular) async {
    try {
      final url = Uri.parse('$baseUrl/usuarios/movimientos/$numerocelular');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Movimiento.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<WalletResponse?> consultarWallets(String numeroCelular) async {
    try {
      final url = Uri.parse('$baseUrl/externo/wallets/$numeroCelular');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WalletResponse.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
