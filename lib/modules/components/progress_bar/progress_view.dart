import 'package:flutter/material.dart';
import 'package:fr_demo/modules/components/progress_bar/progress_controller.dart';
import 'package:get/get.dart';

import '../../../utils/app_colors.dart';

class ProgressView extends StatefulWidget {
  const ProgressView({Key? key}) : super(key: key);

  @override
  State<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView> {
  late ProgressController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Visibility(
        visible: controller.isLoading(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.transparent,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
