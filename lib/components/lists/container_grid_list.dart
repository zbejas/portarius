// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:portarius/components/cards/docker_card.dart';
import 'package:portarius/models/portainer/endpoint.dart';
import 'package:portarius/models/portainer/user.dart';
import 'package:portarius/utils/settings.dart';
import 'package:provider/provider.dart';

import '../../models/docker/docker_container.dart';
import '../../models/portainer/token.dart';
import '../../services/remote.dart';

class ContainerGrid extends StatefulWidget {
  const ContainerGrid({
    Key? key,
    required this.endpoint,
  }) : super(key: key);

  final Endpoint endpoint;

  @override
  State<ContainerGrid> createState() => _ContainerGridState();
}

class _ContainerGridState extends State<ContainerGrid> {
  List<DockerContainer> _containers = [];
  bool _refreshing = false;
  bool _shouldRefresh = true;

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context, listen: true);
    Size size = MediaQuery.of(context).size;
    SettingsManager settingsManager =
        Provider.of<SettingsManager>(context, listen: false);
    Map<String, List<DockerContainer>> mappedContainers = {};
    List<DockerContainer> nonMappedContainers = [];

    if (settingsManager.autoRefresh && !_refreshing && _shouldRefresh) {
      _refreshing = true;
      Future.delayed(Duration(seconds: settingsManager.autoRefreshInterval),
          () {
        if (mounted) {
          _refreshing = false;
          _getContainers(user);
        }
      });
    }

    if (_containers.isEmpty) {
      _getContainers(user);

      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      /// Add all 'com.docker.compose.project'  containers and sort them by name.
      for (DockerContainer container in _containers) {
        if (container.labels != null &&
            container.labels!.labels
                .containsKey('com.docker.compose.project')) {
          if (mappedContainers[
                  container.labels!.labels['com.docker.compose.project']] ==
              null) {
            mappedContainers[
                container.labels!.labels['com.docker.compose.project']] = [];
          }
          mappedContainers[
                  container.labels!.labels['com.docker.compose.project']]
              ?.add(container);
        } else {
          nonMappedContainers.add(container);
        }
      }

      /// Add all non-mapped containers to the 'default' key.
      if (nonMappedContainers.isNotEmpty) {
        mappedContainers['default'] = nonMappedContainers;
      }

      /// Sort the containers by name.
      /// This is done to make the grid look better.
      for (String key in mappedContainers.keys) {
        mappedContainers[key] = mappedContainers[key]!
            .map((DockerContainer container) => container)
            .toList()
          ..sort((DockerContainer a, DockerContainer b) =>
              a.names!.first.compareTo(b.names!.first));
      }
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (mappedContainers.isEmpty) {
            return const Center(
              child: Text('No containers found.'),
            );
          }
          String project = mappedContainers.keys.toList()[index];
          List<DockerContainer>? containers = mappedContainers[project];
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: 15,
                  top: index == 0 ? 0 : 15,
                ),
                child: Text(
                  project,
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: size.width ~/ 150,
                  childAspectRatio: 1,
                ),
                itemCount: (containers as List<DockerContainer>).length,
                itemBuilder: (BuildContext context, int index) {
                  return DockerContainerCard(
                    container: containers[index],
                    endpoint: widget.endpoint,
                    onUpdate: () async {
                      List<DockerContainer> newData = await RemoteService()
                          .getDockerContainerList(user, widget.endpoint);
                      Future.delayed(const Duration(milliseconds: 100), () {
                        setState(() {
                          _containers = newData;
                        });
                      });
                      return null;
                    },
                    onTap: () async {
                      _shouldRefresh = false;
                      var result = await Navigator.pushNamed(
                        context,
                        '/home/container',
                        arguments: <String, dynamic>{
                          'container': containers[index],
                          'endpoint': widget.endpoint,
                        },
                      );
                      setState(() {
                        _shouldRefresh = true;
                      });
                    },
                    onLongPress: () {
                      // TODO something
                    },
                  );
                },
              ),
            ],
          );
        },
        childCount: mappedContainers.keys.length,
      ),
    );
  }

  void _getContainers(User user) {
    if (!_shouldRefresh) {
      return;
    }

    RemoteService().getDockerContainerList(user, widget.endpoint).then((value) {
      if (value.isNotEmpty && mounted) {
        setState(() {
          _containers = value;
        });
      }
    });

    //print('refresh: ${DateTime.now()}');
  }
}
