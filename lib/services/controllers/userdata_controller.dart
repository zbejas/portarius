import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portarius/components/models/serverdata.dart';
import 'package:portarius/services/controllers/storage_controller.dart';

class UserDataController extends GetxController {
  RxList<ServerData> serverList = <ServerData>[].obs;

  @override
  void onInit() {
    super.onInit();
    final StorageController storageController = Get.find();

    final List<Map<String, dynamic>> serverListJson =
        (storageController.userData.get('serverList') ??
            <Map<String, dynamic>>[]) as List<Map<String, dynamic>>;

    for (final Map<String, dynamic> server in serverListJson) {
      serverList.add(ServerData.fromJson(server));
    }
  }

  Future<void> save() async {
    final StorageController storageController = Get.find();
    final List<Map<String, dynamic>> serverListJson = <Map<String, dynamic>>[];

    for (final ServerData server in serverList) {
      serverListJson.add(server.toJson());
    }

    await storageController.saveUserData('serverList', serverListJson);
  }

  void addServer(ServerData serverData) {
    if (serverList.contains(serverData)) {
      _showSnackBar('Server already exists');
      return;
    }

    serverList.add(serverData);
    save();
  }

  void removeServer(ServerData serverData) {
    if (!serverList.contains(serverData)) {
      _showSnackBar('Server not found');
      return;
    }
    serverList.remove(serverData);
    save();
  }

  void _showSnackBar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
