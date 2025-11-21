import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../routes/app_routes.dart';

class RegisterController extends GetxController {
  final dniController = TextEditingController();
  final nombreController = TextEditingController();
  final contactoController = TextEditingController();
  final pinController = TextEditingController();
  final confirmarPinController = TextEditingController();

  final apiService = ApiService();

  var isLoading = false.obs;
  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<void> registrar() async {
    // Validaciones
    if (dniController.text.isEmpty ||
        nombreController.text.isEmpty ||
        contactoController.text.isEmpty ||
        pinController.text.isEmpty ||
        confirmarPinController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Por favor completa todos los campos',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validar DNI (8 dígitos)
    if (dniController.text.length != 8) {
      Get.snackbar(
        'Error',
        'El DNI debe tener 8 dígitos',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validar número de contacto (9 dígitos)
    if (contactoController.text.length != 9) {
      Get.snackbar(
        'Error',
        'El número de contacto debe tener 9 dígitos',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validar PIN (4 dígitos)
    if (pinController.text.length != 4) {
      Get.snackbar(
        'Error',
        'El PIN debe tener 4 dígitos',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validar que los PINs coincidan
    if (pinController.text != confirmarPinController.text) {
      Get.snackbar(
        'Error',
        'Los PINs no coinciden',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    final result = await apiService.registrarUsuario(
      dni: dniController.text,
      nombre: nombreController.text,
      contacto: contactoController.text,
      pin: pinController.text,
    );

    isLoading.value = false;

    if (result['success']) {
      Get.snackbar(
        'Éxito',
        'Usuario registrado exitosamente. Tu saldo inicial es S/ 100.00',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      // Esperar 2 segundos y regresar al login
      await Future.delayed(const Duration(seconds: 2));
      Get.offAllNamed(AppRoutes.login);
    } else {
      Get.snackbar(
        'Error',
        result['message'] ?? 'Error al registrar usuario',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  void onClose() {
    dniController.dispose();
    nombreController.dispose();
    contactoController.dispose();
    pinController.dispose();
    confirmarPinController.dispose();
    super.onClose();
  }
}
