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

  Future<void> realizarTransferencia(String numeroOrigen) async {
    if (!_validarFormulario()) return;

    isTransferring.value = true;

    try {
      final resultado = await _apiService.transferir(
        origen: numeroOrigen,
        destino: numeroDestinoController.text.trim(),
        monto: double.parse(montoController.text),
        mensaje: mensajeController.text.trim(),
        pin: pinController.text.trim(),
        topAppName: selectedWallet.value?.appName ?? 'YaTa',
      );

      if (resultado['success']) {
        // Actualizar el saldo después de la transferencia exitosa
        await _actualizarSaldo(double.parse(montoController.text));

        // Refrescar los datos del dashboard (incluyendo movimientos)
        try {
          final dashboardController = Get.find<DashboardController>();
          await dashboardController.refrescarDatos();
        } catch (e) {
          print('Error al refrescar dashboard: $e');
        }

        Get.back();
        Get.snackbar(
          'Éxito',
          resultado['message'] ?? 'Transferencia realizada correctamente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Error',
          resultado['message'] ?? 'No se pudo realizar la transferencia',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al realizar la transferencia: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
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
