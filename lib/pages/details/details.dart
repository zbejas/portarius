import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portarius/components/models/docker/modules/mount.dart';
import 'package:portarius/components/models/docker/simple_container.dart';
import 'package:portarius/services/controllers/docker_controller.dart';

class ContainerDetailsPage extends StatefulWidget {
  const ContainerDetailsPage({super.key});

  @override
  State<ContainerDetailsPage> createState() => _ContainerDetailsPageState();
}

class _ContainerDetailsPageState extends State<ContainerDetailsPage> {
  bool loading = true;
  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    final DockerController dockerController = Get.find();
    final String containerId = Get.parameters['id']!;

    SimpleContainer container = dockerController.containers.firstWhere(
      (SimpleContainer container) => container.id == containerId,
    );

    if (loading) {
      dockerController.refreshDetails(container).then((_) {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
      });
    }

    /*if (!dockerController.isRefreshing.value && mounted) {
      Future.delayed(Duration(seconds: dockerController.refreshInterval.value),
          () async {
        await dockerController.refreshDetails(container);
        if (mounted) {
          setState(() {});
        }
      });
    }*/

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
                  actions: [
                    // Logs button
                    IconButton(
                      icon: const Icon(Icons.list),
                      onPressed: () {
                        Get.toNamed(
                          '/home/details/${container.id}/logs',
                        );
                      },
                    ),
                  ],
                ),
                if (loading) ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 100,
                      ),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ] else ...[
                  // Mount points
                  if (container.details?.mounts.isNotEmpty ?? false)
                    SliverToBoxAdapter(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'details_mounts'.tr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(),
                              for (Mount mount in container.details!.mounts)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Tooltip(
                                      message: mount.source,
                                      child: Text(
                                        mount.source.length > 25
                                            ? '${mount.source.substring(0, 25)}...'
                                            : mount.source,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    Tooltip(
                                      message: mount.destination,
                                      child: Text(
                                        mount.destination.length > 20
                                            ? '${mount.destination.substring(0, 20)}...'
                                            : mount.destination,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    )
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
