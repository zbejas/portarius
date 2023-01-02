import 'package:portarius/components/models/docker/modules/network.dart';

class NetworkSettings {
  String bridge;
  String gateway;
  String macAddress;
  String sandboxId;
  String ipAddress;
  int ipPrefixLen;
  String linkLocalIpv6Address;
  int linkLocalIpv6PrefixLen;
  String globalIpv6Address;
  int globalIpv6PrefixLen;
  List<DockerNetwork> networks;

  NetworkSettings({
    required this.bridge,
    required this.gateway,
    required this.macAddress,
    required this.sandboxId,
    required this.ipAddress,
    required this.ipPrefixLen,
    required this.linkLocalIpv6Address,
    required this.linkLocalIpv6PrefixLen,
    required this.globalIpv6Address,
    required this.globalIpv6PrefixLen,
    required this.networks,
  });

  factory NetworkSettings.fromJson(Map<String, dynamic> data) {
    return NetworkSettings(
      bridge: data['Bridge'] as String,
      gateway: data['Gateway'] as String,
      macAddress: data['MacAddress'] as String,
      sandboxId: data['SandboxID'] as String,
      ipAddress: data['IPAddress'] as String,
      ipPrefixLen: data['IPPrefixLen'] as int,
      linkLocalIpv6Address: data['LinkLocalIPv6Address'] as String,
      linkLocalIpv6PrefixLen: data['LinkLocalIPv6PrefixLen'] as int,
      globalIpv6Address: data['GlobalIPv6Address'] as String,
      globalIpv6PrefixLen: data['GlobalIPv6PrefixLen'] as int,
      networks: (data['Networks'] as Map<String, dynamic>)
          .entries
          .map((e) =>
              DockerNetwork.fromJson(e.value as Map<String, dynamic>, e.key))
          .toList(),
    );
  }
}
