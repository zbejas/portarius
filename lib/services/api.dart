import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:portarius/services/controllers/logger_controller.dart';
import 'package:portarius/services/controllers/settings_controller.dart';

class PortainerApiProvider extends GetConnect implements GetxService {
  RxString apiToken = ''.obs;
  RxString apiBaseUrl = ''.obs;
  RxString apiEndpoint = ''.obs;

  late Map<String, String> _mainHeaders;

  final LoggerController _loggerController = Get.find();
  late final Logger _logger = _loggerController.logger;

  void init(String token, String baseUrl, String endpoint) {
    apiToken.value = token;
    apiBaseUrl.value = baseUrl;
    apiEndpoint.value = endpoint;

    _mainHeaders = {
      'Content-Type': 'application/json',
      'X-API-Key': apiToken.value,
    };

    // Set global timeout
    httpClient.timeout = const Duration(seconds: 15);

    final SettingsController settingsController = Get.find();
    final bool verifySsl = settingsController.isSslVerificationEnabled.value;

    // Allow self-signed certificates
    allowAutoSignedCert = !verifySsl;
  }

  // Update data for the API
  set updateBaseUrl(String url) => apiBaseUrl.value = url;
  set updateEnpoint(String endpoint) => apiEndpoint.value = endpoint;
  set updateToken(String token) {
    apiToken.value = token;
    _mainHeaders = {
      'Content-Type': 'application/json',
      'X-API-Key': apiToken.value,
    };
  }

  set updateAutoSignedCert(bool value) => allowAutoSignedCert = value;

  void updateAll(String token, String baseUrl, String endpoint) {
    apiToken.value = token;

    _mainHeaders = {
      'Content-Type': 'application/json',
      'X-API-Key': apiToken.value,
    };

    apiBaseUrl.value = baseUrl;
    apiEndpoint.value = endpoint;
  }

  // Get endpoints
  Future<Response?> getEndpoints() async {
    final Response response = await get(
      '$apiBaseUrl/api/endpoints',
      headers: _mainHeaders,
    );

    if (response.hasError) {
      _showSnackBar('Error getting endpoints');
      _logger.e(response.statusText);
      return null;
    }

    return response;
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

  // Get container list
  Future<Response?> getContainers() async {
    final Response response = await get(
      '$apiBaseUrl/api/endpoints/$apiEndpoint/docker/containers/json?all=1',
      headers: _mainHeaders,
    );

    if (response.hasError) {
      _showSnackBar('Error getting containers');
      _logger.e(response.statusText);
      return null;
    }

    return response;
  }
}
