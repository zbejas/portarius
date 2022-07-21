import 'package:flutter/material.dart';
import 'package:portarius/models/portainer/endpoint.dart';
import 'package:portarius/models/portainer/user.dart';
import 'package:portarius/services/remote.dart';
import 'package:provider/provider.dart';

import '../../models/docker/docker_container.dart';

class DockerContainerCard extends StatefulWidget {
  const DockerContainerCard({
    Key? key,
    required this.endpoint,
    required this.onUpdate,
    required this.container,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  /// The endpoint to which the container belongs.
  /// This is used to know which API endpoint to use.
  final Endpoint endpoint;

  /// Callback for when the user updates the container.
  final Future<VoidCallback?> Function()? onUpdate;
  final void Function()? onTap;
  final void Function()? onLongPress;

  final DockerContainer container;

  @override
  State<DockerContainerCard> createState() => _DockerContainerCardState();
}

class _DockerContainerCardState extends State<DockerContainerCard> {
  final List<bool> _isLoading = [false, false];

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context, listen: true);
    DockerContainer container = widget.container;
    Endpoint endpoint = widget.endpoint;
    Size size = MediaQuery.of(context).size;

    String name = container.names!.first.replaceRange(0, 1, '');

    return Card(
      elevation: 0,
      child: GridTile(
        header: Padding(
            padding: const EdgeInsets.all(15),
            child: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: Card(
                    child: Container(
                      width: 18,
                      height: 18,
                      color: container.state == 'running'
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).secondaryHeaderColor,
                    ),
                  ),
                ),
                Flexible(
                  flex: 3,
                  fit: FlexFit.loose,
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: SizedBox(
                    width: size.height * .02,
                  ),
                ),
              ],
            )),
        footer: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (!_isLoading[0]) ...[
                IconButton(
                  tooltip: container.state == 'running' ? 'Stop' : 'Start',
                  icon: container.state == 'running'
                      ? const Icon(Icons.stop_circle_outlined)
                      : const Icon(Icons.play_circle_outlined),
                  onPressed: () async {
                    /// Pop up confirmation dialog.
                    /// If the user confirms, restart the container.
                    /// If the user cancels, do nothing.
                    if (container.state == 'running') {
                      if (await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return _stopConfirmationDialog(container);
                          })) {
                        setState(() {
                          _isLoading[0] = true;
                        });
                        bool result = await RemoteService()
                            .stopDockerContainer(user, endpoint, container.id);

                        if (result) {
                          widget.onUpdate!();
                        }

                        setState(() {
                          _isLoading[0] = false;
                        });
                      }
                    } else {
                      setState(() {
                        _isLoading[0] = true;
                      });
                      bool result = await RemoteService()
                          .startDockerContainer(user, endpoint, container.id);

                      if (result) {
                        widget.onUpdate!();
                      }

                      setState(() {
                        _isLoading[0] = false;
                      });
                    }
                  },
                ),
              ] else ...[
                Padding(
                  padding: EdgeInsets.all(size.height * 0.011),
                  child: SizedBox(
                    height: size.height * 0.035,
                    width: size.height * 0.035,
                    child: const CircularProgressIndicator(strokeWidth: 1.5),
                  ),
                ),
              ],
              if (!_isLoading[1]) ...[
                IconButton(
                  tooltip: 'Restart',
                  icon: const Icon(Icons.restart_alt),
                  onPressed: () async {
                    /// Pop up confirmation dialog.
                    /// If the user confirms, restart the container.
                    /// If the user cancels, do nothing.
                    if (await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return _restartConfirmationDialog(container);
                        })) {
                      setState(() {
                        _isLoading[1] = true;
                      });
                      bool result = await RemoteService()
                          .restartDockerContainer(user, endpoint, container.id);

                      if (result) {
                        widget.onUpdate!();
                      }

                      setState(() {
                        _isLoading[1] = false;
                      });
                    }
                  },
                ),
              ] else ...[
                Padding(
                  padding: EdgeInsets.all(size.height * 0.011),
                  child: SizedBox(
                    height: size.height * 0.035,
                    width: size.height * 0.035,
                    child: const CircularProgressIndicator(strokeWidth: 1.5),
                  ),
                ),
              ],

              /*IconButton(
                  icon: const Icon(Icons.keyboard_arrow_right),
                  onPressed: () async {
                    setState(() {
                      _isLoading[2] = true;
                    });
                  },
                ),*/
            ],
          ),
        ),
        child: InkWell(
          onTap: () {
            widget.onTap!();
          },
          onLongPress: () {
            widget.onLongPress!();
          },
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 45),
                  child: Text(
                    '${container.status}',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _restartConfirmationDialog(DockerContainer container) => AlertDialog(
        title: Text('Restart ${container.names?.first.replaceRange(0, 1, '')}'),
        content: Text(
            'Are you sure you want to restart ${container.names?.first.replaceRange(0, 1, '')}?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: const Text('Restart'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );

  Widget _stopConfirmationDialog(DockerContainer container) => AlertDialog(
        title: Text('Stop ${container.names?.first.replaceRange(0, 1, '')}'),
        content: Text(
            'Are you sure you want to stop ${container.names?.first.replaceRange(0, 1, '')}?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: const Text('Stop'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
}
