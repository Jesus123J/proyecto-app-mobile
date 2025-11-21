import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/historial_controller.dart';

class HistorialView extends GetView<HistorialController> {
  const HistorialView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Movimientos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.cargarMovimientos(),
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(
            () => Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildFilterChip(
                      context,
                      'Todos',
                      controller.filtroSeleccionado.value == 'Todos',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterChip(
                      context,
                      'Recibidos',
                      controller.filtroSeleccionado.value == 'Recibidos',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterChip(
                      context,
                      'Enviados',
                      controller.filtroSeleccionado.value == 'Enviados',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (controller.movimientosFiltrados.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay movimientos',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.cargarMovimientos(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.movimientosFiltrados.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final movimiento = controller.movimientosFiltrados[index];
                      final esRecibido = controller.esMovimientoRecibido(movimiento);
                      final tipo = esRecibido ? 'Recibido' : 'Enviado';

                      // Parsear la fecha
                      DateTime? fecha;
                      try {
                        fecha = DateTime.parse(movimiento.fechaHora);
                      } catch (e) {
                        fecha = DateTime.now();
                      }

                      return Card(
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: esRecibido
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Icon(
                              esRecibido
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: esRecibido ? Colors.green : Colors.orange,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            movimiento.mensaje.isNotEmpty
                                ? movimiento.mensaje
                                : tipo,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                tipo,
                                style: TextStyle(
                                  color: esRecibido ? Colors.green : Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                esRecibido
                                    ? 'De: ${movimiento.dniOrigen}'
                                    : 'Para: ${movimiento.dniDestino}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('dd/MM/yyyy HH:mm').format(fecha),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Código: ${movimiento.codigoTransferencia}',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 10,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                          trailing: Text(
                            '${esRecibido ? '+' : '-'}S/ ${movimiento.monto.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: esRecibido ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Obx(
            () => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total de movimientos:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${controller.movimientosFiltrados.length}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          controller.cambiarFiltro(label);
        }
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }
}
