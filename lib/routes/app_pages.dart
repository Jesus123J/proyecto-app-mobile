import 'package:get/get.dart';
import '../views/login/login_view.dart';
import '../views/register/register_view.dart';
import '../views/dashboard/dashboard_view.dart';
import '../views/historial/historial_view.dart';
import '../controllers/login_controller.dart';
import '../controllers/register_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/historial_controller.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.login;

  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LoginController>(() => LoginController());
      }),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<RegisterController>(() => RegisterController());
      }),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DashboardController>(() => DashboardController());
      }),
    ),
    GetPage(
      name: AppRoutes.historial,
      page: () => const HistorialView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HistorialController>(() => HistorialController());
      }),
    ),
  ];
}
