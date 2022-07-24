// To parse this JSON data, do
//
//     final detailedDockerContainer = detailedDockerContainerFromJson(jsonString);

import 'dart:convert';

DetailedDockerContainer detailedDockerContainerFromJson(String str) =>
    DetailedDockerContainer.fromJson(json.decode(str));

String detailedDockerContainerToJson(DetailedDockerContainer data) =>
    json.encode(data.toJson());

class DetailedDockerContainer {
  DetailedDockerContainer({
    required this.appArmorProfile,
    required this.args,
    required this.config,
    required this.created,
    required this.driver,
    required this.execIDs,
    required this.hostConfig,
    required this.hostnamePath,
    required this.hostsPath,
    required this.logPath,
    required this.id,
    required this.image,
    required this.mountLabel,
    required this.name,
    required this.networkSettings,
    required this.path,
    required this.processLabel,
    required this.resolvConfPath,
    required this.restartCount,
    required this.state,
    required this.mounts,
  });

  String? appArmorProfile;
  List<String>? args;
  Config? config;
  DateTime? created;
  String? driver;
  List<String>? execIDs;
  HostConfig? hostConfig;
  String? hostnamePath;
  String? hostsPath;
  String? logPath;
  String? id;
  String? image;
  String? mountLabel;
  String? name;
  NetworkSettings? networkSettings;
  String? path;
  String? processLabel;
  String? resolvConfPath;
  int? restartCount;
  DockerState? state;
  List<Mount>? mounts;

  factory DetailedDockerContainer.fromJson(Map<String, dynamic> json) =>
      DetailedDockerContainer(
        appArmorProfile: json["AppArmorProfile"],
        args: List<String>.from(json["Args"].map((x) => x)),
        config: Config.fromJson(json["Config"]),
        created: DateTime.parse(json["Created"]),
        driver: json["Driver"],
        execIDs: List<String>.from(json["ExecIDs"]?.map((x) => x) ?? []),
        hostConfig: HostConfig.fromJson(json["HostConfig"]),
        hostnamePath: json["HostnamePath"],
        hostsPath: json["HostsPath"],
        logPath: json["LogPath"],
        id: json["Id"],
        image: json["Image"],
        mountLabel: json["MountLabel"],
        name: json["Name"].toString().replaceRange(0, 1, ''),
        networkSettings: NetworkSettings.fromJson(json["NetworkSettings"]),
        path: json["Path"],
        processLabel: json["ProcessLabel"],
        resolvConfPath: json["ResolvConfPath"],
        restartCount: json["RestartCount"],
        state:
            json["State"] != null ? DockerState.fromJson(json["State"]) : null,
        mounts: List<Mount>.from(json["Mounts"].map((x) => Mount.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "AppArmorProfile": appArmorProfile,
        "Args": List<dynamic>.from(args?.map((x) => x) ?? []),
        "Config": config?.toJson(),
        "Created": created?.toIso8601String(),
        "Driver": driver,
        "ExecIDs": List<dynamic>.from(execIDs?.map((x) => x) ?? []),
        "HostConfig": hostConfig?.toJson(),
        "HostnamePath": hostnamePath,
        "HostsPath": hostsPath,
        "LogPath": logPath,
        "Id": id,
        "Image": image,
        "MountLabel": mountLabel,
        "Name": name,
        "NetworkSettings": networkSettings?.toJson(),
        "Path": path,
        "ProcessLabel": processLabel,
        "ResolvConfPath": resolvConfPath,
        "RestartCount": restartCount,
        "DockerState": state?.toJson(),
        "Mounts": List<dynamic>.from(mounts?.map((x) => x.toJson()) ?? []),
      };
}

class Config {
  Config({
    required this.attachStderr,
    required this.attachStdin,
    required this.attachStdout,
    required this.cmd,
    required this.domainname,
    required this.env,
    required this.healthcheck,
    required this.hostname,
    required this.image,
    required this.labels,
    required this.macAddress,
    required this.networkDisabled,
    required this.openStdin,
    required this.stdinOnce,
    required this.tty,
    required this.user,
    required this.volumes,
    required this.workingDir,
    required this.stopSignal,
    required this.stopTimeout,
  });

  bool? attachStderr;
  bool? attachStdin;
  bool? attachStdout;
  List<String>? cmd;
  String? domainname;
  List<String>? env;
  Healthcheck? healthcheck;
  String? hostname;
  String? image;
  Labels? labels;
  String? macAddress;
  bool? networkDisabled;
  bool? openStdin;
  bool? stdinOnce;
  bool? tty;
  String? user;
  Volumes? volumes;
  String? workingDir;
  String? stopSignal;
  int? stopTimeout;

  factory Config.fromJson(Map<String, dynamic> json) => Config(
        attachStderr: json["AttachStderr"],
        attachStdin: json["AttachStdin"],
        attachStdout: json["AttachStdout"],
        cmd: List<String>.from(json["Cmd"]?.map((x) => x) ?? []),
        domainname: json["Domainname"],
        env: List<String>.from(json["Env"].map((x) => x)),
        healthcheck: json["Healthcheck"] != null
            ? Healthcheck.fromJson(json["Healthcheck"])
            : null,
        hostname: json["Hostname"],
        image: json["Image"],
        labels: Labels.fromJson(json["Labels"]),
        macAddress: json["MacAddress"],
        networkDisabled: json["NetworkDisabled"],
        openStdin: json["OpenStdin"],
        stdinOnce: json["StdinOnce"],
        tty: json["Tty"],
        user: json["User"],
        volumes: Volumes.fromJson(json["Volumes"]),
        workingDir: json["WorkingDir"],
        stopSignal: json["StopSignal"],
        stopTimeout: json["StopTimeout"],
      );

  Map<String, dynamic> toJson() => {
        "AttachStderr": attachStderr,
        "AttachStdin": attachStdin,
        "AttachStdout": attachStdout,
        "Cmd": List<dynamic>.from(cmd?.map((x) => x) ?? []),
        "Domainname": domainname,
        "Env": List<dynamic>.from(env?.map((x) => x) ?? []),
        "Healthcheck": healthcheck?.toJson(),
        "Hostname": hostname,
        "Image": image,
        "Labels": labels?.toJson(),
        "MacAddress": macAddress,
        "NetworkDisabled": networkDisabled,
        "OpenStdin": openStdin,
        "StdinOnce": stdinOnce,
        "Tty": tty,
        "User": user,
        "Volumes": volumes?.toJson(),
        "WorkingDir": workingDir,
        "StopSignal": stopSignal,
        "StopTimeout": stopTimeout,
      };
}

class Healthcheck {
  Healthcheck({
    required this.test,
  });

  List<String> test;

  factory Healthcheck.fromJson(Map<String, dynamic> json) => Healthcheck(
        test: List<String>.from(json["Test"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "Test": List<dynamic>.from(test.map((x) => x)),
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

class Volumes {
  Volumes({
    required this.volumesData,
  });

  PortBindings volumesData;

  factory Volumes.fromJson(Map<String, dynamic> json) => Volumes(
        volumesData: PortBindings.fromJson(json),
      );

  Map<String, dynamic> toJson() => {
        "/volumes/data": volumesData.toJson(),
      };
}

class PortBindings {
  PortBindings();

  factory PortBindings.fromJson(Map<String, dynamic> json) => PortBindings();

  Map<String, dynamic> toJson() => {};
}

class HostConfig {
  HostConfig({
    required this.maximumIOps,
    required this.maximumIoBps,
    required this.blkioWeight,
    required this.blkioWeightDevice,
    required this.blkioDeviceReadBps,
    required this.blkioDeviceWriteBps,
    required this.blkioDeviceReadIOps,
    required this.blkioDeviceWriteIOps,
    required this.containerIdFile,
    required this.cpusetCpus,
    required this.cpusetMems,
    required this.cpuPercent,
    required this.cpuShares,
    required this.cpuPeriod,
    required this.cpuRealtimePeriod,
    required this.cpuRealtimeRuntime,
    required this.devices,
    required this.deviceRequests,
    required this.ipcMode,
    required this.memory,
    required this.memorySwap,
    required this.memoryReservation,
    required this.kernelMemory,
    required this.oomKillDisable,
    required this.oomScoreAdj,
    required this.networkMode,
    required this.pidMode,
    required this.portBindings,
    required this.privileged,
    required this.readonlyRootfs,
    required this.publishAllPorts,
    required this.restartPolicy,
    required this.logConfig,
    required this.sysctls,
    required this.ulimits,
    required this.volumeDriver,
    required this.shmSize,
  });

  int? maximumIOps;
  int? maximumIoBps;
  int? blkioWeight;
  List<PortBindings>? blkioWeightDevice;
  List<PortBindings>? blkioDeviceReadBps;
  List<PortBindings>? blkioDeviceWriteBps;
  List<PortBindings>? blkioDeviceReadIOps;
  List<PortBindings>? blkioDeviceWriteIOps;
  String? containerIdFile;
  String? cpusetCpus;
  String? cpusetMems;
  int? cpuPercent;
  int? cpuShares;
  int? cpuPeriod;
  int? cpuRealtimePeriod;
  int? cpuRealtimeRuntime;
  List<dynamic>? devices;
  List<DeviceRequest>? deviceRequests;
  String? ipcMode;
  int? memory;
  int? memorySwap;
  int? memoryReservation;
  int? kernelMemory;
  bool? oomKillDisable;
  int? oomScoreAdj;
  String? networkMode;
  String? pidMode;
  PortBindings? portBindings;
  bool? privileged;
  bool? readonlyRootfs;
  bool? publishAllPorts;
  RestartPolicy? restartPolicy;
  LogConfig? logConfig;
  Sysctls? sysctls;
  List<PortBindings>? ulimits;
  String? volumeDriver;
  int? shmSize;

  factory HostConfig.fromJson(Map<String, dynamic> json) => HostConfig(
        maximumIOps: json["MaximumIOps"],
        maximumIoBps: json["MaximumIOBps"],
        blkioWeight: json["BlkioWeight"],
        blkioWeightDevice: List<PortBindings>.from(
            json["BlkioWeightDevice"]?.map((x) => PortBindings.fromJson(x)) ??
                []),
        blkioDeviceReadBps: List<PortBindings>.from(
            json["BlkioDeviceReadBps"]?.map((x) => PortBindings.fromJson(x)) ??
                []),
        blkioDeviceWriteBps: List<PortBindings>.from(
            json["BlkioDeviceWriteBps"]?.map((x) => PortBindings.fromJson(x)) ??
                []),
        blkioDeviceReadIOps: List<PortBindings>.from(
            json["BlkioDeviceReadIOps"]?.map((x) => PortBindings.fromJson(x)) ??
                []),
        blkioDeviceWriteIOps: List<PortBindings>.from(
            json["BlkioDeviceWriteIOps"]
                    ?.map((x) => PortBindings.fromJson(x)) ??
                []),
        containerIdFile: json["ContainerIDFile"],
        cpusetCpus: json["CpusetCpus"],
        cpusetMems: json["CpusetMems"],
        cpuPercent: json["CpuPercent"],
        cpuShares: json["CpuShares"],
        cpuPeriod: json["CpuPeriod"],
        cpuRealtimePeriod: json["CpuRealtimePeriod"],
        cpuRealtimeRuntime: json["CpuRealtimeRuntime"],
        devices: List<dynamic>.from(json["Devices"]?.map((x) => x) ?? []),
        deviceRequests: List<DeviceRequest>.from(
            json["DeviceRequests"]?.map((x) => DeviceRequest.fromJson(x)) ??
                []),
        ipcMode: json["IpcMode"],
        memory: json["Memory"],
        memorySwap: json["MemorySwap"],
        memoryReservation: json["MemoryReservation"],
        kernelMemory: json["KernelMemory"],
        oomKillDisable: json["OomKillDisable"],
        oomScoreAdj: json["OomScoreAdj"],
        networkMode: json["NetworkMode"],
        pidMode: json["PidMode"],
        portBindings: PortBindings.fromJson(json["PortBindings"]),
        privileged: json["Privileged"],
        readonlyRootfs: json["ReadonlyRootfs"],
        publishAllPorts: json["PublishAllPorts"],
        restartPolicy: RestartPolicy.fromJson(json["RestartPolicy"]),
        logConfig: LogConfig.fromJson(json["LogConfig"]),
        sysctls:
            json["Sysctls"] != null ? Sysctls.fromJson(json["Sysctls"]) : null,
        ulimits: List<PortBindings>.from(
            json["Ulimits"]?.map((x) => PortBindings.fromJson(x)) ?? []),
        volumeDriver: json["VolumeDriver"],
        shmSize: json["ShmSize"],
      );

  Map<String, dynamic> toJson() => {
        "MaximumIOps": maximumIOps,
        "MaximumIOBps": maximumIoBps,
        "BlkioWeight": blkioWeight,
        "BlkioWeightDevice":
            List<dynamic>.from(blkioWeightDevice?.map((x) => x.toJson()) ?? []),
        "BlkioDeviceReadBps": List<dynamic>.from(
            blkioDeviceReadBps?.map((x) => x.toJson()) ?? []),
        "BlkioDeviceWriteBps": List<dynamic>.from(
            blkioDeviceWriteBps?.map((x) => x.toJson()) ?? []),
        "BlkioDeviceReadIOps": List<dynamic>.from(
            blkioDeviceReadIOps?.map((x) => x.toJson()) ?? []),
        "BlkioDeviceWriteIOps": List<dynamic>.from(
            blkioDeviceWriteIOps?.map((x) => x.toJson()) ?? []),
        "ContainerIDFile": containerIdFile,
        "CpusetCpus": cpusetCpus,
        "CpusetMems": cpusetMems,
        "CpuPercent": cpuPercent,
        "CpuShares": cpuShares,
        "CpuPeriod": cpuPeriod,
        "CpuRealtimePeriod": cpuRealtimePeriod,
        "CpuRealtimeRuntime": cpuRealtimeRuntime,
        "Devices": List<dynamic>.from(devices?.map((x) => x) ?? []),
        "DeviceRequests":
            List<dynamic>.from(deviceRequests?.map((x) => x.toJson()) ?? []),
        "IpcMode": ipcMode,
        "Memory": memory,
        "MemorySwap": memorySwap,
        "MemoryReservation": memoryReservation,
        "KernelMemory": kernelMemory,
        "OomKillDisable": oomKillDisable,
        "OomScoreAdj": oomScoreAdj,
        "NetworkMode": networkMode,
        "PidMode": pidMode,
        "PortBindings": portBindings?.toJson(),
        "Privileged": privileged,
        "ReadonlyRootfs": readonlyRootfs,
        "PublishAllPorts": publishAllPorts,
        "RestartPolicy": restartPolicy?.toJson(),
        "LogConfig": logConfig?.toJson(),
        "Sysctls": sysctls?.toJson(),
        "Ulimits": List<dynamic>.from(ulimits?.map((x) => x.toJson()) ?? []),
        "VolumeDriver": volumeDriver,
        "ShmSize": shmSize,
      };
}

class DeviceRequest {
  DeviceRequest({
    required this.driver,
    required this.count,
    required this.deviceIDs,
    required this.capabilities,
    required this.options,
  });

  String? driver;
  int? count;
  List<String>? deviceIDs;
  List<List<String>>? capabilities;
  Options? options;

  factory DeviceRequest.fromJson(Map<String, dynamic> json) => DeviceRequest(
        driver: json["Driver"],
        count: json["Count"],
        deviceIDs: List<String>.from(json["DeviceIDs"].map((x) => x)),
        capabilities: List<List<String>>.from(json["Capabilities"]
            .map((x) => List<String>.from(x.map((x) => x)))),
        options: Options.fromJson(json["Options"]),
      );

  Map<String, dynamic> toJson() => {
        "Driver": driver,
        "Count": count,
        "DeviceIDs\"": List<dynamic>.from(deviceIDs?.map((x) => x) ?? []),
        "Capabilities": List<dynamic>.from(
            capabilities?.map((x) => List<dynamic>.from(x.map((x) => x))) ??
                []),
        "Options": options?.toJson(),
      };
}

class Options {
  Options({
    required this.properties,
  });

  Map<String, dynamic> properties;

  factory Options.fromJson(Map<String, dynamic> json) => Options(
        properties: json,
      );

  Map<String, dynamic> toJson() => properties;
}

class LogConfig {
  LogConfig({
    required this.type,
  });

  String type;

  factory LogConfig.fromJson(Map<String, dynamic> json) => LogConfig(
        type: json["Type"],
      );

  Map<String, dynamic> toJson() => {
        "Type": type,
      };
}

class RestartPolicy {
  RestartPolicy({
    required this.maximumRetryCount,
    required this.name,
  });

  int maximumRetryCount;
  String name;

  factory RestartPolicy.fromJson(Map<String, dynamic> json) => RestartPolicy(
        maximumRetryCount: json["MaximumRetryCount"],
        name: json["Name"],
      );

  Map<String, dynamic> toJson() => {
        "MaximumRetryCount": maximumRetryCount,
        "Name": name,
      };
}

class Sysctls {
  Sysctls({
    required this.netIpv4IpForward,
  });

  Map<String, dynamic> netIpv4IpForward;

  factory Sysctls.fromJson(Map<String, dynamic> json) => Sysctls(
        netIpv4IpForward: json,
      );

  Map<String, dynamic> toJson() => netIpv4IpForward;
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
    required this.bridge,
    required this.sandboxId,
    required this.hairpinMode,
    required this.linkLocalIPv6Address,
    required this.linkLocalIPv6PrefixLen,
    required this.sandboxKey,
    required this.endpointId,
    required this.gateway,
    required this.globalIPv6Address,
    required this.globalIPv6PrefixLen,
    required this.ipAddress,
    required this.ipPrefixLen,
    required this.iPv6Gateway,
    required this.macAddress,
    required this.networks,
  });

  String? bridge;
  String? sandboxId;
  bool? hairpinMode;
  String? linkLocalIPv6Address;
  int? linkLocalIPv6PrefixLen;
  String? sandboxKey;
  String? endpointId;
  String? gateway;
  String? globalIPv6Address;
  int? globalIPv6PrefixLen;
  String? ipAddress;
  int? ipPrefixLen;
  String? iPv6Gateway;
  String? macAddress;
  Networks? networks;

  factory NetworkSettings.fromJson(Map<String, dynamic> json) =>
      NetworkSettings(
        bridge: json["Bridge"],
        sandboxId: json["SandboxID"],
        hairpinMode: json["HairpinMode"],
        linkLocalIPv6Address: json["LinkLocalIPv6Address"],
        linkLocalIPv6PrefixLen: json["LinkLocalIPv6PrefixLen"],
        sandboxKey: json["SandboxKey"],
        endpointId: json["EndpointID"],
        gateway: json["Gateway"],
        globalIPv6Address: json["GlobalIPv6Address"],
        globalIPv6PrefixLen: json["GlobalIPv6PrefixLen"],
        ipAddress: json["IPAddress"],
        ipPrefixLen: json["IPPrefixLen"],
        iPv6Gateway: json["IPv6Gateway"],
        macAddress: json["MacAddress"],
        networks: json["Networks"] != null
            ? Networks.fromJson(json["Networks"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "Bridge": bridge,
        "SandboxID": sandboxId,
        "HairpinMode": hairpinMode,
        "LinkLocalIPv6Address": linkLocalIPv6Address,
        "LinkLocalIPv6PrefixLen": linkLocalIPv6PrefixLen,
        "SandboxKey": sandboxKey,
        "EndpointID": endpointId,
        "Gateway": gateway,
        "GlobalIPv6Address": globalIPv6Address,
        "GlobalIPv6PrefixLen": globalIPv6PrefixLen,
        "IPAddress": ipAddress,
        "IPPrefixLen": ipPrefixLen,
        "IPv6Gateway": iPv6Gateway,
        "MacAddress": macAddress,
        "Networks": networks?.toJson(),
      };
}

class Networks {
  Networks({
    required this.bridge,
  });

  Bridge? bridge;

  factory Networks.fromJson(Map<String, dynamic> json) => Networks(
        bridge: json["bridge"] != null ? Bridge.fromJson(json["bridge"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "bridge": bridge?.toJson(),
      };
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

class DockerState {
  DockerState({
    required this.error,
    required this.exitCode,
    required this.finishedAt,
    required this.health,
    required this.oomKilled,
    required this.dead,
    required this.paused,
    required this.pid,
    required this.restarting,
    required this.running,
    required this.startedAt,
    required this.status,
  });

  String? error;
  int? exitCode;
  DateTime? finishedAt;
  Health? health;
  bool? oomKilled;
  bool? dead;
  bool? paused;
  int? pid;
  bool? restarting;
  bool? running;
  DateTime? startedAt;
  String? status;

  factory DockerState.fromJson(Map<String, dynamic> json) => DockerState(
        error: json["Error"],
        exitCode: json["ExitCode"],
        finishedAt: DateTime.parse(json["FinishedAt"]),
        health: json["Health"] != null ? Health.fromJson(json["Health"]) : null,
        oomKilled: json["OOMKilled"],
        dead: json["Dead"],
        paused: json["Paused"],
        pid: json["Pid"],
        restarting: json["Restarting"],
        running: json["Running"],
        startedAt: DateTime.parse(json["StartedAt"]),
        status: json["Status"],
      );

  Map<String, dynamic> toJson() => {
        "Error": error,
        "ExitCode": exitCode,
        "FinishedAt": finishedAt?.toIso8601String(),
        "Health": health?.toJson(),
        "OOMKilled": oomKilled,
        "Dead": dead,
        "Paused": paused,
        "Pid": pid,
        "Restarting": restarting,
        "Running": running,
        "StartedAt": startedAt?.toIso8601String(),
        "Status": status,
      };
}

class Health {
  Health({
    required this.status,
    required this.failingStreak,
    required this.log,
  });

  String? status;
  int? failingStreak;
  List<Log>? log;

  factory Health.fromJson(Map<String, dynamic> json) => Health(
        status: json["Status"],
        failingStreak: json["FailingStreak"],
        log: List<Log>.from(json["Log"].map((x) => Log.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Status": status,
        "FailingStreak": failingStreak,
        "Log": List<dynamic>.from(log?.map((x) => x.toJson()) ?? []),
      };
}

class Log {
  Log({
    required this.start,
    required this.end,
    required this.exitCode,
    required this.output,
  });

  DateTime? start;
  DateTime? end;
  int? exitCode;
  String? output;

  factory Log.fromJson(Map<String, dynamic> json) => Log(
        start: DateTime.parse(json["Start"]),
        end: DateTime.parse(json["End"]),
        exitCode: json["ExitCode"],
        output: json["Output"],
      );

  Map<String, dynamic> toJson() => {
        "Start": start?.toIso8601String(),
        "End": end?.toIso8601String(),
        "ExitCode": exitCode,
        "Output": output,
      };
}
