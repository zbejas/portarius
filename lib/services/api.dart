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

  final Duration _localTimeout = const Duration(milliseconds: 500);

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

  Future<String?> testConnection({
    required String url,
    required String token,
  }) async {
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
  Future<List<PortainerEndpoint>?> checkEndpoints({
    required String url,
    required String token,
  }) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-API-Key': token,
    };

    final Response response = await get(
      '$url/api/endpoints',
      headers: headers,
    );

    if (response.hasError) {
      _showSnackBar('snackbar_api_error_endpoints'.tr);
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
    final Response response = await _getResponse('/endpoints');

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
    final Response response = await _getResponse(
      '/endpoints/$apiEndpoint/docker/containers/json?all=true',
    );

    if (response.hasError) {
      _showSnackBar(response.statusText ?? 'snackbar_api_error_containers'.tr);
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
    final Response response = await _postResponse(
      '/endpoints/$apiEndpoint/docker/containers/$id/start',
      {},
    );

    if (response.hasError) {
      _showSnackBar(response.statusText ?? 'snackbar_api_error_start'.tr);
      _logger.e(response.statusText);
    }
  }

  // Stop container
  Future<void> stopContainer(String id) async {
    final Response response = await _postResponse(
      '/endpoints/$apiEndpoint/docker/containers/$id/stop',
      {},
    );

    if (response.hasError) {
      _showSnackBar(response.statusText ?? 'snackbar_api_error_stop'.tr);
      _logger.e(response.statusText);
    }
  }

  // Restart container
  Future<void> restartContainer(String id) async {
    final Response response = await _postResponse(
      '/endpoints/$apiEndpoint/docker/containers/$id/restart',
      {},
    );

    if (response.hasError) {
      _showSnackBar(response.statusText ?? 'snackbar_api_error_restart'.tr);
      _logger.e(response.statusText);
    }
  }

  void _showSnackBar(String message) {
    Get.snackbar(
      'snackbar_api_error_title'.tr,
      message,
      backgroundColor: Get.theme.errorColor,
      colorText: Get.theme.scaffoldBackgroundColor,
      margin: const EdgeInsets.all(10),
    );
  }

  // Get a response using a GET request
  // The url is the url without the base url withouth the /api prefix
  // @param url The url to get
  Future<Response> _getResponse(String url) async {
    Response response;

    if (apiLocalUrl.isNotEmpty) {
      try {
        response = await get(
          '$apiLocalUrl/api$url',
          headers: _mainHeaders,
        ).timeout(_localTimeout);
      } catch (e) {
        response = const Response(statusCode: 500);
      }
    } else {
      response = await get(
        '$apiBaseUrl/api$url',
        headers: _mainHeaders,
      );
    }

    // if response is not ok, try the other url
    if (response.hasError) {
      response = await get(
        '$apiBaseUrl/api$url',
        headers: _mainHeaders,
      );
    }

    return response;
  }

  // Get a response using a POST request
  // The url is the url without the base url withouth the /api prefix
  // @param url The url to get
  Future<Response> _postResponse(String url, Map<String, dynamic> body) async {
    Response response;

    // if local url is set, ping it
    if (apiLocalUrl.isNotEmpty) {
      try {
        response = await post(
          '$apiLocalUrl/api$url',
          body,
          headers: _mainHeaders,
        ).timeout(_localTimeout);
      } catch (e) {
        response = const Response(statusCode: 500);
      }
    } else {
      response = await post(
        '$apiBaseUrl/api$url',
        body,
        headers: _mainHeaders,
      );
    }

    // if response is not ok, try the other url
    if (response.hasError) {
      response = await post(
        '$apiBaseUrl/api$url',
        body,
        headers: _mainHeaders,
      );
    }

    return response;
  }

  // todo: figure out how to do this properly
  // Stream a socket
  // The url is the url without the base url withouth the /api prefix
  // @param url The url to get
  // ignore: unused_element
  GetSocket? _getSocket(String url) {
    GetSocket? stream;

    // if local url is set, ping it
    if (apiLocalUrl.isNotEmpty) {
      try {
        stream = socket('$apiLocalUrl/api$url');
      } catch (e) {
        stream = null;
      }
    } else {
      stream = socket('$apiBaseUrl/api$url');
    }

    return stream;
  }
}
