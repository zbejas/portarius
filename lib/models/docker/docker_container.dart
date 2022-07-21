// To parse this JSON data, do
//
//     final token = tokenFromJson(jsonString);

import 'dart:convert';

List<DockerContainer> dockerContainerFromJson(String str) =>
    List<DockerContainer>.from(
        json.decode(str).map((x) => DockerContainer.fromJson(x)));

String dockerContainerToJson(List<DockerContainer> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

/// Smaller representation of a container than inspecting a single container
class DockerContainer {
  DockerContainer({
    required this.id,
    required this.names,
    required this.image,
    required this.imageId,
    required this.command,
    required this.created,
    required this.state,
    required this.status,
    required this.ports,
    required this.labels,
    required this.sizeRw,
    required this.sizeRootFs,
    required this.hostConfig,
    required this.networkSettings,
    required this.mounts,
  });

  String id;
  List<String>? names;
  String? image;
  String? imageId;
  String? command;
  int? created;
  String? state;
  String? status;
  List<Port>? ports;
  Labels? labels;
  int? sizeRw;
  int? sizeRootFs;
  HostConfig? hostConfig;
  NetworkSettings? networkSettings;
  List<Mount>? mounts;

  factory DockerContainer.fromJson(Map<String, dynamic> json) =>
      DockerContainer(
        id: json["Id"],
        names: List<String>.from(json["Names"]?.map((x) => x) ?? []),
        image: json["Image"],
        imageId: json["ImageID"],
        command: json["Command"],
        created: json["Created"],
        state: json["State"],
        status: json["Status"],
        ports:
            List<Port>.from(json["Ports"]?.map((x) => Port.fromJson(x)) ?? []),
        labels: Labels.fromJson(json["Labels"] ?? {}),
        sizeRw: json["SizeRw"],
        sizeRootFs: json["SizeRootFs"],
        hostConfig: HostConfig.fromJson(json["HostConfig"] ?? {}),
        networkSettings: NetworkSettings.fromJson(json["NetworkSettings"]),
        mounts: List<Mount>.from(
            json["Mounts"]?.map((x) => Mount.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Names": List<dynamic>.from(names?.map((x) => x) ?? []),
        "Image": image,
        "ImageID": imageId,
        "Command": command,
        "Created": created,
        "State": state,
        "Status": status,
        "Ports": List<dynamic>.from(ports?.map((x) => x.toJson()) ?? []),
        "Labels": labels?.toJson(),
        "SizeRw": sizeRw,
        "SizeRootFs": sizeRootFs,
        "HostConfig": hostConfig?.toJson(),
        "NetworkSettings": networkSettings?.toJson(),
        "Mounts": List<dynamic>.from(mounts?.map((x) => x.toJson()) ?? []),
      };

  void updateContainer(DockerContainer container) {
    id = container.id;
    names = container.names!.isEmpty ? names : container.names;
    image = container.image ?? image;
    imageId = container.imageId ?? imageId;
    command = container.command ?? command;
    created = container.created ?? created;
    state = container.state ?? state;
    status = container.status ?? status;
    ports = container.ports!.isEmpty ? ports : container.ports;
    labels = container.labels ?? labels;
    sizeRw = container.sizeRw ?? sizeRw;
    sizeRootFs = container.sizeRootFs ?? sizeRootFs;
    hostConfig = container.hostConfig ?? hostConfig;
    networkSettings = container.networkSettings ?? networkSettings;
    mounts = container.mounts!.isEmpty ? mounts : container.mounts;
  }
}

class Bridge {
  Bridge({
    required this.networkId,
    required this.endpointId,
    required this.gateway,
    required this.ipAddress,
    required this.ipPrefixLen,
    required this.iPv6Gateway,
    required this.globalIPv6Address,
    required this.globalIPv6PrefixLen,
    required this.macAddress,
  });

  String? networkId;
  String? endpointId;
  String? gateway;
  String? ipAddress;
  int? ipPrefixLen;
  String? iPv6Gateway;
  String? globalIPv6Address;
  int? globalIPv6PrefixLen;
  String? macAddress;

  factory Bridge.fromJson(Map<String, dynamic> json) => Bridge(
        networkId: json["NetworkID"],
        endpointId: json["EndpointID"],
        gateway: json["Gateway"],
        ipAddress: json["IPAddress"],
        ipPrefixLen: json["IPPrefixLen"],
        iPv6Gateway: json["IPv6Gateway"],
        globalIPv6Address: json["GlobalIPv6Address"],
        globalIPv6PrefixLen: json["GlobalIPv6PrefixLen"],
        macAddress: json["MacAddress"],
      );

  Map<String, dynamic> toJson() => {
        "NetworkID": networkId,
        "EndpointID": endpointId,
        "Gateway": gateway,
        "IPAddress": ipAddress,
        "IPPrefixLen": ipPrefixLen,
        "IPv6Gateway": iPv6Gateway,
        "GlobalIPv6Address": globalIPv6Address,
        "GlobalIPv6PrefixLen": globalIPv6PrefixLen,
        "MacAddress": macAddress,
      };
}

class Port {
  Port({
    required this.privatePort,
    required this.publicPort,
    required this.type,
  });

  int? privatePort;
  int? publicPort;
  String? type;

  factory Port.fromJson(Map<String, dynamic> json) => Port(
        privatePort: json["PrivatePort"],
        publicPort: json["PublicPort"],
        type: json["Type"],
      );

  Map<String, dynamic> toJson() => {
        "PrivatePort": privatePort,
        "PublicPort": publicPort,
        "Type": type,
      };
}

class HostConfig {
  HostConfig({
    required this.networkMode,
  });

  String networkMode;

  factory HostConfig.fromJson(Map<String, dynamic> json) => HostConfig(
        networkMode: json["NetworkMode"],
      );

  Map<String, dynamic> toJson() => {
        "NetworkMode": networkMode,
      };
}

class Labels {
  /// This class maps all the labels that are used in the Docker image.

  Labels({
    required this.labels,
  });

  Map<String, dynamic> labels;

  factory Labels.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> tempLabels = {};
    tempLabels.addAll(json);

    return Labels(
      labels: tempLabels,
    );
  }

  Map<String, dynamic> toJson() => {
        'Labels': labels,
      };
}

class Mount {
  Mount({
    required this.name,
    required this.source,
    required this.destination,
    required this.driver,
    required this.mode,
    required this.rw,
    required this.propagation,
  });

  String? name;
  String? source;
  String? destination;
  String? driver;
  String? mode;
  bool? rw;
  String? propagation;

  factory Mount.fromJson(Map<String, dynamic> json) => Mount(
        name: json["Name"],
        source: json["Source"],
        destination: json["Destination"],
        driver: json["Driver"],
        mode: json["Mode"],
        rw: json["RW"],
        propagation: json["Propagation"],
      );

  Map<String, dynamic> toJson() => {
        "Name": name,
        "Source": source,
        "Destination": destination,
        "Driver": driver,
        "Mode": mode,
        "RW": rw,
        "Propagation": propagation,
      };
}

class NetworkSettings {
  NetworkSettings({
    required this.networks,
  });

  Networks networks;

  factory NetworkSettings.fromJson(Map<String, dynamic> json) =>
      NetworkSettings(
        networks: Networks.fromJson(json["Networks"]),
      );

  Map<String, dynamic> toJson() => {
        "Networks": networks.toJson(),
      };
}

class Networks {
  Networks({
    required this.bridge,
  });

  Bridge? bridge;

  factory Networks.fromJson(Map<String, dynamic> json) => Networks(
        bridge: Bridge.fromJson(json["bridge"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "bridge": bridge?.toJson(),
      };
}
