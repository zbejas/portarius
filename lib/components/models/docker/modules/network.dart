class DockerNetwork {
  String name;
  String networkId;
  String endpointId;
  String gateway;
  String ipAddress;
  int ipPrefixLen;
  String ipv6Gateway;
  String globalIpv6Address;
  int globalIpv6PrefixLen;
  String macAddress;

  DockerNetwork({
    required this.name,
    required this.networkId,
    required this.endpointId,
    required this.gateway,
    required this.ipAddress,
    required this.ipPrefixLen,
    required this.ipv6Gateway,
    required this.globalIpv6Address,
    required this.globalIpv6PrefixLen,
    required this.macAddress,
  });

  factory DockerNetwork.fromJson(Map<String, dynamic> data, String name) {
    return DockerNetwork(
      name: name,
      networkId: data['NetworkID'] as String,
      endpointId: data['EndpointID'] as String,
      gateway: data['Gateway'] as String,
      ipAddress: data['IPAddress'] as String,
      ipPrefixLen: data['IPPrefixLen'] as int,
      ipv6Gateway: data['IPv6Gateway'] as String,
      globalIpv6Address: data['GlobalIPv6Address'] as String,
      globalIpv6PrefixLen: data['GlobalIPv6PrefixLen'] as int,
      macAddress: data['MacAddress'] as String,
    );
  }
}
