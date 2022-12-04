import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portarius/components/models/portainer/endpoint.dart';
import 'package:portarius/components/models/serverdata.dart';
import 'package:portarius/services/api.dart';
import 'package:portarius/services/controllers/storage_controller.dart';

class UserDataController extends GetxController {
  RxList<ServerData> serverList = <ServerData>[].obs;
  ServerData? currentServer;
  List<PortainerEndpoint> currentServerEndpoints = <PortainerEndpoint>[];

  @override
  void onInit() {
    super.onInit();
    final StorageController storageController = Get.find();

    final Map<dynamic, dynamic> storedList = storageController.userData.toMap();

    if (storedList.isNotEmpty) {
      for (final Map<dynamic, dynamic> server in storedList['serverList']) {
        serverList.add(ServerData.fromJson(server));
      }
    }

    if (storedList['currentServer'] != null) {
      currentServer = ServerData.fromJson(storedList['currentServer'] as Map);
    }

    if (storedList['currentServerEndpoints'] != null) {
      for (final Map<dynamic, dynamic> endpoint
          in storedList['currentServerEndpoints']) {
        currentServerEndpoints.add(PortainerEndpoint.fromJson(endpoint));
      }
    }
  }

  Future<void> save() async {
    final StorageController storageController = Get.find();
    final List<Map<String, dynamic>> serverListJson = <Map<String, dynamic>>[];

    for (final ServerData server in serverList) {
      serverListJson.add(server.toJson());
    }

    await storageController.saveUserData('serverList', serverListJson);

    if (currentServer != null) {
      await storageController.saveUserData(
        'currentServer',
        currentServer!.toJson(),
      );
    }

    if (currentServerEndpoints.isNotEmpty) {
      await storageController.saveUserData(
        'currentServerEndpoints',
        currentServerEndpoints.map((e) => e.toJson()).toList(),
      );
    }
  }

  void addServer(ServerData serverData) {
    if (serverList.contains(serverData)) {
      _showSnackBar('userdata_server_exists'.tr);
      return;
    }

    serverList.add(serverData);
    setCurrentServer(serverData);
    refresh();
    save();
  }

  void removeServer(ServerData serverData) {
    if (!serverList.contains(serverData)) {
      _showSnackBar('snackbar_userdata_server_not_found'.tr);
      return;
    }
    serverList.remove(serverData);
    save();
  }

  void _showSnackBar(String message) {
    Get.snackbar(
      'snackbar_userdata_title'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
    );
  }

  bool setCurrentServer(ServerData serverData) {
    // get endpoints from server
    final PortainerApiProvider api = Get.find();

    // changed to .then() so the user has instant feedback
    api.checkEndpoints(url: serverData.baseUrl, token: serverData.token).then(
      (endpoints) {
        if (endpoints == null) {
          _showSnackBar('snackbar_server_add_test_no_endoint_title'.tr);
          return false;
        }

        if (endpoints.isNotEmpty) {
          currentServerEndpoints = endpoints;
        }
      },
    );

    currentServer = serverData;
    save();
    return true;
  }

  void clearCurrentServer() {
    currentServer = null;
    clearCurrentServerEndpoints();
    final PortainerApiProvider api = Get.find();
    api.clearAll();
  }

  void setCurrentServerEndpoints(List<PortainerEndpoint> endpoints) {
    currentServerEndpoints = endpoints;
    save();
  }

  void clearCurrentServerEndpoints() {
    currentServerEndpoints = <PortainerEndpoint>[];
    save();
  }

  void setNewCurrentServerEndpoint(String endpointId) {
    currentServer = currentServer!.copyWith(endpoint: endpointId);
    final PortainerApiProvider api = Get.find();
    api.init(currentServer!);
    save();
  }

  Future<void> refreshEndpoints(ServerData serverData) async {
    final PortainerApiProvider api = Get.find();
    final List<PortainerEndpoint>? endpoints = await api.checkEndpoints(
      url: serverData.baseUrl,
      token: serverData.token,
    );

    if (endpoints == null) {
      return;
    }

    if (endpoints.isNotEmpty) {
      currentServerEndpoints = endpoints;
    }
  }
}
