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
  var dni = ''.obs;
  var ultimosMovimientos = <Movimiento>[].obs;
  var isLoading = false.obs;
  var saldoVisible = true.obs;

  @override
  void onInit() {
    super.onInit();
    cargarDatos().then((_) {
      // Iniciar monitoreo después de cargar los datos
      iniciarMonitoreoNotificaciones();
    });
  }

  void iniciarMonitoreoNotificaciones() {
    if (dni.value.isNotEmpty) {
      // Iniciar el monitoreo de notificaciones
      notificationService.startMonitoring(
        dni.value,
        onNuevoMovimiento: () async {
          // Cuando llega un nuevo movimiento, recargar los movimientos
          await cargarMovimientos();
          // Calcular el saldo basado en los movimientos
          await calcularSaldoDesdeMovimientos();
        },
      );
    }
  }

  void toggleSaldoVisibility() {
    saldoVisible.value = !saldoVisible.value;
  }

  Future<void> cargarDatos() async {
    final userData = storage.read('userData');

    if (userData != null) {
      nombreUsuario.value = userData['nombre'] ?? 'Usuario';
      contacto.value = userData['contacto'] ?? '';
      dni.value = userData['dni'] ?? '';

      // Parsear el saldo de forma robusta
      if (userData['saldo'] != null) {
        final saldoRaw = userData['saldo'];
        if (saldoRaw is num) {
          saldo.value = saldoRaw.toDouble();
        } else if (saldoRaw is String) {
          // Limpiar el string de símbolos de moneda
          final saldoLimpio = saldoRaw
              .replaceAll('S/', '')
              .replaceAll('S/.', '')
              .replaceAll(',', '')
              .trim();
          saldo.value = double.tryParse(saldoLimpio) ?? 0.0;
        } else {
          saldo.value = 0.0;
        }
      } else {
        saldo.value = 0.0;
      }

      print('📱 Datos cargados - Saldo inicial: ${saldo.value}');
    }

    // Cargar movimientos reales desde la API
    await cargarMovimientos();

    // Actualizar el saldo desde el servidor
    await calcularSaldoDesdeMovimientos();
  }

  Future<void> cargarMovimientos() async {
    if (dni.value.isEmpty) return;

    isLoading.value = true;

    try {
      final movimientos = await apiService.obtenerMovimientos(dni.value);

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
    return movimiento.dniDestino == dni.value;
  }

  void actualizarSaldo(double nuevoSaldo) {
    saldo.value = nuevoSaldo;
  }

  // Método para refrescar todos los datos del dashboard
  Future<void> refrescarDatos() async {
    await cargarDatos();
  }

  // Método para calcular el saldo basado en los movimientos más recientes
  Future<void> calcularSaldoDesdeMovimientos() async {
    if (dni.value.isEmpty) return;

    try {
      print('🔄 Actualizando saldo para DNI: ${dni.value}');
      print('💰 Saldo anterior: ${saldo.value}');

      // Obtener el saldo actualizado desde el API
      final nuevoSaldo = await apiService.obtenerSaldoUsuario(dni.value);

      if (nuevoSaldo != null) {
        // Asegurar que el saldo sea un double válido
        final saldoActualizado = double.parse(nuevoSaldo.toStringAsFixed(2));

        print('💰 Nuevo saldo recibido: $saldoActualizado');

        // Actualizar el saldo observable
        saldo.value = saldoActualizado;

        print('✅ Saldo actualizado correctamente a: ${saldo.value}');

        // Actualizar también en el storage
        final userData = storage.read('userData');
        if (userData != null) {
          userData['saldo'] = saldoActualizado;
          await storage.write('userData', userData);
          print('💾 Saldo guardado en storage');
        }
      } else {
        print('⚠️ No se recibió saldo del servidor');
      }
    } catch (e) {
      print('❌ Error al calcular saldo desde movimientos: $e');
    }
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
