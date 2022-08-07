import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:portarius/models/docker/detailed_container.dart';
import 'package:portarius/models/portainer/endpoint.dart';

import '../models/docker/docker_container.dart';
import '../models/portainer/token.dart';
import '../models/portainer/user.dart';

class RemoteService {
  /// Authenticates the user with the given credentials and returns a [Token].
  /// The [Token] will be used to access the Portainer API.
  Future<Token?> authPortainer(
      String username, String password, String hostUrl) async {
    http.Client client = http.Client();

    // * If there is a '/' at the end of the hostUrl, remove it.
    if (hostUrl.endsWith('/')) {
      hostUrl = hostUrl.substring(0, hostUrl.length - 1);
    }

    Uri uri = Uri.parse("$hostUrl/api/auth");

    http.Response response = await client.post(
      uri,
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
      headers: {
        "Content-Type": "application/json",
        "Charset": "utf-8",
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      Token token = tokenFromJson(response.body);
      Box<dynamic> box = await Hive.openBox('portainer');
      box.put('jwt', token.jwt);

      return token;
    } else {
      debugPrint('authPortainer: ${response.statusCode}');
      return null;
    }
  }

  /// Send logout request to portainer API.
  /// Function will return true or false depending on if the request was successful
  Future<bool> logoutPortainer(User user) async {
    http.Client client = http.Client();

    // * If there is a '/' at the end of the hostUrl, remove it.
    if (user.hostUrl.endsWith('/')) {
      user.hostUrl = user.hostUrl.substring(0, user.hostUrl.length - 1);
    }

    Uri uri = Uri.parse("${user.hostUrl}/api/auth/logout");

    http.Response response = await client.post(
      uri,
      headers: {
        "Authorization": user.token?.getBearerToken() ?? '',
      },
    );

    if (response.statusCode == 204) {
      return true;
    } else {
      debugPrint('logoutPortainer: ${response.statusCode}');
      return false;
    }
  }

  /// Check if currently stored [Token] is valid.
  /// If the token is valid, it will return true.
  /// If the token is not valid, it will return false.
  /// If there is no token stored, it will return false.
  /// If the token is stored, but it is not valid, it will remove the token from the local storage.
  Future<bool> isTokenValid(User user) async {
    if (user.token == null) {
      return false;
    }

    http.Client client = http.Client();
    Uri uri = Uri.parse("${user.hostUrl}/api/motd");
    http.Response response = await client.get(
      uri,
      headers: {"Authorization": user.token?.getBearerToken() ?? ''},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint('isTokenValid: ${response.statusCode}');
      return false;
    }
  }

  /// Returns a [List<DockerContainer>] containing all containers.
  /// The [Token] will be used to access the Portainer API.
  Future<List<DockerContainer>> getDockerContainerList(
      User user, Endpoint endpoint) async {
    http.Client client = http.Client();

    Uri uri = Uri.parse(
      "${user.hostUrl}/api/endpoints/${endpoint.id}/docker/containers/json?all=true",
    );

    http.Response response = await client.get(uri, headers: {
      "Authorization": user.token?.getBearerToken() ?? '',
    });

    if (response.statusCode == 200) {
      return dockerContainerFromJson(response.body);
    } else {
      debugPrint('getDockerContainerList: ${response.statusCode}');
      throw Exception('Failed to load post');
    }
  }

  /// Get a [DockerContainer] by its id.
  /// The [Token] will be used to access the Portainer API.
  /// The [DockerContainer] will be returned.
  /// If the container does not exist, it will return null.
  Future<DetailedDockerContainer?> getDockerContainer(
      User user, Endpoint endpoint, String containerId) async {
    http.Client client = http.Client();

    Uri uri = Uri.parse(
        "${user.hostUrl}/api/endpoints/${endpoint.id}/docker/containers/$containerId/json");

    http.Response response = await client.get(uri, headers: {
      "Authorization": user.token?.getBearerToken() ?? '',
    });

    if (response.statusCode == 200) {
      return detailedDockerContainerFromJson(response.body);
    } else {
      debugPrint('getDockerContainer: ${response.statusCode}');
      throw Exception('Failed to load post');
    }
  }

  /// Restart a [DockerContainer] with the given id.
  /// The [Token] will be used to access the Portainer API.
  /// Returns true if the request was successful.
  /// Returns false if the request was not successful.
  Future<bool> restartDockerContainer(
      User user, Endpoint endpoint, String containerId) async {
    http.Client client = http.Client();

    Uri uri = Uri.parse(
        "${user.hostUrl}/api/endpoints/${endpoint.id}/docker/containers/$containerId/restart");

    http.Response response = await client.post(uri, headers: {
      "Authorization": user.token?.getBearerToken() ?? '',
    });

    if (response.statusCode == 204) {
      return true;
    } else {
      debugPrint('restartDockerContainer: ${response.statusCode}');
      return false;
    }
  }

  /// Start a [DockerContainer] with the given id.
  /// The [Token] will be used to access the Portainer API.
  /// Returns true if the request was successful.
  /// Returns false if the request was not successful.
  Future<bool> startDockerContainer(
      User user, Endpoint endpoint, String containerId) async {
    http.Client client = http.Client();

    Uri uri = Uri.parse(
        "${user.hostUrl}/api/endpoints/${endpoint.id}/docker/containers/$containerId/start");

    http.Response response = await client.post(uri,
        headers: {
          "Authorization": user.token?.getBearerToken() ?? '',
        },
        body: jsonEncode({}));

    if (response.statusCode == 204) {
      return true;
    } else {
      debugPrint('startDockerContainer: ${response.statusCode}');
      return false;
    }
  }

  /// Stop a [DockerContainer] with the given id.
  /// The [Token] will be used to access the Portainer API.
  /// Returns true if the request was successful.
  /// Returns false if the request was not successful.
  Future<bool> stopDockerContainer(
      User user, Endpoint endpoint, String containerId) async {
    http.Client client = http.Client();

    Uri uri = Uri.parse(
        "${user.hostUrl}/api/endpoints/${endpoint.id}/docker/containers/$containerId/stop");

    http.Response response = await client.post(uri, headers: {
      "Authorization": user.token?.getBearerToken() ?? '',
    });

    if (response.statusCode == 204) {
      return true;
    } else {
      debugPrint('stopDockerContainer: ${response.statusCode}');
      return false;
    }
  }

  /// Get stacks from portainer API.
  /// The [Token] will be used to access the Portainer API.
  Future<dynamic> getStacks(User user) async {
    http.Client client = http.Client();

    Uri uri = Uri.parse("${user.hostUrl}/api/stacks");

    http.Response response = await client.get(
      uri,
      headers: {"Authorization": user.token?.getBearerToken() ?? ''},
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      debugPrint('getStacks: ${response.statusCode}');
      throw Exception('Failed to load post');
    }
  }

  /// Get endpoints from portainer API.
  Future<List<Endpoint>> getEndpoints(User user) async {
    http.Client client = http.Client();

    Uri uri = Uri.parse("${user.hostUrl}/api/endpoints");

    http.Response response = await client.get(
      uri,
      headers: {"Authorization": user.token?.getBearerToken() ?? ''},
    );

    if (response.statusCode == 200) {
      return List<Endpoint>.from(
          json.decode(response.body).map((x) => Endpoint.fromJson(x)));
    } else {
      debugPrint('getEndpoints: ${response.statusCode}');
      throw Exception('Failed to load post');
    }
  }

  Future<List<String>> getContainerLogs(
      User user, Endpoint endpoint, String containerId) async {
    http.Client client = http.Client();

    Uri uri = Uri.parse(
        "${user.hostUrl}/api/endpoints/${endpoint.id}/docker/containers/$containerId/logs?tail=200&stdout=true&stderr=true");

    http.Response response = await client.get(uri, headers: {
      "Authorization": user.token?.getBearerToken() ?? '',
    });

    if (response.statusCode == 200) {
      String splitStr = response.body.replaceRange(7, response.body.length, '');

      List<String> returnList = response.body.split(splitStr);
      returnList.removeAt(0);
      for (int i = 0; i < returnList.length; i++) {
        returnList[i] = returnList[i].replaceRange(0, 1, '');
      }

      return returnList;
    } else {
      debugPrint('getLogs: ${response.statusCode}');
      debugPrint('getLogs: ${response.body}');
      throw Exception('Failed to load post');
    }
  }
}
