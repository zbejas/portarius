// ignore_for_file: always_specify_types, avoid_dynamic_calls

import 'dart:convert';

import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:portarius/services/controllers/logger_controller.dart';

class StorageController extends GetxController {
  late Box<dynamic> userData;
  late Box<dynamic> settings;
  late PackageInfo packageInfo;

  final Logger _logger = LoggerController().logger;

  Future<void> init(String encryptionKey, String path) async {
    try {
      // Try getting encryped box collection

      // Open the boxes from the collection
      userData = await Hive.openBox('userData',
          encryptionCipher: HiveAesCipher(base64Decode(encryptionKey)));
      settings = await Hive.openBox('settings',
          encryptionCipher: HiveAesCipher(base64Decode(encryptionKey)));

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
}
