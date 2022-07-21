import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:portarius/components/appbar/appbar.dart';
import 'package:portarius/components/cards/status_card.dart';
import 'package:portarius/models/docker/detailed_container.dart';
import 'package:portarius/models/docker/docker_container.dart';
import 'package:portarius/models/portainer/endpoint.dart';
import 'package:portarius/services/remote.dart';
import 'package:portarius/utils/settings.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../../models/portainer/user.dart';

class ContainerDetailsPage extends StatefulWidget {
  const ContainerDetailsPage({Key? key}) : super(key: key);

  @override
  State<ContainerDetailsPage> createState() => _ContainerDetailsPageState();
}

class _ContainerDetailsPageState extends State<ContainerDetailsPage> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _logScrollController = ScrollController();
  bool _refreshing = false;
  DetailedDockerContainer? detailedContainer;
  bool _onLoad = true;
  bool _showLogs = false;
  bool _autoScroll = true;

  List<String> _logs = [];

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context, listen: true);
    SettingsManager settingsManager =
        Provider.of<SettingsManager>(context, listen: false);

    Size size = MediaQuery.of(context).size;

    Map<String, dynamic> arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    DockerContainer container = arguments['container'];
    Endpoint endpoint = arguments['endpoint'];

    if (_onLoad && mounted) {
      _onLoad = false;
      _getDetailedData(endpoint, container, user);
    }

    if (settingsManager.autoRefresh && !_refreshing) {
      _refreshing = true;
      Future.delayed(Duration(seconds: settingsManager.autoRefreshInterval),
          () {
        if (mounted) {
          _refreshing = false;
          _getDetailedData(endpoint, container, user);

          if (_showLogs && mounted) {
            _getLogs(endpoint, container, user);
          }
        }
      });
    }

    if (detailedContainer == null) {
      return Scaffold(
        body: CustomScrollView(
          shrinkWrap: true,
          controller: _scrollController,
          slivers: const [
            PortariusAppBar(),
            SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          ],
        ),
      );
    }

    detailedContainer?.mounts
        ?.sort((a, b) => a.destination!.compareTo(b.destination!));

    return Scaffold(
      floatingActionButton: SpeedDial(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        spaceBetweenChildren: 2.5,
        spacing: 5,
        children: [
          /*SpeedDialChild(
            child: detailedContainer!.state!.status == 'running'
                ? const Icon(Icons.stop_circle_outlined)
                : const Icon(Icons.play_circle_outlined),
            label: detailedContainer!.state!.status == 'running'
                ? 'Stop'
                : 'Start',
            onTap: () {
              
            },
          ),*/
          SpeedDialChild(
            child: const Icon(Icons.data_array),
            label: 'Logs',
            onTap: () {
              setState(() {
                _showLogs = !_showLogs;
                if (_showLogs) {
                  // scroll to the bottom of page
                  Future.delayed(const Duration(milliseconds: 50), () {
                    _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeOut);
                  });
                }
              });
            },
          ),
          /*SpeedDialChild(
            child: const Icon(Icons.delete),
            label: 'Delete',
            onTap: () {},
          ),*/
        ],
        child: const Icon(Icons.menu),
      ),
      body: CustomScrollView(
        shrinkWrap: true,
        controller: _scrollController,
        slivers: [
          PortariusAppBar(
            title: detailedContainer!.name ?? 'Unknown',
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Wrap(
                clipBehavior: Clip.antiAlias,
                alignment: WrapAlignment.start,
                spacing: 10,
                children: [
                  DockerStatusCard(detailedContainer: detailedContainer!),
                  if (detailedContainer!.mounts!.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Text('Volumes',
                                style: Theme.of(context).textTheme.headline6),
                            ...detailedContainer!.mounts!.map((mount) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  Text(
                                    '${mount.source} -> ${mount.destination}',
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  if (_showLogs) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 10,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Logs',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6),
                                  Row(
                                    children: [
                                      const Text('Auto scroll'),
                                      Switch(
                                        value: _autoScroll,
                                        onChanged: (value) {
                                          setState(() {
                                            _autoScroll = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                            SizedBox(
                              height: size.height * 0.65,
                              child: _logs.isEmpty
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : ListView(
                                      controller: _logScrollController,
                                      children: [
                                        ..._logs.map((line) {
                                          return InkWell(
                                            customBorder:
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                            onLongPress: () {
                                              Clipboard.setData(
                                                  ClipboardData(text: line));
                                              ToastContext().init(context);
                                              Toast.show(
                                                  'Copied line to clipboard',
                                                  duration: Toast.lengthLong,
                                                  gravity: Toast.bottom);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 10,
                                                right: 10,
                                              ),
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    height: 15,
                                                  ),
                                                  Text(line),
                                                  const Divider(),
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  _getDetailedData(
      Endpoint endpoint, DockerContainer container, User user) async {
    DetailedDockerContainer? detailedContainer =
        await RemoteService().getDockerContainer(user, endpoint, container.id);
    if (detailedContainer != null && mounted) {
      setState(() {
        this.detailedContainer = detailedContainer;
      });
    }
  }

  void _getLogs(Endpoint endpoint, DockerContainer container, User user) async {
    List<String> logs =
        await RemoteService().getContainerLogs(user, endpoint, container.id);

    // merged list
    List<String> mergedLogs = [];
    mergedLogs.addAll(_logs);

    print('logs: ${mergedLogs.length}');

    // find last line in old logs
    String lastLine = '';

    if (_logs.isNotEmpty) {
      lastLine = _logs.last;
    }

    if (lastLine != '') {
      for (String line in logs) {
        if (line.compareTo(lastLine) > 0) {
          mergedLogs.add(line);
          break;
        }
      }
    } else {
      mergedLogs.addAll(logs);
    }

    print('logs: ${mergedLogs.length}');

    setState(() {
      _logs = mergedLogs;
      Future.delayed(const Duration(milliseconds: 10), () {
        if (_showLogs &&
            _autoScroll &&
            _logScrollController.positions.isNotEmpty &&
            mounted) {
          _logScrollController.animateTo(
              _logScrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 200),
              curve: Curves.easeIn);
        }
      });
    });
  }
}
