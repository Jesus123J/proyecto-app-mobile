import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/movimiento.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';
import '../routes/app_routes.dart';

class DashboardController extends GetxController {
  final storage = GetStorage();
  final notificationService = NotificationService();
  final apiService = ApiService();

  var saldo = 0.0.obs;
  var nombreUsuario = 'Usuario'.obs;
  var contacto = ''.obs;
  var ultimosMovimientos = <Movimiento>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final userData = storage.read('userData');

    if (userData != null) {
      nombreUsuario.value = userData['nombre'] ?? 'Usuario';
      contacto.value = userData['contacto'] ?? '';
      saldo.value = userData['saldo'] != null
          ? double.tryParse(userData['saldo'].toString()) ?? 0.0
          : 0.0;
    }

    // Cargar movimientos reales desde la API
    await cargarMovimientos();
  }

  Future<void> cargarMovimientos() async {
    if (contacto.value.isEmpty) return;

    isLoading.value = true;

    try {
      final movimientos = await apiService.obtenerMovimientos(contacto.value);

      // Ordenar por fecha y tomar solo los últimos 3
      movimientos.sort((a, b) {
        try {
          final fechaA = DateTime.parse(a.fechaHora);
          final fechaB = DateTime.parse(b.fechaHora);
          return fechaB.compareTo(fechaA); // Orden descendente (más reciente primero)
        } catch (e) {
          return 0;
        }
      });

      ultimosMovimientos.value = movimientos.take(3).toList();
    } catch (e) {
      print('Error al cargar movimientos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Determinar si un movimiento es recibido o enviado
  bool esMovimientoRecibido(Movimiento movimiento) {
    return movimiento.dniDestino == contacto.value;
  }

  void actualizarSaldo(double nuevoSaldo) {
    saldo.value = nuevoSaldo;
  }

  // Método para refrescar todos los datos del dashboard
  Future<void> refrescarDatos() async {
    await cargarDatos();
  }

  void logout() {
    // Detener el monitoreo de notificaciones
    notificationService.stopMonitoring();

    // Limpiar datos de sesión
    storage.erase();

    // Navegar al login
    Get.offAllNamed(AppRoutes.login);
  }
}
