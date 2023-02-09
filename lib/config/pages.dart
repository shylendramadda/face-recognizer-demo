import 'package:fr_demo/config/routes.dart';
import 'package:fr_demo/modules/settings/settings_screen.dart';
import 'package:fr_demo/modules/splash/splash_screen.dart';
import 'package:get/get.dart';

import '../modules/camera/camera_screen.dart';
import '../modules/home/home_controller.dart';
import '../modules/home/home_screen.dart';
import '../modules/preview/preview_screen.dart';

class Pages {
  static final notFound = GetPage(
    name: Routes.notFound,
    page: () => const SplashScreen(),
  );

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController());
      }),
    ),
    GetPage(
      name: Routes.camera,
      page: () => const CameraScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController());
      }),
    ),
    GetPage(
      name: Routes.preview,
      page: () => const PreviewScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController());
      }),
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsScreen(),
    ),
  ];
}
