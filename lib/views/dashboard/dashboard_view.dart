import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/dashboard_controller.dart';
import '../../routes/app_routes.dart';
import '../enviar/enviar_view.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yata Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              controller.logout();
            },
          ),
        ],
      ),
      body: Obx(
        () => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, ${controller.nombreUsuario.value}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Saldo disponible',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            controller.saldoVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white70,
                            size: 20,
                          ),
                          onPressed: controller.toggleSaldoVisibility,
                          tooltip: controller.saldoVisible.value
                              ? 'Ocultar saldo'
                              : 'Mostrar saldo',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.saldoVisible.value
                          ? 'S/ ${controller.saldo.value.toStringAsFixed(2)}'
                          : 'S/ ••••••',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context,
                        icon: Icons.arrow_upward,
                        label: 'Enviar',
                        onTap: () {
                          Get.to(() => EnviarView(
                                dniOrigen: controller.dni.value,
                                nombreUsuario: controller.nombreUsuario.value,
                              ));
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        context,
                        icon: Icons.person,
                        label: 'Mi Perfil',
                        onTap: () {
                          _mostrarDatosUsuario(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        context,
                        icon: Icons.history,
                        label: 'Historial',
                        onTap: () {
                          Get.toNamed(AppRoutes.historial);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Últimos movimientos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.historial);
                      },
                      child: const Text('Ver todos'),
                    ),
                  ],
                ),
              ),
              if (controller.isLoading.value)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (controller.ultimosMovimientos.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text('No hay movimientos'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.ultimosMovimientos.length,
                  itemBuilder: (context, index) {
                    final movimiento = controller.ultimosMovimientos[index];
                    final esRecibido = controller.esMovimientoRecibido(movimiento);
                    final tipo = esRecibido ? 'Recibido' : 'Enviado';

                    // Parsear la fecha
                    DateTime? fecha;
                    try {
                      fecha = DateTime.parse(movimiento.fechaHora);
                    } catch (e) {
                      fecha = DateTime.now();
                    }

                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: esRecibido
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          esRecibido
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: esRecibido ? Colors.green : Colors.orange,
                        ),
                      ),
                      title: Text(
                        movimiento.mensaje.isNotEmpty
                            ? movimiento.mensaje
                            : tipo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(fecha),
                      ),
                      trailing: Text(
                        'S/ ${movimiento.monto.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: esRecibido ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDatosUsuario(BuildContext context) {
    final userData = controller.storage.read('userData');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mis Datos',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Avatar y nombre
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    controller.nombreUsuario.value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Información del usuario
            _buildInfoItem(
              context,
              icon: Icons.badge,
              label: 'DNI',
              value: userData?['dni']?.toString() ?? 'No disponible',
            ),
            const Divider(height: 24),

            _buildInfoItem(
              context,
              icon: Icons.person_outline,
              label: 'Nombre Completo',
              value: userData?['nombre']?.toString() ?? 'No disponible',
            ),
            const Divider(height: 24),

            _buildInfoItem(
              context,
              icon: Icons.phone,
              label: 'Número de Celular',
              value: userData?['contacto']?.toString() ?? 'No disponible',
            ),
            const Divider(height: 24),

            _buildInfoItem(
              context,
              icon: Icons.account_balance_wallet,
              label: 'Saldo Actual',
              value: 'S/ ${controller.saldo.value.toStringAsFixed(2)}',
              valueColor: Colors.green,
            ),
            const Divider(height: 24),

            _buildInfoItem(
              context,
              icon: Icons.email,
              label: 'Correo Electrónico',
              value: userData?['email']?.toString() ?? 'No registrado',
            ),

            const SizedBox(height: 32),

            // Botón de cerrar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cerrar'),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: valueColor,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
