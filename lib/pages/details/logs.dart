import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portarius/components/models/docker/simple_container.dart';
import 'package:portarius/services/controllers/docker_controller.dart';

class DetailsLogsPage extends StatefulWidget {
  const DetailsLogsPage({super.key});

  @override
  State<DetailsLogsPage> createState() => _DetailsLogsPageState();
}

class _DetailsLogsPageState extends State<DetailsLogsPage> {
  bool loading = true;
  List<String>? logs = [];
  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final DockerController dockerController = Get.find();
    final String containerId = Get.parameters['id']!;

    SimpleContainer container = dockerController.containers.firstWhere(
      (SimpleContainer container) => container.id == containerId,
    );

    if (!dockerController.isRefreshing.value && mounted && logs != null) {
      Future.delayed(Duration(seconds: dockerController.refreshInterval.value),
          () async {
        logs = await dockerController.getContainerLogs(container);
        loading = false;

        if (mounted) {
          setState(() {});
        }
      });
    }

    if (logs == null) {
      Future.delayed(const Duration(milliseconds: 500), () async {
        Get.defaultDialog(
          title: 'Error',
          middleText: 'Could not get logs for this container',
          textConfirm: 'OK',
          onConfirm: () => Get.back(),
        );
      });
    }

    return Scaffold(
      body: Obx(
        () {
          container = dockerController.containers.firstWhere(
            (SimpleContainer container) => container.id == containerId,
          );
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverAppBar(
                  centerTitle: true,
                  backgroundColor: context.theme.scaffoldBackgroundColor,
                  elevation: 0,
                  pinned: true,
                  title: Text(
                    container.name ?? 'portarius',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (loading) ...[
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
                if (logs != null && logs!.isNotEmpty) ...[
                  // Logs here
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return Text(logs![index]);
                      },
                      childCount: logs!.length,
                    ),
                  ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}
