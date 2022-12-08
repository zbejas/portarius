// ignore_for_file: always_specify_types, avoid_dynamic_calls

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show SystemChannels, SystemNavigator, rootBundle;
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:portarius/main.dart';
import 'package:portarius/services/controllers/logger_controller.dart';
import 'package:portarius/services/controllers/settings_controller.dart';
import 'package:portarius/services/controllers/userdata_controller.dart';
import 'package:share_plus/share_plus.dart';

class StorageController extends GetxController {
  late Box<dynamic> userData;
  late Box<dynamic> settings;
  late PackageInfo packageInfo;
  late Map<String, Map<String, String>> languages;

  final Logger _logger = LoggerController().logger;

  Future<void> init(String encryptionKey, String path) async {
    try {
      // Open the boxes from the collection
      userData = await Hive.openBox(
        'userData',
        encryptionCipher: HiveAesCipher(base64Decode(encryptionKey)),
      );
      settings = await Hive.openBox(
        'settings',
        encryptionCipher: HiveAesCipher(base64Decode(encryptionKey)),
      );

      // Get package info
      packageInfo = await PackageInfo.fromPlatform();
    } catch (e) {
      _logger.e(e);
      return;
    }
  }

  // Save data to userData box
  Future<void> saveUserData(String key, dynamic value) async {
    await userData.put(key, value);
    update();
  }

  Future<void> saveSettings(String key, dynamic value) async {
    await settings.put(key, value);
    update();
  }

  Future<void> loadLanguages() async {
    final Map<String, String> enUs =
        await _convertToMap('assets/lang/en_US.json');
    final Map<String, String> sl = await _convertToMap('assets/lang/sl.json');

    languages = {
      'en_US': enUs,
      'sl': sl,
    };
  }

  Future<Map<String, String>> _convertToMap(String path) async {
    final Map<String, String> newMap = {};
    final Map data = jsonDecode(
      await rootBundle.loadString(path),
    ) as Map;

    data.forEach((key, value) {
      newMap[key.toString()] = value.toString();
    });
    return newMap;
  }

  // Combine the two boxes into one map and return it
  Map<String, dynamic> toJson() {
    return {
      'userData': userData.toMap(),
      'settings': settings.toMap(),
    };
  }

  Future<void> exportData() async {
    final String jsonString = jsonEncode(toJson());

    // Create a temporary file
    final directory = await pathProvider.getTemporaryDirectory();
    final File jsonFile = File(
        '${directory.path}/portarius_backup_${_parseTime(DateTime.now())}.json');
    await jsonFile.writeAsBytes(jsonString.codeUnits);

    final XFile file = XFile(jsonFile.path);
    final ShareResult result = await Share.shareXFiles(
      [file],
    );

    if (result.status != ShareResultStatus.success) {
      _logger.e('Error sharing file: ${result.status}');
    }

    // Delete the temporary file
    await jsonFile.delete();
  }

  Future<void> importData() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final File file = File(result.files.single.path!);
      final Map<String, dynamic> data = jsonDecode(
        await file.readAsString(),
      ) as Map<String, dynamic>;
      // Check if the data is valid
      if (!data.containsKey('userData') || !data.containsKey('settings')) {
        _logger.e('Invalid data: $data');
        Get.snackbar(
          'snackbar_settings_restore_backup_error_title'.tr,
          'snackbar_settings_restore_backup_error_content'.trParams(
            {
              'error': 'Invalid data.',
            },
          ),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.errorColor,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
        );
        return;
      }

      // Save the data to the boxes
      await userData.putAll(data['userData'] as Map);
      await settings.putAll(data['settings'] as Map);

      final UserDataController userDataController = Get.find();
      userDataController.onInit();

      final SettingsController settingsController = Get.find();
      settingsController.fromJson(settings.toMap());

      Get.snackbar(
        'snackbar_success_title'.tr,
        'snackbar_success_content'.tr,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );

      // Restart the app
      Get.forceAppUpdate();
    } else {
      _logger.e('Error importing data: No file selected');
    }
  }

  String _parseTime(DateTime time) {
    return '${time.year}-${time.month}-${time.day}_${time.hour}-${time.minute}-${time.second}';
  }
}
