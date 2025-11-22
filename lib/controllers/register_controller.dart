import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
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
    // Limpiar espacios en blanco de los campos
    final dni = dniController.text.trim();
    final nombre = nombreController.text.trim();
    final contacto = contactoController.text.trim();
    final pin = pinController.text.trim();
    final confirmarPin = confirmarPinController.text.trim();

    // Validaciones
    if (dni.isEmpty ||
        nombre.isEmpty ||
        contacto.isEmpty ||
        pin.isEmpty ||
        confirmarPin.isEmpty) {
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
    if (dni.length != 8) {
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
    if (contacto.length != 9) {
      Get.snackbar(
        'Error',
        'El número de contacto debe tener 9 dígitos',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validar PIN (10 dígitos)
    if (pin.length != 10) {
      Get.snackbar(
        'Error',
        'El PIN debe tener 10 dígitos',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validar que los PINs coincidan
    if (pin != confirmarPin) {
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
      dni: dni,
      nombre: nombre,
      contacto: contacto,
      pin: pin,
    );

    isLoading.value = false;

    if (result['success']) {
      Get.snackbar(
        'Éxito',
        'Usuario registrado exitosamente. Tu saldo inicial es S/ 100.00',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Guardar datos del usuario en el storage para navegación automática
      final storage = GetStorage();
      await storage.write('userData', {
        'nombre': nombre,
        'contacto': contacto,
        'dni': dni,
        'saldo': 100.0,
        'pin': pin,
      });

      // Esperar 1 segundo y navegar al dashboard directamente
      await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed(AppRoutes.dashboard);
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
