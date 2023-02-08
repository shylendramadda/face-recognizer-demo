import 'package:get/get.dart';

import '../data/remote/remote_service.dart';
import '../modules/components/progress_bar/progress_controller.dart';

class GlobalBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(ProgressController());
    Get.put(RemoteService());
  }
}
