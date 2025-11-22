import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Verificar si hay una sesión activa
  String _getInitialRoute() {
    final storage = GetStorage();
    final userData = storage.read('userData');

    // Si hay userData guardado, ir al dashboard
    if (userData != null) {
      print('✅ Sesión encontrada - Redirigiendo al dashboard');
      return AppRoutes.dashboard;
    }

    // Si no hay sesión, ir al login
    print('❌ No hay sesión - Mostrando login');
    return AppRoutes.login;
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Yata',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      initialRoute: _getInitialRoute(),
      getPages: AppPages.routes,
    );
  }
}
