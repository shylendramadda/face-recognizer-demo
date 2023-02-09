import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fr_demo/data/local/preference_utils.dart';
import 'package:fr_demo/data/models/file_data.dart';
import 'package:fr_demo/data/models/face_detection.dart';
import 'package:fr_demo/modules/home/home_controller.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pfile_picker/pfile_picker.dart';
import 'package:toast/toast.dart';

import '../../config/routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_utils.dart';
import '../components/progress_bar/progress_view.dart';

List<CameraDescription> cameras = [];

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeController homeController = Get.find();
  List<FileData> fileDataList = [];
  List<String> videoTypeStrings = [];
  List<FaceDetection>? faceDetections = [];
  DateTime currentBackPressTime = DateTime.now();
  String selectedVideoType = 'Other';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getCameras();
      loadData();
    });
  }

  void loadData() {
    final url = PreferenceUtils.getString(AppConstants.url);
    if (url != null && url.isNotEmpty) {
      AppConstants.baseUrl = url;
    }
    if (!kIsWeb) {
      getLocalData();
    }
    getServerData();
    // getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => loadData(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Get.toNamed(Routes.settings),
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: onWillPop,
        child: Stack(
          children: [
            fileDataList.isNotEmpty
                ? _buildListItems()
                : const Center(child: Text('No data')),
            const ProgressView(),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        children: [
          SpeedDialChild(
              child: const Icon(Icons.browse_gallery_outlined),
              label: 'Gallery',
              backgroundColor: AppColors.primary,
              onTap: () => pickFiles()),
          SpeedDialChild(
              child: const Icon(Icons.camera_outlined),
              label: 'Camera',
              backgroundColor: AppColors.primary,
              onTap: () => Get.toNamed(Routes.camera)),
        ],
      ),
    );
  }

  Widget _buildListItems() {
    return ListView.separated(
      itemCount: fileDataList.length,
      itemBuilder: (context, index) {
        var fileData = fileDataList[index];
        String filePath = '';
        final name = fileData.name ?? '';
        if (name.isNotEmpty && name.contains(':')) {
          final names = name.split(":");
          filePath = names.last;
        }
        return InkWell(
          onTap: () => onFileTap(filePath, name),
          child: listItem(fileData),
        );
      },
      separatorBuilder: (_, __) =>
          const Divider(color: AppColors.grey, height: 4),
    );
  }

  Container listItem(FileData fileData) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          filePreviewImage(fileData),
          const SizedBox(width: 16),
          fileContent(fileData),
        ],
      ),
    );
  }

  Expanded fileContent(FileData fileData) {
    String filePath = fileData.filePath ?? '';
    String fileName = filePath.split('/').last;
    String name = fileData.name ?? '';
    String score = '';
    bool isFromServer = name.isNotEmpty;
    if (isFromServer) {
      final names = fileData.name!.split(':');
      name = names[0];
      score = names[1];
    }
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          fileName.isNotEmpty
              ? Text(
                  fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                )
              : const SizedBox(),
          FutureBuilder(
            future: AppUtils.getFileSize(filePath, 2),
            builder: (BuildContext context, snapshot) {
              return snapshot.data != null
                  ? Text(snapshot.data.toString())
                  : Container();
            },
          ),
          const SizedBox(height: 10),
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            fileData.dateTime ?? 'No Time',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          score.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.all(20),
                  child: TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(getScoreColor(score))),
                    onPressed: _doNothing(),
                    child: Text(
                      score,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
              : Container(),
          Row(
            children: [
              !isFromServer
                  ? GestureDetector(
                      child: const Icon(Icons.upload_file),
                      onTap: () => startUpload(filePath),
                    ) //_showVideoTypeDialog(filePath, context))
                  : Container(),
              const SizedBox(width: 80),
              !isFromServer
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          child: const Icon(Icons.delete),
                          onTap: () => showDeleteAlert(context, filePath),
                        )
                      ],
                    )
                  : Container()
            ],
          ),
        ],
      ),
    );
  }

  Container filePreviewImage(FileData fileData) {
    bool isVideo = false;
    bool isNetworkImage = false;
    final name = fileData.name ?? '';
    String filePath = fileData.filePath ?? '';
    // if server image
    if (name.isNotEmpty && name.contains(':')) {
      final names = name.split(":");
      filePath = AppConstants.imageBaseUrl + names.last;
      isNetworkImage = true;
    }

    if (filePath.isNotEmpty) {
      isVideo = filePath.endsWith('.mp4');
      // if (isVideo) {
      // } else {
      //   isNetworkImage = AppUtils.isNetworkFile(filePath);
      // }
    }

    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
      ),
      child: filePath.isNotEmpty
          ? !isVideo
              ? isNetworkImage
                  ? CachedNetworkImage(
                      imageUrl: filePath,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      // ignore: prefer_const_literals_to_create_immutables
                      httpHeaders: {
                        "tenantUid": "test",
                        "tuid": "test",
                        "Authorization": "Basic YWRtaW46YWRtaW4="
                      },
                    )
                  : Image.file(File(filePath))
              : Image.asset(
                  'assets/images/video_preview.png',
                  width: 300,
                  height: 200,
                )
          : Image.asset(
              'assets/images/person_preview.png',
              width: 300,
              height: 200,
            ),
    );
  }

  Future<void> getCameras() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      cameras = await availableCameras();
      debugPrint('Cameras ---> $cameras');
    } on CameraException catch (e) {
      AppUtils.showToast(AppConstants.noCameras);
      debugPrint('Error in fetching the cameras: $e');
    }
  }

  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg' 'png', 'mp4'],
        allowMultiple: true,
        allowCompression: true);
    try {
      if (result != null && result.files.isNotEmpty) {
        List<File> fileList = result.paths.map((path) => File(path!)).toList();
        for (File file in fileList) {
          var filePath = file.path.toString();
          if (AppUtils.isSupportedFormat(filePath)) {
            debugPrint('Path: ${file.path}');
            final fileData = FileData();
            fileData.filePath = file.path.toString();
            fileDataList.insert(0, fileData);
          }
        }
        setState(() {});
      } else {
        // User canceled the picker
      }
    } catch (e) {
      e.printError();
      AppUtils.showToast(AppConstants.somethingWentWrong + e.toString());
    }
  }

  getLocalData() async {
    final directory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> fileList = await directory.list().toList();
    fileDataList.clear();

    for (var file in fileList) {
      var filePath = file.path.toString();
      if (AppUtils.isSupportedFormat(filePath)) {
        final fileData = FileData();
        fileData.filePath = filePath;
        fileDataList.add(fileData);
      }
    }
    setState(() {});
  }

  getServerData() async {
    faceDetections = [];
    fileDataList.clear();
    // final isExists = await AppUtils.isNetworkAvailable();
    // if (!isExists) {
    //   AppUtils.showToast(AppConstants.noInternet);
    //   return null;
    // }
    faceDetections = await homeController.getServerData();
    if (faceDetections != null && faceDetections!.isNotEmpty) {
      for (FaceDetection fd in faceDetections!) {
        final fileData = FileData();
        fileData.filePath = fd.filePath;
        fileData.name = fd.name;
        fileData.dateTime = AppUtils.getDate(fd.faceDetectedOn ?? 0);
        fileDataList.add(fileData);
      }
      setState(() {});
    }
  }

  onFileTap(String filePath, String name) {
    Get.toNamed(Routes.preview, arguments: {
      "filePath": filePath,
      "name": name,
    });
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (now.difference(currentBackPressTime) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      AppUtils.showSnackBarMessage(
          context, 'Press BACK again to exit from the app');
      return Future.value(false);
    }
    return Future.value(true);
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    AppUtils.position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<String> getAddress(double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    return placemarks.first.administrativeArea ?? "";
  }

  deleteLocalFile(String filePath) async {
    try {
      final file = File(filePath);
      await file.delete();
      final oldFile =
          fileDataList.firstWhere((element) => element.filePath == filePath);
      fileDataList.remove(oldFile);
      setState(() {
        AppUtils.showToast("File is deleted");
      });
    } catch (e) {
      e.printError();
    }
  }

  showDeleteAlert(BuildContext context, String filePath) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        deleteLocalFile(filePath);
        Get.back();
      },
    );
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Get.back();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text('Delete Alert'),
      content: const Text('Are you sure want to delete this file?'),
      actions: [cancelButton, okButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> startUpload(String filePath) async {
    final isSuccess =
        await homeController.uploadFile(filePath, AppUtils.position);
    if (isSuccess) {
      deleteLocalFile(filePath);
      loadData();
    }
  }

  _doNothing() {}

  Color? getScoreColor(String score) {
    if (score == 'high') {
      return Colors.green;
    } else if (score == 'medium') {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}
