import 'package:flutter/material.dart';
import 'package:fr_demo/utils/app_colors.dart';
import 'package:fr_demo/utils/app_constants.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:toast/toast.dart';

import 'config/global_bindings.dart';
import 'config/globals.dart';
import 'config/pages.dart';
import 'config/routes.dart';

class FaceRecognizer extends StatelessWidget {
  const FaceRecognizer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.noTransition,
      title: AppConstants.appName,
      theme: ThemeData(primarySwatch: AppColors.primary),
      initialRoute: Routes.initial,
      unknownRoute: Pages.notFound,
      getPages: Pages.routes,
      navigatorKey: Globals.materialKey,
      initialBinding: GlobalBindings(),
    );
  }
}
