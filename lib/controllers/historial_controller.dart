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
      final contacto = storage.read('contacto') ?? '';

      if (contacto.isEmpty) {
        isLoading.value = false;
        return;
      }

      final movimientosData = await apiService.obtenerMovimientos(contacto);
      movimientos.value = movimientosData;
    } catch (e) {
      print('Error al cargar movimientos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<Movimiento> get movimientosFiltrados {
    final contacto = storage.read('contacto') ?? '';

    if (filtroSeleccionado.value == 'Todos') {
      return movimientos;
    } else if (filtroSeleccionado.value == 'Recibidos') {
      return movimientos.where((m) => m.dniDestino == contacto).toList();
    } else {
      // Enviados
      return movimientos.where((m) => m.dniOrigen == contacto).toList();
    }
  }

  void cambiarFiltro(String filtro) {
    filtroSeleccionado.value = filtro;
  }

  // Determinar si un movimiento es recibido o enviado
  bool esMovimientoRecibido(Movimiento movimiento) {
    final contacto = storage.read('contacto') ?? '';
    return movimiento.dniDestino == contacto;
  }
}
