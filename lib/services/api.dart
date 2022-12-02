import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:portarius/components/models/docker/simple_container.dart';
import 'package:portarius/components/models/portainer/endpoint.dart';
import 'package:portarius/components/models/serverdata.dart';
import 'package:portarius/services/controllers/logger_controller.dart';
import 'package:portarius/services/controllers/settings_controller.dart';

class PortainerApiProvider extends GetConnect implements GetxService {
  RxString apiToken = ''.obs;
  RxString apiBaseUrl = ''.obs;
  RxString apiLocalUrl = ''.obs;
  RxString apiEndpoint = ''.obs;

  late Map<String, String> _mainHeaders;

  late final Logger _logger = Get.find<LoggerController>().logger;

  final Duration _localTimeout = const Duration(milliseconds: 1500);

  void init(ServerData serverData) {
    apiToken.value = serverData.token;
    apiBaseUrl.value = serverData.baseUrl;
    apiEndpoint.value = serverData.endpoint ?? '';
    apiLocalUrl.value = serverData.localUrl ?? '';

    _mainHeaders = {
      'Content-Type': 'application/json',
      'X-API-Key': apiToken.value,
    };

    // Set global timeout
    httpClient.timeout = const Duration(seconds: 15);

    final SettingsController settingsController = Get.find();

    // Allow self-signed certificates
    allowAutoSignedCert = settingsController.allowAutoSignedCerts.value;
  }

  // Update data for the API
  set updateBaseUrl(String url) => apiBaseUrl.value = url;
  set updateLocalUrl(String url) => apiLocalUrl.value = url;
  set updateEnpoint(String endpoint) => apiEndpoint.value = endpoint;
  set updateToken(String token) {
    apiToken.value = token;
    _mainHeaders = {
      'Content-Type': 'application/json',
      'X-API-Key': apiToken.value,
    };
  }

  set updateAutoSignedCert(bool value) => allowAutoSignedCert = value;

  void clearAll() {
    apiToken.value = '';
    apiBaseUrl.value = '';
    apiEndpoint.value = '';
    apiLocalUrl.value = '';
  }

  Future<String?> testConnection(
      {required String url, required String token}) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-API-Key': token,
    };

    final Response response = await get(
      '$url/api/endpoints',
      headers: headers,
    );

    if (response.hasError) {
      return response.statusText;
    } else {
      return null;
    }
  }

// Get api endpoints
  Future<List<PortainerEndpoint>?> checkEndpoints(
      {required String url, required String token}) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-API-Key': token,
    };

    final Response response = await get(
      '$url/api/endpoints',
      headers: headers,
    );

    if (response.hasError) {
      _showSnackBar('Error getting endpoints');
      _logger.e(response.statusText);
      return null;
    }

    // todo: this is a temporary measure
    // Create list of endpoints with only the ids
    final List<PortainerEndpoint> endpoints = <PortainerEndpoint>[];

    for (final dynamic endpoint in response.body) {
      endpoints
          .add(PortainerEndpoint.fromJson(endpoint as Map<String, dynamic>));
    }

    return endpoints;
  }

  // Get endpoints
  Future<List<PortainerEndpoint>?> getEndpoints() async {
    // ping local url
    Response response;

    // if local url is set, ping it
    if (apiLocalUrl.isNotEmpty) {
      response = await get(
        '$apiLocalUrl/api/endpoints',
        headers: _mainHeaders,
      );
    } else {
      response = await get(
        '$apiBaseUrl/api/endpoints',
        headers: _mainHeaders,
      );
    }

    // if response is not ok, try the other url
    if (response.hasError) {
      response = await get(
        '$apiBaseUrl/api/endpoints',
        headers: _mainHeaders,
      );
    }

    if (response.hasError) {
      _showSnackBar('Error getting endpoints');
      _logger.e(response.statusText);
      return null;
    }

    // todo: this is a temporary measure
    // Create list of endpoints with only the ids
    final List<PortainerEndpoint> endpoints = <PortainerEndpoint>[];

    for (final dynamic endpoint in response.body) {
      endpoints
          .add(PortainerEndpoint.fromJson(endpoint as Map<String, dynamic>));
    }

    return endpoints;
  }

  // Get container list
  Future<List<SimpleContainer>> getContainers() async {
    Response response;

    // if local url is set, ping it
    if (apiLocalUrl.isNotEmpty) {
      try {
        response = await get(
          '$apiLocalUrl/api/endpoints/$apiEndpoint/docker/containers/json',
          headers: _mainHeaders,
        ).timeout(_localTimeout);
      } catch (e) {
        response = const Response(statusCode: 500);
      }
    } else {
      response = await get(
        '$apiBaseUrl/api/endpoints/$apiEndpoint/docker/containers/json',
        headers: _mainHeaders,
      );
    }

    // if response is not ok, try the other url
    if (response.hasError) {
      response = await get(
        '$apiBaseUrl/api/endpoints/$apiEndpoint/docker/containers/json',
        headers: _mainHeaders,
      );
    }

    if (response.hasError) {
      _showSnackBar(response.statusText ?? 'Error getting containers.');
      _logger.e(response.statusText);

      return <SimpleContainer>[];
    }

    final List<dynamic> jsonList = response.body as List<dynamic>;

    final List<SimpleContainer> containers = jsonList.map((dynamic json) {
      return SimpleContainer.fromJson(json as Map<String, dynamic>);
    }).toList();

    return containers;
  }

  // Start container
  Future<void> startContainer(String id) async {
    Response response;

    // if local url is set, ping it
    if (apiLocalUrl.isNotEmpty) {
      try {
        response = await post(
          '$apiLocalUrl/api/endpoints/$apiEndpoint/docker/containers/$id/start',
          {},
          headers: _mainHeaders,
        ).timeout(_localTimeout);
      } catch (e) {
        response = const Response(statusCode: 500);
      }
    } else {
      response = await post(
        '$apiBaseUrl/api/endpoints/$apiEndpoint/docker/containers/$id/start',
        {},
        headers: _mainHeaders,
      );
    }

    // if response is not ok, try the other url
    if (response.hasError) {
      response = await post(
        '$apiBaseUrl/api/endpoints/$apiEndpoint/docker/containers/$id/start',
        {},
        headers: _mainHeaders,
      );
    }

    if (response.hasError) {
      _showSnackBar(response.statusText ?? 'Error starting container.');
      _logger.e(response.statusText);
    }
  }

  // Stop container
  Future<void> stopContainer(String id) async {
    Response response;

    // if local url is set, ping it
    if (apiLocalUrl.isNotEmpty) {
      try {
        response = await post(
          '$apiLocalUrl/api/endpoints/$apiEndpoint/docker/containers/$id/stop',
          {},
          headers: _mainHeaders,
        ).timeout(_localTimeout);
      } catch (e) {
        response = const Response(statusCode: 500);
      }
    } else {
      response = await post(
        '$apiBaseUrl/api/endpoints/$apiEndpoint/docker/containers/$id/stop',
        {},
        headers: _mainHeaders,
      );
    }

    // if response is not ok, try the other url
    if (response.hasError) {
      response = await post(
        '$apiBaseUrl/api/endpoints/$apiEndpoint/docker/containers/$id/stop',
        {},
        headers: _mainHeaders,
      );
    }

    if (response.hasError) {
      _showSnackBar(response.statusText ?? 'Error stopping container.');
      _logger.e(response.statusText);
    }
  }

  // Restart container
  Future<void> restartContainer(String id) async {
    Response response;

    // if local url is set, ping it
    if (apiLocalUrl.isNotEmpty) {
      try {
        response = await post(
          '$apiLocalUrl/api/endpoints/$apiEndpoint/docker/containers/$id/restart',
          {},
          headers: _mainHeaders,
        ).timeout(_localTimeout);
      } catch (e) {
        response = const Response(statusCode: 500);
      }
    } else {
      response = await post(
        '$apiBaseUrl/api/endpoints/$apiEndpoint/docker/containers/$id/restart',
        {},
        headers: _mainHeaders,
      );
    }

    // if response is not ok, try the other url
    if (response.hasError) {
      response = await post(
        '$apiBaseUrl/api/endpoints/$apiEndpoint/docker/containers/$id/restart',
        {},
        headers: _mainHeaders,
      );
    }

    if (response.hasError) {
      _showSnackBar(response.statusText ?? 'Error restarting container.');
      _logger.e(response.statusText);
    }
  }

  void _showSnackBar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Get.theme.errorColor,
      colorText: Get.theme.scaffoldBackgroundColor,
      margin: const EdgeInsets.all(10),
    );
  }
}
