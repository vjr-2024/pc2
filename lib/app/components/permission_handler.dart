import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  static Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (status.isGranted) {
      // Permission is already granted
      return true;
    } else if (status.isDenied || status.isLimited || status.isRestricted) {
      // Request permission
      status = await Permission.storage.request();
      return status.isGranted;
    } else if (status.isPermanentlyDenied) {
      // Open app settings to manually grant permission
      await openAppSettings();
      return false;
    }
    return false;
  }
}
