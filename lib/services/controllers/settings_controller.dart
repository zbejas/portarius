import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:portarius/services/api.dart';
import 'package:portarius/services/controllers/docker_controller.dart';
import 'package:portarius/services/controllers/logger_controller.dart';
import 'package:portarius/services/controllers/storage_controller.dart';
import 'package:portarius/services/local_auth.dart';

class SettingsController extends GetxController {
  RxBool isDarkMode = false.obs;
  RxBool isAuthEnabled = false.obs;
  RxBool allowAutoSignedCerts = false.obs;
  RxBool autoRefresh = true.obs;
  RxInt refreshInterval = 5.obs;
  RxString sortOption = SortOptions.stack.toString().obs;
  RxBool paranoidMode = false.obs;
  Rx<Locale?> locale = const Locale('en', 'US').obs;
  RxBool listView = true.obs;

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
      'sortOption': sortOption.value,
      'paranoidMode': paranoidMode.value,
      'locale': locale.value.toString(),
      'listView': listView.value,
    };
  }

  // Add data from json to the controller
  // If data is null, set defaults
  void fromJson(Map<dynamic, dynamic> json) {
    isDarkMode.value = (json['isDarkMode'] ?? Get.isPlatformDarkMode) as bool;
    isAuthEnabled.value = (json['isAuthEnabled'] ?? false) as bool;
    allowAutoSignedCerts.value =
        (json['allowAutoSignedCerts'] ?? false) as bool;
    autoRefresh.value = (json['autoRefresh'] ?? true) as bool;
    refreshInterval.value = (json['refreshInterval'] ?? 5) as int;
    sortOption.value =
        (json['sortOption'] ?? SortOptions.stack.toString()) as String;
    paranoidMode.value = (json['paranoidMode'] ?? false) as bool;
    listView.value = (json['listView'] ?? false) as bool;

    // Set locale if it exists
    if (json['locale'] != null) {
      final List<String> localeSplit = (json['locale'] as String).split('_');
      // Check if locale is in the form of 'en_US' or 'en' (for example)
      if (localeSplit.length == 2) {
        locale.value = Locale(localeSplit[0], localeSplit[1]);
      } else {
        locale.value = Locale(localeSplit[0]);
      }
    }
  }

  // ! Toggles and setters

  void toggleListView() {
    listView.value = !listView.value;
    save();
  }

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
        title: 'dialog_settings_security_biometrics_title'.tr,
        middleText: 'dialog_settings_security_biometrics_content'.tr,
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
              'snackbar_settings_no_auth_title'.tr,
              'snackbar_settings_no_auth_content'.tr,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Get.theme.errorColor,
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
      // A warning that self-signed certs will be enabled if
      // the user enables auto signed certs
      Get.defaultDialog(
        title: 'dialog_settings_ssl_verification_title'.tr,
        middleText: 'dialog_settings_ssl_verification_content'.tr,
        textConfirm: 'dialog_ok'.tr,
        textCancel: 'dialog_cancel'.tr,
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
    }

    final PortainerApiProvider apiProvider = Get.find();
    apiProvider.updateAutoSignedCert = !allowAutoSignedCerts.value;
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

  void setSortOption(String value) {
    _logger.d('Setting sort option to: $value');
    sortOption.value = value;
    save();
  }

  void toggleParanoidMode() {
    _logger.d('Toggling paranoid mode to: ${!paranoidMode.value}');
    paranoidMode.value = !paranoidMode.value;
    save();
  }

  void setLocale(Locale value) {
    _logger.d('Setting locale to: ${value.languageCode}');
    locale.value = value;
    Get.updateLocale(value);
    save();
  }
}
