import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/enviar_controller.dart';

class EnviarView extends StatelessWidget {
  final String dniOrigen;
  final String nombreUsuario;

  const EnviarView({
    super.key,
    required this.dniOrigen,
    required this.nombreUsuario,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EnviarController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar dinero'),
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller.numeroDestinoController,
                decoration: const InputDecoration(
                  labelText: 'Número de celular destino',
                  hintText: '987654321',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  if (value.length >= 9) {
                    controller.consultarWalletsDisponibles();
                  }
                },
              ),
              const SizedBox(height: 16),
              if (controller.isLoadingWallets.value)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (!controller.isLoadingWallets.value &&
                  controller.walletResponse.value != null &&
                  controller.walletResponse.value!.found)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'Usuario encontrado',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Billeteras disponibles:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...controller.walletResponse.value!.walletsDisponibles
                          .map((wallet) {
                        final isSelected =
                            controller.selectedWallet.value?.walletUuid ==
                                wallet.walletUuid;
                        return InkWell(
                          onTap: () {
                            controller.selectedWallet.value = wallet;
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _getAppColor(wallet.appName),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.account_balance_wallet,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        wallet.userName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        wallet.appName,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.montoController,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  hintText: '0.00',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.mensajeController,
                decoration: const InputDecoration(
                  labelText: 'Mensaje (opcional)',
                  hintText: 'Escribe un mensaje',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.pinController,
                decoration: const InputDecoration(
                  labelText: 'PIN',
                  hintText: 'Ingresa tu PIN (10 dígitos)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 10,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isTransferring.value
                      ? null
                      : () {
                          controller.realizarTransferencia(dniOrigen);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isTransferring.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Enviar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAppColor(String appName) {
    switch (appName.toLowerCase()) {
      case 'yata':
        return Colors.purple;
      case 'yape':
        return Colors.deepPurple;
      case 'plin':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
