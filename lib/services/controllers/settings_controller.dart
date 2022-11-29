import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:portarius/services/api.dart';
import 'package:portarius/services/controllers/logger_controller.dart';
import 'package:portarius/services/controllers/storage_controller.dart';
import 'package:portarius/services/controllers/userdata_controller.dart';
import 'package:portarius/services/local_auth.dart';

class SettingsController extends GetxController {
  RxBool isDarkMode = false.obs;
  RxBool isAuthEnabled = false.obs;
  RxBool allowAutoSignedCerts = false.obs;
  RxBool autoRefresh = true.obs;
  RxInt refreshInterval = 5.obs;

  final Logger _logger = Get.find<LoggerController>().logger;

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
      'allowAutoSignedCerts': allowAutoSignedCerts.value,
      'autoRefresh': autoRefresh.value,
      'refreshInterval': refreshInterval.value,
    };
  }

  // Add data from json to the controller
  // If data is null, set defaults
  void fromJson(Map<dynamic, dynamic> json) {
    isDarkMode.value = (json['isDarkMode'] ?? Get.isPlatformDarkMode) as bool;
    isAuthEnabled.value = (json['isAuthEnabled'] ?? false) as bool;
    allowAutoSignedCerts.value = (json['allowAutoSignedCerts'] ?? true) as bool;
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

  Future<void> toggleAuthEnabled() async {
    final LocalAuthController localAuth = Get.find();
    if (!isAuthEnabled.value) {
      // A warning that biometrics will be disabled if
      // the user disables biometrics on their device
      Get.defaultDialog(
        title: 'Warning',
        middleText:
            'Biometrics will be disabled if you disable the screen lock on your device.',
        textConfirm: 'Continue',
        textCancel: 'Cancel',
        contentPadding: const EdgeInsets.all(16),
        titlePadding: const EdgeInsets.only(top: 20),
        onConfirm: () async {
          Get.back();
          // check if device supports local auth
          if (!(await localAuth.authenticate())) {
            _logger.w('Device does not support local auth');
            Get.snackbar(
              'Error',
              'Device does not support local auth',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              margin: const EdgeInsets.all(10),
            );
            return;
          }
          _logger.d('Toggling auth enabled to: ${!isAuthEnabled.value}');
          isAuthEnabled.value = !isAuthEnabled.value;
          save();
        },
      );
    } else {
      _logger.d('Toggling auth enabled to: ${!isAuthEnabled.value}');
      isAuthEnabled.value = !isAuthEnabled.value;
      save();
    }
  }

  Future<void> toggleAutoCert() async {
    if (!allowAutoSignedCerts.value) {
      // A warning that biometrics will be disabled if
      // the user disables biometrics on their device
      Get.defaultDialog(
        title: 'Warning',
        middleText:
            'Allowing self-signed certificates could make your connection insecure.',
        textConfirm: 'Continue',
        textCancel: 'Cancel',
        contentPadding: const EdgeInsets.all(16),
        titlePadding: const EdgeInsets.only(top: 20),
        onConfirm: () async {
          Get.back();

          _logger.d(
            'Auto certs set to: ${!allowAutoSignedCerts.value}',
          );
          allowAutoSignedCerts.value = !allowAutoSignedCerts.value;
          save();
        },
      );
    } else {
      _logger.d(
        'Auto certs set to : ${!allowAutoSignedCerts.value}',
      );
      allowAutoSignedCerts.value = !allowAutoSignedCerts.value;
      save();

      // If SSL verification is disabled, we need to re-initialize the API
      // but only if there is a server set
      final UserDataController userDataController = Get.find();
      final PortainerApiProvider api = Get.find();
      if (userDataController.currentServer != null) {
        api.init(
          userDataController.currentServer!,
        );
      }
    }
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
