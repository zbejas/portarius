import 'package:portarius/components/models/docker/modules/config.dart';
import 'package:portarius/components/models/docker/modules/network_settings.dart';

import 'modules/mount.dart';

class DetailedContainer {
  ContainerConfig config;
  NetworkSettings networkSettings;
  List<Mount> mounts;

  DetailedContainer({
    required this.config,
    required this.networkSettings,
    required this.mounts,
  });

  factory DetailedContainer.fromJson(Map<String, dynamic> data) {
    return DetailedContainer(
      config: ContainerConfig.fromJson(data['Config'] as Map<String, dynamic>),
      networkSettings: NetworkSettings.fromJson(
        data['NetworkSettings'] as Map<String, dynamic>,
      ),
      mounts: (data['Mounts'] as List<dynamic>)
          .map((e) => Mount.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
