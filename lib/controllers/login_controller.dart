import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class LoginController extends GetxController {
  final contactoController = TextEditingController();
  final pinController = TextEditingController();
  final storage = GetStorage();
  final apiService = ApiService();
  final notificationService = NotificationService();

  var isLoading = false.obs;
  var obscurePassword = true.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    if (contactoController.text.isEmpty || pinController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Por favor ingresa tu número de celular y PIN',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    final result = await apiService.login(
      contactoController.text,
      pinController.text,
    );

    isLoading.value = false;

    if (result['success']) {
      final userData = result['data'];

      await storage.write('contacto', contactoController.text);
      await storage.write('pin', pinController.text);
      await storage.write('nombre', userData['nombre'] ?? 'Usuario');
      await storage.write('userData', userData);

      // Solicitar permisos de notificación
      await notificationService.requestPermissions();

      // Iniciar monitoreo de transferencias
      await notificationService.startMonitoring(contactoController.text);

      Get.snackbar(
        'Bienvenido',
        'Inicio de sesión exitoso',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      Get.snackbar(
        'Error',
        result['message'] ?? 'Error al iniciar sesión',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  void onClose() {
    contactoController.dispose();
    pinController.dispose();
    super.onClose();
  }
}
