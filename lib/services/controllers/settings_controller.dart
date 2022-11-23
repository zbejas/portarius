import 'package:get/get.dart';
import 'package:portarius/services/controllers/storage_controller.dart';

class SettingsController extends GetxController {
  RxBool isDarkMode = false.obs;
  RxBool isAuthEnabled = false.obs;
  RxBool isSslVerificationEnabled = true.obs;
  RxBool autoRefresh = true.obs;
  RxBool isLoggingEnabled = false.obs;
  RxInt refreshInterval = 5.obs;

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
      'isLoggingEnabled': isLoggingEnabled.value,
      'refreshInterval': refreshInterval.value,
    };
  }

  // Add data from json to the controller
  // If data is null, set defaults
  void fromJson(Map<dynamic, dynamic> json) {
    isDarkMode.value = (json['isDarkMode'] ?? false) as bool;
    isAuthEnabled.value = (json['isAuthEnabled'] ?? false) as bool;
    isSslVerificationEnabled.value =
        (json['isSslVerificationEnabled'] ?? true) as bool;
    autoRefresh.value = (json['autoRefresh'] ?? true) as bool;
    isLoggingEnabled.value = (json['isLoggingEnabled'] ?? false) as bool;
    refreshInterval.value = (json['refreshInterval'] ?? 5) as int;
  }

  // ! Toggles and setters

  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
    save();
  }

  void toggleAuthEnabled() {
    isAuthEnabled.value = !isAuthEnabled.value;
    save();
  }

  void toggleSslVerificationEnabled() {
    isSslVerificationEnabled.value = !isSslVerificationEnabled.value;
  }

  void toggleAutoRefresh() {
    autoRefresh.value = !autoRefresh.value;
    save();
  }

  void toggleLoggingEnabled() {
    isLoggingEnabled.value = !isLoggingEnabled.value;
    save();
  }

  void setRefreshInterval(int value) {
    refreshInterval.value = value;
    save();
  }
}
