import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'api_service.dart';
import '../models/movimiento.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final ApiService _apiService = ApiService();
  final GetStorage _storage = GetStorage();

  Timer? _pollingTimer;
  String? _lastMovementId;
  bool _isInitialized = false;

  // Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  // Cuando el usuario toca la notificación
  void _onNotificationTapped(NotificationResponse response) {
    // Aquí puedes navegar a la pantalla de movimientos si lo deseas
    print('Notificación tocada: ${response.payload}');
  }

  // Iniciar el monitoreo de transferencias
  Future<void> startMonitoring(String numerocelular) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Detener monitoreo previo si existe
    stopMonitoring();

    // Obtener el último movimiento conocido
    final movimientos = await _apiService.obtenerMovimientos(numerocelular);
    if (movimientos.isNotEmpty) {
      _lastMovementId = movimientos.first.id;
    }

    // Iniciar el timer que consulta cada 5 segundos
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _checkForNewTransfers(numerocelular);
    });

    print('Monitoreo de transferencias iniciado');
  }

  // Detener el monitoreo
  void stopMonitoring() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _lastMovementId = null;
    print('Monitoreo de transferencias detenido');
  }

  // Verificar si hay nuevas transferencias
  Future<void> _checkForNewTransfers(String numerocelular) async {
    try {
      final movimientos = await _apiService.obtenerMovimientos(numerocelular);

      if (movimientos.isEmpty) return;

      // Obtener el movimiento más reciente
      final latestMovement = movimientos.first;

      // Si es un nuevo movimiento y el usuario es el destinatario
      if (_lastMovementId != null && latestMovement.id != _lastMovementId) {
        // Verificar si el usuario es el destinatario (recibió dinero)
        if (latestMovement.dniDestino == numerocelular ||
            latestMovement.contacto == numerocelular) {

          // Mostrar notificación
          await _showTransferNotification(latestMovement);

          // Actualizar el último movimiento conocido
          _lastMovementId = latestMovement.id;
        } else {
          // Si no es destinatario, solo actualizar el último ID
          _lastMovementId = latestMovement.id;
        }
      }
    } catch (e) {
      print('Error al verificar transferencias: $e');
    }
  }

  // Mostrar notificación de transferencia recibida
  Future<void> _showTransferNotification(Movimiento movimiento) async {
    const androidDetails = AndroidNotificationDetails(
      'transfers_channel',
      'Transferencias',
      channelDescription: 'Notificaciones de transferencias recibidas',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final montoFormateado = movimiento.monto.toStringAsFixed(2);
    final titulo = '¡Ya te llegó el dinero!';
    final mensaje = 'Recibiste S/ $montoFormateado\n${movimiento.mensaje}';

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      titulo,
      mensaje,
      notificationDetails,
      payload: movimiento.id,
    );

    print('Notificación mostrada: $titulo - $mensaje');
  }

  // Verificar si el monitoreo está activo
  bool get isMonitoring => _pollingTimer != null && _pollingTimer!.isActive;

  // Método para solicitar permisos (Android 13+)
  Future<bool> requestPermissions() async {
    if (!_isInitialized) {
      await initialize();
    }

    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final granted = await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }

    return true;
  }
}
