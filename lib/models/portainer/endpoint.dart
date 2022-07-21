// To parse this JSON data, do
//
//     final endpoint = endpointFromJson(jsonString);

import 'dart:convert';

import 'package:portarius/models/portainer/user.dart';
import 'package:portarius/services/remote.dart';

Endpoint endpointFromJson(String str) => Endpoint.fromJson(json.decode(str));

String endpointToJson(Endpoint data) => json.encode(data.toJson());

class Endpoint {
  Endpoint({
    this.authorizedTeams,
    this.authorizedUsers,
    this.azureCredentials,
    this.composeSyntaxMaxVersion,
    this.edgeCheckinInterval,
    this.edgeId,
    this.edgeKey,
    this.extensions,
    this.groupId,
    this.id,
    this.kubernetes,
    this.name,
    this.publicUrl,
    this.snapshots,
    this.status,
    this.tls,
    this.tlscaCert,
    this.tlsCert,
    this.tlsConfig,
    this.tlsKey,
    this.tagIds,
    this.tags,
    this.teamAccessPolicies,
    this.type,
    this.url,
    this.userAccessPolicies,
    this.lastCheckInDate,
    this.securitySettings,
  });

  List<int>? authorizedTeams;
  List<int>? authorizedUsers;
  AzureCredentials? azureCredentials;
  String? composeSyntaxMaxVersion;
  int? edgeCheckinInterval;
  String? edgeId;
  String? edgeKey;
  List<Extension>? extensions;
  int? groupId;
  int? id;
  Kubernetes? kubernetes;
  String? name;
  String? publicUrl;
  List<EndpointSnapshot>? snapshots;
  int? status;
  bool? tls;
  String? tlscaCert;
  String? tlsCert;
  TlsConfig? tlsConfig;
  String? tlsKey;
  List<int>? tagIds;
  List<String>? tags;
  AccessPolicies? teamAccessPolicies;
  int? type;
  String? url;
  AccessPolicies? userAccessPolicies;
  int? lastCheckInDate;
  SecuritySettings? securitySettings;

  factory Endpoint.fromJson(Map<String, dynamic> json) => Endpoint(
        authorizedTeams:
            List<int>.from(json["AuthorizedTeams"]?.map((x) => x) ?? []),
        authorizedUsers:
            List<int>.from(json["AuthorizedUsers"]?.map((x) => x) ?? []),
        azureCredentials:
            AzureCredentials.fromJson(json["AzureCredentials"] ?? {}),
        composeSyntaxMaxVersion: json["ComposeSyntaxMaxVersion"],
        edgeCheckinInterval: json["EdgeCheckinInterval"],
        edgeId: json["EdgeID"],
        edgeKey: json["EdgeKey"],
        extensions: List<Extension>.from(
            json["Extensions"]?.map((x) => Extension.fromJson(x)) ?? []),
        groupId: json["GroupId"],
        id: json["Id"],
        kubernetes: Kubernetes.fromJson(json["Kubernetes"] ?? {}),
        name: json["Name"],
        publicUrl: json["PublicURL"],
        snapshots: List<EndpointSnapshot>.from(
            json["Snapshots"]?.map((x) => EndpointSnapshot.fromJson(x)) ?? []),
        status: json["Status"],
        tls: json["TLS"],
        tlscaCert: json["TLSCACert"],
        tlsCert: json["TLSCert"],
        tlsConfig: TlsConfig.fromJson(json["TLSConfig"] ?? {}),
        tlsKey: json["TLSKey"],
        tagIds: List<int>.from(json["TagIds"]?.map((x) => x) ?? []),
        tags: List<String>.from(json["Tags"]?.map((x) => x) ?? []),
        teamAccessPolicies:
            AccessPolicies.fromJson(json["TeamAccessPolicies"] ?? {}),
        type: json["Type"],
        url: json["URL"],
        userAccessPolicies:
            AccessPolicies.fromJson(json["UserAccessPolicies"] ?? {}),
        lastCheckInDate: json["lastCheckInDate"],
        securitySettings:
            SecuritySettings.fromJson(json["securitySettings"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "AuthorizedTeams":
            List<dynamic>.from(authorizedTeams?.map((x) => x) ?? []),
        "AuthorizedUsers":
            List<dynamic>.from(authorizedUsers?.map((x) => x) ?? []),
        "AzureCredentials": azureCredentials?.toJson(),
        "ComposeSyntaxMaxVersion": composeSyntaxMaxVersion,
        "EdgeCheckinInterval": edgeCheckinInterval,
        "EdgeID": edgeId,
        "EdgeKey": edgeKey,
        "Extensions":
            List<dynamic>.from(extensions?.map((x) => x.toJson()) ?? []),
        "GroupId": groupId,
        "Id": id,
        "Kubernetes": kubernetes?.toJson(),
        "Name": name,
        "PublicURL": publicUrl,
        "Snapshots": List<dynamic>.from(snapshots!.map((x) => x.toJson())),
        "Status": status,
        "TLS": tls,
        "TLSCACert": tlscaCert,
        "TLSCert": tlsCert,
        "TLSConfig": tlsConfig?.toJson(),
        "TLSKey": tlsKey,
        "TagIds": List<dynamic>.from(tagIds?.map((x) => x) ?? []),
        "Tags": List<dynamic>.from(tags?.map((x) => x) ?? []),
        "TeamAccessPolicies": teamAccessPolicies?.toJson(),
        "Type": type,
        "URL": url,
        "UserAccessPolicies": userAccessPolicies?.toJson(),
        "lastCheckInDate": lastCheckInDate,
        "securitySettings": securitySettings?.toJson(),
      };

  /// Refresh the endpoint's status.
  Future<void> refreshEndpoint(User user) async {
    Endpoint newEndpint = (await RemoteService().getEndpoints(user)).firstWhere(
        (x) => x.id == id,
        orElse: () => throw Exception("Endpoint not found"));
    authorizedTeams = newEndpint.authorizedTeams;
    authorizedUsers = newEndpint.authorizedUsers;
    azureCredentials = newEndpint.azureCredentials;
    composeSyntaxMaxVersion = newEndpint.composeSyntaxMaxVersion;
    edgeCheckinInterval = newEndpint.edgeCheckinInterval;
    edgeId = newEndpint.edgeId;
    edgeKey = newEndpint.edgeKey;
    extensions = newEndpint.extensions;
    groupId = newEndpint.groupId;
    id = newEndpint.id;
    kubernetes = newEndpint.kubernetes;
    name = newEndpint.name;
    publicUrl = newEndpint.publicUrl;
    snapshots = newEndpint.snapshots;
    status = newEndpint.status;
    tls = newEndpint.tls;
    tlscaCert = newEndpint.tlscaCert;
    tlsCert = newEndpint.tlsCert;
    tlsConfig = newEndpint.tlsConfig;
    tlsKey = newEndpint.tlsKey;
    tagIds = newEndpint.tagIds;
    tags = newEndpint.tags;
    teamAccessPolicies = newEndpint.teamAccessPolicies;
    type = newEndpint.type;
    url = newEndpint.url;
    userAccessPolicies = newEndpint.userAccessPolicies;
    lastCheckInDate = newEndpint.lastCheckInDate;
    securitySettings = newEndpint.securitySettings;
  }
}

class AzureCredentials {
  AzureCredentials({
    this.applicationId,
    this.authenticationKey,
    this.tenantId,
  });

  String? applicationId;
  String? authenticationKey;
  String? tenantId;

  factory AzureCredentials.fromJson(Map<String, dynamic> json) =>
      AzureCredentials(
        applicationId: json["ApplicationID"],
        authenticationKey: json["AuthenticationKey"],
        tenantId: json["TenantID"],
      );

  Map<String, dynamic> toJson() => {
        "ApplicationID": applicationId,
        "AuthenticationKey": authenticationKey,
        "TenantID": tenantId,
      };
}

class Extension {
  Extension({
    this.type,
    this.url,
  });

  int? type;
  String? url;

  factory Extension.fromJson(Map<String, dynamic> json) => Extension(
        type: json["Type"],
        url: json["URL"],
      );

  Map<String, dynamic> toJson() => {
        "Type": type,
        "URL": url,
      };
}

class Kubernetes {
  Kubernetes({
    this.configuration,
    this.snapshots,
  });

  Configuration? configuration;
  List<KubernetesSnapshot>? snapshots;

  factory Kubernetes.fromJson(Map<String, dynamic> json) => Kubernetes(
        configuration: Configuration.fromJson(json["Configuration"]),
        snapshots: List<KubernetesSnapshot>.from(
            json["Snapshots"]?.map((x) => KubernetesSnapshot.fromJson(x)) ??
                []),
      );

  Map<String, dynamic> toJson() => {
        "Configuration": configuration?.toJson(),
        "Snapshots":
            List<dynamic>.from(snapshots?.map((x) => x.toJson()) ?? []),
      };
}

class Configuration {
  Configuration({
    this.ingressClasses,
    this.restrictDefaultNamespace,
    this.storageClasses,
    this.useLoadBalancer,
    this.useServerMetrics,
  });

  List<IngressClass>? ingressClasses;
  bool? restrictDefaultNamespace;
  List<StorageClass>? storageClasses;
  bool? useLoadBalancer;
  bool? useServerMetrics;

  factory Configuration.fromJson(Map<String, dynamic> json) => Configuration(
        ingressClasses: List<IngressClass>.from(
            json["IngressClasses"]?.map((x) => IngressClass.fromJson(x)) ?? []),
        restrictDefaultNamespace: json["RestrictDefaultNamespace"],
        storageClasses: List<StorageClass>.from(
            json["StorageClasses"]?.map((x) => StorageClass.fromJson(x)) ?? []),
        useLoadBalancer: json["UseLoadBalancer"],
        useServerMetrics: json["UseServerMetrics"],
      );

  Map<String, dynamic> toJson() => {
        "IngressClasses":
            List<dynamic>.from(ingressClasses?.map((x) => x.toJson()) ?? []),
        "RestrictDefaultNamespace": restrictDefaultNamespace,
        "StorageClasses":
            List<dynamic>.from(storageClasses?.map((x) => x.toJson()) ?? []),
        "UseLoadBalancer": useLoadBalancer,
        "UseServerMetrics": useServerMetrics,
      };
}

class IngressClass {
  IngressClass({
    this.name,
    this.type,
  });

  String? name;
  String? type;

  factory IngressClass.fromJson(Map<String, dynamic> json) => IngressClass(
        name: json["Name"],
        type: json["Type"],
      );

  Map<String, dynamic> toJson() => {
        "Name": name,
        "Type": type,
      };
}

class StorageClass {
  StorageClass({
    this.accessModes,
    this.allowVolumeExpansion,
    this.name,
    this.provisioner,
  });

  List<String>? accessModes;
  bool? allowVolumeExpansion;
  String? name;
  String? provisioner;

  factory StorageClass.fromJson(Map<String, dynamic> json) => StorageClass(
        accessModes: List<String>.from(json["AccessModes"].map((x) => x)),
        allowVolumeExpansion: json["AllowVolumeExpansion"],
        name: json["Name"],
        provisioner: json["Provisioner"],
      );

  Map<String, dynamic> toJson() => {
        "AccessModes": List<dynamic>.from(accessModes?.map((x) => x) ?? []),
        "AllowVolumeExpansion": allowVolumeExpansion,
        "Name": name,
        "Provisioner": provisioner,
      };
}

class KubernetesSnapshot {
  KubernetesSnapshot({
    this.kubernetesVersion,
    this.nodeCount,
    this.time,
    this.totalCpu,
    this.totalMemory,
  });

  String? kubernetesVersion;
  int? nodeCount;
  int? time;
  int? totalCpu;
  int? totalMemory;

  factory KubernetesSnapshot.fromJson(Map<String, dynamic> json) =>
      KubernetesSnapshot(
        kubernetesVersion: json["KubernetesVersion"],
        nodeCount: json["NodeCount"],
        time: json["Time"],
        totalCpu: json["TotalCPU"],
        totalMemory: json["TotalMemory"],
      );

  Map<String, dynamic> toJson() => {
        "KubernetesVersion": kubernetesVersion,
        "NodeCount": nodeCount,
        "Time": time,
        "TotalCPU": totalCpu,
        "TotalMemory": totalMemory,
      };
}

class SecuritySettings {
  SecuritySettings({
    this.allowBindMountsForRegularUsers,
    this.allowContainerCapabilitiesForRegularUsers,
    this.allowDeviceMappingForRegularUsers,
    this.allowHostNamespaceForRegularUsers,
    this.allowPrivilegedModeForRegularUsers,
    this.allowStackManagementForRegularUsers,
    this.allowSysctlSettingForRegularUsers,
    this.allowVolumeBrowserForRegularUsers,
    this.enableHostManagementFeatures,
  });

  bool? allowBindMountsForRegularUsers;
  bool? allowContainerCapabilitiesForRegularUsers;
  bool? allowDeviceMappingForRegularUsers;
  bool? allowHostNamespaceForRegularUsers;
  bool? allowPrivilegedModeForRegularUsers;
  bool? allowStackManagementForRegularUsers;
  bool? allowSysctlSettingForRegularUsers;
  bool? allowVolumeBrowserForRegularUsers;
  bool? enableHostManagementFeatures;

  factory SecuritySettings.fromJson(Map<String, dynamic> json) =>
      SecuritySettings(
        allowBindMountsForRegularUsers: json["allowBindMountsForRegularUsers"],
        allowContainerCapabilitiesForRegularUsers:
            json["allowContainerCapabilitiesForRegularUsers"],
        allowDeviceMappingForRegularUsers:
            json["allowDeviceMappingForRegularUsers"],
        allowHostNamespaceForRegularUsers:
            json["allowHostNamespaceForRegularUsers"],
        allowPrivilegedModeForRegularUsers:
            json["allowPrivilegedModeForRegularUsers"],
        allowStackManagementForRegularUsers:
            json["allowStackManagementForRegularUsers"],
        allowSysctlSettingForRegularUsers:
            json["allowSysctlSettingForRegularUsers"],
        allowVolumeBrowserForRegularUsers:
            json["allowVolumeBrowserForRegularUsers"],
        enableHostManagementFeatures: json["enableHostManagementFeatures"],
      );

  Map<String, dynamic> toJson() => {
        "allowBindMountsForRegularUsers": allowBindMountsForRegularUsers,
        "allowContainerCapabilitiesForRegularUsers":
            allowContainerCapabilitiesForRegularUsers,
        "allowDeviceMappingForRegularUsers": allowDeviceMappingForRegularUsers,
        "allowHostNamespaceForRegularUsers": allowHostNamespaceForRegularUsers,
        "allowPrivilegedModeForRegularUsers":
            allowPrivilegedModeForRegularUsers,
        "allowStackManagementForRegularUsers":
            allowStackManagementForRegularUsers,
        "allowSysctlSettingForRegularUsers": allowSysctlSettingForRegularUsers,
        "allowVolumeBrowserForRegularUsers": allowVolumeBrowserForRegularUsers,
        "enableHostManagementFeatures": enableHostManagementFeatures,
      };
}

class EndpointSnapshot {
  EndpointSnapshot({
    this.dockerSnapshotRaw,
    this.dockerVersion,
    this.healthyContainerCount,
    this.imageCount,
    this.nodeCount,
    this.runningContainerCount,
    this.serviceCount,
    this.stackCount,
    this.stoppedContainerCount,
    this.swarm,
    this.time,
    this.totalCpu,
    this.totalMemory,
    this.unhealthyContainerCount,
    this.volumeCount,
  });

  DockerSnapshotRaw? dockerSnapshotRaw;
  String? dockerVersion;
  int? healthyContainerCount;
  int? imageCount;
  int? nodeCount;
  int? runningContainerCount;
  int? serviceCount;
  int? stackCount;
  int? stoppedContainerCount;
  bool? swarm;
  int? time;
  int? totalCpu;
  int? totalMemory;
  int? unhealthyContainerCount;
  int? volumeCount;

  factory EndpointSnapshot.fromJson(Map<String, dynamic> json) =>
      EndpointSnapshot(
        dockerSnapshotRaw:
            DockerSnapshotRaw.fromJson(json["DockerSnapshotRaw"]),
        dockerVersion: json["DockerVersion"],
        healthyContainerCount: json["HealthyContainerCount"],
        imageCount: json["ImageCount"],
        nodeCount: json["NodeCount"],
        runningContainerCount: json["RunningContainerCount"],
        serviceCount: json["ServiceCount"],
        stackCount: json["StackCount"],
        stoppedContainerCount: json["StoppedContainerCount"],
        swarm: json["Swarm"],
        time: json["Time"],
        totalCpu: json["TotalCPU"],
        totalMemory: json["TotalMemory"],
        unhealthyContainerCount: json["UnhealthyContainerCount"],
        volumeCount: json["VolumeCount"],
      );

  Map<String, dynamic> toJson() => {
        "DockerSnapshotRaw": dockerSnapshotRaw?.toJson(),
        "DockerVersion": dockerVersion,
        "HealthyContainerCount": healthyContainerCount,
        "ImageCount": imageCount,
        "NodeCount": nodeCount,
        "RunningContainerCount": runningContainerCount,
        "ServiceCount": serviceCount,
        "StackCount": stackCount,
        "StoppedContainerCount": stoppedContainerCount,
        "Swarm": swarm,
        "Time": time,
        "TotalCPU": totalCpu,
        "TotalMemory": totalMemory,
        "UnhealthyContainerCount": unhealthyContainerCount,
        "VolumeCount": volumeCount,
      };
}

class DockerSnapshotRaw {
  DockerSnapshotRaw({
    this.containers,
    this.images,
    this.info,
    this.networks,
    this.version,
    this.volumes,
  });

  Containers? containers;
  Containers? images;
  Containers? info;
  Containers? networks;
  Containers? version;
  Containers? volumes;

  factory DockerSnapshotRaw.fromJson(Map<String, dynamic> json) =>
      DockerSnapshotRaw(
        containers: Containers.fromJson(json["Containers"] ?? {}),
        images: Containers.fromJson(json["Images"] ?? {}),
        info: Containers.fromJson(json["Info"] ?? {}),
        networks: Containers.fromJson(json["Networks"] ?? {}),
        version: Containers.fromJson(json["Version"] ?? {}),
        volumes: Containers.fromJson(json["Volumes"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "Containers": containers?.toJson(),
        "Images": images?.toJson(),
        "Info": info?.toJson(),
        "Networks": networks?.toJson(),
        "Version": version?.toJson(),
        "Volumes": volumes?.toJson(),
      };
}

class Containers {
  Containers();

  factory Containers.fromJson(Map<String, dynamic> json) => Containers();

  Map<String, dynamic> toJson() => {};
}

class AccessPolicies {
  AccessPolicies({
    this.additionalProp1,
    this.additionalProp2,
    this.additionalProp3,
  });

  AdditionalProp? additionalProp1;
  AdditionalProp? additionalProp2;
  AdditionalProp? additionalProp3;

  factory AccessPolicies.fromJson(Map<String, dynamic> json) => AccessPolicies(
        additionalProp1: AdditionalProp.fromJson(json["additionalProp1"] ?? {}),
        additionalProp2: AdditionalProp.fromJson(json["additionalProp2"] ?? {}),
        additionalProp3: AdditionalProp.fromJson(json["additionalProp3"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "additionalProp1": additionalProp1?.toJson(),
        "additionalProp2": additionalProp2?.toJson(),
        "additionalProp3": additionalProp3?.toJson(),
      };
}

class AdditionalProp {
  AdditionalProp({
    this.roleId,
  });

  int? roleId;

  factory AdditionalProp.fromJson(Map<String, dynamic> json) => AdditionalProp(
        roleId: json["RoleId"],
      );

  Map<String, dynamic> toJson() => {
        "RoleId": roleId,
      };
}

class TlsConfig {
  TlsConfig({
    this.tls,
    this.tlscaCert,
    this.tlsCert,
    this.tlsKey,
    this.tlsSkipVerify,
  });

  bool? tls;
  String? tlscaCert;
  String? tlsCert;
  String? tlsKey;
  bool? tlsSkipVerify;

  factory TlsConfig.fromJson(Map<String, dynamic> json) => TlsConfig(
        tls: json["TLS"],
        tlscaCert: json["TLSCACert"],
        tlsCert: json["TLSCert"],
        tlsKey: json["TLSKey"],
        tlsSkipVerify: json["TLSSkipVerify"],
      );

  Map<String, dynamic> toJson() => {
        "TLS": tls,
        "TLSCACert": tlscaCert,
        "TLSCert": tlsCert,
        "TLSKey": tlsKey,
        "TLSSkipVerify": tlsSkipVerify,
      };
}
