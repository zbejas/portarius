// ignore_for_file: always_specify_types, avoid_dynamic_calls

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemNavigator, rootBundle;
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:portarius/services/controllers/logger_controller.dart';
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
    ShareResult result = await Share.shareXFiles(
      [file],
    );

    if (result.status != ShareResultStatus.success) {
      _logger.e('Error sharing file: ${result.status}');
    }

    // Delete the temporary file
    await jsonFile.delete();
  }

  Future<void> importData() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
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

      // Show dialog to restart the app
      Get.defaultDialog(
        title: 'dialog_settings_backup_restore_restart_title'.tr,
        middleText: 'dialog_settings_backup_restore_restart_content'.tr,
        textConfirm: 'dialog_ok'.tr,
        textCancel: 'dialog_cancel_not_now'.tr,
        // exit the app
        onConfirm: () => SystemNavigator.pop(),
      );
    } else {
      _logger.e('No file selected');
    }
  }

  String _parseTime(DateTime time) {
    return '${time.year}-${time.month}-${time.day}_${time.hour}-${time.minute}-${time.second}';
  }
}
