class AppConstants {
  // API
  static String baseUrl = 'http://192.168.0.118:9595/api/base';
  static String imageBaseUrl = '$baseUrl/fd/image/';

  // App
  static const String appName = 'iSentinel - Face Recognition';
  static const String companyName = '3Frames';

  // Messages
  static const String settings = 'Settings';
  static const String enterURL = 'Update Base URL';
  static const String somethingWentWrong = 'Something went wrong';
  static const String uploadIssue = 'Something went wrong while uploading';
  static const String fileUploadSuccess = 'File uploaded successfully';
  static var requestFailed = 'Request failed';
  static var noCameras = 'Error in fetching the camera';
  static var oneMomentPlease = 'One moment please..';
  static const String noInternet =
      'No internet, Please check your internet and try again';

  // Shared preferences
  static const String url = 'URL';
}
