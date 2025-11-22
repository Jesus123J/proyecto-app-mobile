import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/wallet.dart';
import '../services/api_service.dart';
import 'dashboard_controller.dart';

class EnviarController extends GetxController {
  final ApiService _apiService = ApiService();
  final storage = GetStorage();

  final numeroDestinoController = TextEditingController();
  final montoController = TextEditingController();
  final mensajeController = TextEditingController();
  final pinController = TextEditingController();

  var isLoadingWallets = false.obs;
  var walletResponse = Rxn<WalletResponse>();
  var selectedWallet = Rxn<WalletDisponible>();
  var isTransferring = false.obs;

  @override
  void onClose() {
    numeroDestinoController.dispose();
    montoController.dispose();
    mensajeController.dispose();
    pinController.dispose();
    super.onClose();
  }

  Future<void> consultarWalletsDisponibles() async {
    final numeroDestino = numeroDestinoController.text.trim();

    if (numeroDestino.isEmpty || numeroDestino.length < 9) {
      walletResponse.value = null;
      selectedWallet.value = null;
      return;
    }

    isLoadingWallets.value = true;

    try {
      final response = await _apiService.consultarWallets(numeroDestino);
      walletResponse.value = response;

      if (response != null && response.found && response.walletsDisponibles.isNotEmpty) {
        // Auto-seleccionar YaTa si está disponible
        final yataWallet = response.walletsDisponibles.firstWhereOrNull(
          (w) => w.appName.toLowerCase() == 'yata'
        );
        selectedWallet.value = yataWallet ?? response.walletsDisponibles.first;
      } else {
        selectedWallet.value = null;
        if (response != null && !response.found) {
          Get.snackbar(
            'Usuario no encontrado',
            'El número ingresado no tiene billeteras disponibles',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo consultar las billeteras: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingWallets.value = false;
    }
  }

  Future<void> realizarTransferencia(String dniOrigen) async {
    if (!_validarFormulario()) return;

    print('🚀 ========== INICIANDO PROCESO DE TRANSFERENCIA ==========');
    print('👤 DNI Origen: $dniOrigen');
    print('📞 Número Destino: ${numeroDestinoController.text.trim()}');
    print('💰 Monto: ${montoController.text}');
    print('📱 App destino: ${selectedWallet.value?.appName ?? 'YaTa'}');

    isTransferring.value = true;

    try {
      final resultado = await _apiService.transferir(
        origen: dniOrigen,
        destino: numeroDestinoController.text.trim(),
        monto: double.parse(montoController.text),
        mensaje: mensajeController.text.trim(),
        pin: pinController.text.trim(),
        topAppName: selectedWallet.value?.appName ?? 'YaTa',
      );

      print('📊 Resultado recibido: $resultado');

      if (resultado['success']) {
        print('✅ Transferencia exitosa!');

        // Actualizar el saldo después de la transferencia exitosa
        await _actualizarSaldo(double.parse(montoController.text));

        // Refrescar los datos del dashboard (incluyendo movimientos)
        try {
          final dashboardController = Get.find<DashboardController>();
          await dashboardController.refrescarDatos();
        } catch (e) {
          print('Error al refrescar dashboard: $e');
        }

        // Mostrar diálogo de éxito
        Get.dialog(
          Builder(
            builder: (BuildContext dialogContext) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 64,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '¡Transferencia exitosa!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Se envió S/ ${montoController.text} correctamente',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(); // Cerrar diálogo
                            Get.back(); // Volver al dashboard
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Aceptar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          barrierDismissible: false,
        );
      } else {
        print('❌ Error en la transferencia: ${resultado['message']}');

        // Mostrar diálogo de error
        Get.dialog(
          Builder(
            builder: (BuildContext dialogContext) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 64,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Error al enviar',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        resultado['message'] ?? 'No se pudo realizar la transferencia',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(); // Cerrar diálogo
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Entendido',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          barrierDismissible: false,
        );
      }
    } catch (e) {
      print('❌ Excepción al realizar transferencia: $e');

      // Mostrar diálogo de error por excepción
      Get.dialog(
        Builder(
          builder: (BuildContext dialogContext) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Error de conexión',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No se pudo conectar con el servidor. Por favor verifica tu conexión a internet.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(); // Cerrar diálogo
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cerrar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        barrierDismissible: false,
      );
    } finally {
      isTransferring.value = false;
    }
  }

  Future<void> _actualizarSaldo(double montoTransferido) async {
    try {
      // Obtener datos del usuario desde el storage
      final userData = storage.read('userData');
      if (userData != null) {
        // Obtener el saldo actual
        final saldoActual = userData['saldo'] != null
            ? double.tryParse(userData['saldo'].toString()) ?? 0.0
            : 0.0;

        // Calcular el nuevo saldo
        final nuevoSaldo = saldoActual - montoTransferido;

        // Actualizar el saldo en userData
        userData['saldo'] = nuevoSaldo;

        // Guardar en el storage
        await storage.write('userData', userData);

        // Actualizar el saldo en el DashboardController si está disponible
        try {
          final dashboardController = Get.find<DashboardController>();
          dashboardController.actualizarSaldo(nuevoSaldo);
        } catch (e) {
          // Si no se encuentra el controller, no pasa nada
          print('DashboardController no encontrado: $e');
        }
      }
    } catch (e) {
      print('Error al actualizar saldo: $e');
    }
  }

  bool _validarFormulario() {
    if (numeroDestinoController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Ingrese el número de destino',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    if (selectedWallet.value == null) {
      Get.snackbar('Error', 'No hay billeteras disponibles para este número',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    if (montoController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Ingrese el monto',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    final monto = double.tryParse(montoController.text);
    if (monto == null || monto <= 0) {
      Get.snackbar('Error', 'Ingrese un monto válido',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    // Validar que el usuario tenga saldo suficiente
    final userData = storage.read('userData');
    if (userData != null) {
      final saldoActual = userData['saldo'] != null
          ? double.tryParse(userData['saldo'].toString()) ?? 0.0
          : 0.0;

      if (monto > saldoActual) {
        Get.snackbar(
          'Saldo insuficiente',
          'Tu saldo actual es S/ ${saldoActual.toStringAsFixed(2)}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    }

    if (pinController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Ingrese su PIN',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    return true;
  }
}
