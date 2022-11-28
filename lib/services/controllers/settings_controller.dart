import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:portarius/services/controllers/logger_controller.dart';
import 'package:portarius/services/controllers/storage_controller.dart';

class SettingsController extends GetxController {
  RxBool isDarkMode = false.obs;
  RxBool isAuthEnabled = false.obs;
  RxBool isSslVerificationEnabled = true.obs;
  RxBool autoRefresh = true.obs;
  RxInt refreshInterval = 5.obs;

  Logger _logger = Get.find<LoggerController>().logger;

  Future<void> save() async {
    final StorageController storageController = Get.find();
    for (final String key in toJson().keys) {
      await storageController.saveSettings(key, toJson()[key]);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode.value,
      'isAuthEnabled': isAuthEnabled.value,
      'isSslVerificationEnabled': isSslVerificationEnabled.value,
      'autoRefresh': autoRefresh.value,
      'refreshInterval': refreshInterval.value,
    };
  }

  // Add data from json to the controller
  // If data is null, set defaults
  void fromJson(Map<dynamic, dynamic> json) {
    isDarkMode.value = (json['isDarkMode'] ?? Get.isPlatformDarkMode) as bool;
    isAuthEnabled.value = (json['isAuthEnabled'] ?? false) as bool;
    isSslVerificationEnabled.value =
        (json['isSslVerificationEnabled'] ?? true) as bool;
    autoRefresh.value = (json['autoRefresh'] ?? true) as bool;
    refreshInterval.value = (json['refreshInterval'] ?? 5) as int;
  }

  // ! Toggles and setters

  void toggleDarkMode() {
    _logger.d('Toggling dark mode to: ${!isDarkMode.value}');
    isDarkMode.value = !isDarkMode.value;
    Get.forceAppUpdate();
    save();
  }

  void toggleAuthEnabled() {
    _logger.d('Toggling auth enabled to: ${!isAuthEnabled.value}');
    isAuthEnabled.value = !isAuthEnabled.value;
    save();
  }

  void toggleSslVerificationEnabled() {
    _logger
        .d('Toggling SSL verification to: ${!isSslVerificationEnabled.value}');
    isSslVerificationEnabled.value = !isSslVerificationEnabled.value;
  }

  void toggleAutoRefresh() {
    _logger.d('Toggling auto refresh to: ${!autoRefresh.value}');
    autoRefresh.value = !autoRefresh.value;
    save();
  }

  void setRefreshInterval(int value) {
    _logger.d('Setting refresh interval to: $value');
    refreshInterval.value = value;
    save();
  }
}
