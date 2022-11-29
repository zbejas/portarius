import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:portarius/services/api.dart';
import 'package:portarius/services/controllers/logger_controller.dart';
import 'package:portarius/services/controllers/settings_controller.dart';
import 'package:portarius/services/controllers/storage_controller.dart';
import 'package:portarius/services/controllers/userdata_controller.dart';
import 'package:portarius/services/local_auth.dart';

import 'controllers/drawer_controller.dart';

class ServiceController {
  Future<void> initServices() async {
    final Logger logger = Get.put(LoggerController()).logger;

    logger.i('Initializing services...');

    // Make sure flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize secure storage
    await initStorage();

    // Initialize settings controller
    final SettingsController settings = Get.put(SettingsController());

    // Get settings from storage
    final StorageController storage = Get.find();
    settings.fromJson(storage.settings.toMap());

    // Initialize local_auth
    final LocalAuthController localAuth = Get.put(LocalAuthController());
    if (settings.isAuthEnabled.value) {
      if (!(await localAuth.deviceSupported())) {
        logger.w('Device does not support local auth');
        settings.isAuthEnabled.value = false;
        await settings.save();
        Get.forceAppUpdate();
      }

      final bool result = await localAuth.authenticate();
      if (!result) {
        logger.e('Failed to authenticate');

        // Try reinitializing
        // Hope this doesn't cause an infinite loop/memory leaks
        await initServices();
        return;
      }
    }

    // Init user data controller
    final UserDataController userData = Get.put(UserDataController());

    // Init DrawerController
    final PortariusDrawerController drawerController =
        Get.put(PortariusDrawerController());

    // Init api provider
    final PortainerApiProvider apiProvider = Get.put(PortainerApiProvider());
    if (userData.serverList.isNotEmpty) {
      // init api provider with selected server
    }
    // 200ms delay to make sure the UI has time to update
    await Future.delayed(const Duration(milliseconds: 200));

    logger.i('Services initialized.');
  }

  Future<void> initStorage() async {
    final String path =
        (await path_provider.getApplicationDocumentsDirectory()).path;

    if (!GetPlatform.isWeb) {
      Hive.init(path);
    }

    // Get encryption key from secure storage
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    final bool containsEncryptionKey =
        await secureStorage.containsKey(key: 'encryptionKey');

    // If the key doesn't exist, generate a new one
    if (!containsEncryptionKey) {
      final List<int> key = Hive.generateSecureKey();
      await secureStorage.write(
        key: 'encryptionKey',
        value: base64UrlEncode(key),
      );
    } else {
      // check if key is valid
      final String? key = await secureStorage.read(key: 'encryptionKey');

      // if key is not valid, generate a new one and delete the old one
      // and the hive storage
      if (key == null || key.isEmpty) {
        final List<int> newKey = Hive.generateSecureKey();
        await Hive.deleteBoxFromDisk('userData');
        await Hive.deleteBoxFromDisk('settings');
        await secureStorage.write(
            key: 'encryptionKey', value: base64UrlEncode(newKey));
      }
    }

    // get the key
    final String key = await secureStorage.read(key: 'encryptionKey') ?? '';

    // Initialize storage
    final StorageController storageController = Get.put(StorageController());
    await storageController.init(key, path);
  }
}
