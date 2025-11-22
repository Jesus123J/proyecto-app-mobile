import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/movimiento.dart';
import '../services/api_service.dart';

class HistorialController extends GetxController {
  final storage = GetStorage();
  final apiService = ApiService();

  var movimientos = <Movimiento>[].obs;
  var isLoading = false.obs;
  var filtroSeleccionado = 'Todos'.obs;

  @override
  void onInit() {
    super.onInit();
    cargarMovimientos();
  }

  Future<void> cargarMovimientos() async {
    isLoading.value = true;

    try {
      final userData = storage.read('userData');
      final dni = userData != null ? userData['dni'] ?? '' : '';

      if (dni.isEmpty) {
        isLoading.value = false;
        return;
      }

      final movimientosData = await apiService.obtenerMovimientos(dni);
      movimientos.value = movimientosData;
    } catch (e) {
      print('Error al cargar movimientos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<Movimiento> get movimientosFiltrados {
    final userData = storage.read('userData');
    final dni = userData != null ? userData['dni'] ?? '' : '';

    if (filtroSeleccionado.value == 'Todos') {
      return movimientos;
    } else if (filtroSeleccionado.value == 'Recibidos') {
      return movimientos.where((m) => m.dniDestino == dni).toList();
    } else {
      // Enviados
      return movimientos.where((m) => m.dniOrigen == dni).toList();
    }
  }

  void cambiarFiltro(String filtro) {
    filtroSeleccionado.value = filtro;
  }

  // Determinar si un movimiento es recibido o enviado
  bool esMovimientoRecibido(Movimiento movimiento) {
    final userData = storage.read('userData');
    final dni = userData != null ? userData['dni'] ?? '' : '';
    return movimiento.dniDestino == dni;
  }
}
