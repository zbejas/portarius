import 'package:flutter/material.dart';
import 'package:portarius/models/docker/detailed_container.dart';

class DockerStatusCard extends StatelessWidget {
  DockerStatusCard({Key? key, required this.detailedContainer})
      : super(key: key);
  DetailedDockerContainer detailedContainer;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'ID: ${detailedContainer.id}',
      padding: const EdgeInsets.all(5.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status: ${detailedContainer.state!.status}',
              ),
              const Divider(),
              Text(
                'Created: ${_parseDateTime(detailedContainer.created!.toLocal())}',
              ),
              const Divider(),
              Text(
                'Start time: ${_parseDateTime(detailedContainer.state!.startedAt!.toLocal())}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _parseDateTime(DateTime time) {
    return '${time.day}.${time.month}.${time.year} ${time.hour}:${time.minute}:${time.second}';
  }
}
