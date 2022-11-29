import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portarius/components/models/docker/simple_container.dart';
import 'package:portarius/services/controllers/docker_controller.dart';

class ContainerList extends StatefulWidget {
  const ContainerList({super.key});

  @override
  State<ContainerList> createState() => _ContainerListState();
}

class _ContainerListState extends State<ContainerList> {
  Map<SimpleContainer, String> loading = {};
  final DockerController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    if (controller.isRefreshing.value && mounted) {
      Future.delayed(Duration(seconds: controller.refreshInterval.value),
          () async {
        await controller.updateContainers();
      });
    }

    return Obx(
      () => controller.containers.isEmpty
          ? const Center(
              child: Text(
                'No containers found.\nMight also be loading...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(
                top: 15,
                bottom: 50,
                left: 15,
                right: 15,
              ),
              itemCount: controller.containers.length,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.only(
                  bottom: 10,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ListTile(
                    title: Text(
                      controller.containers[index].name ?? 'no name',
                      style: context.textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      controller.containers[index].status ?? 'no status',
                    ),
                    dense: false,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // start/stop icon button
                        IconButton(
                          icon: loading.containsKey(
                                      controller.containers[index]) &&
                                  loading[controller.containers[index]] ==
                                      'start/stop'
                              ? const SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                  ),
                                )
                              : Icon(
                                  controller.containers[index].state ==
                                          'running'
                                      ? Icons.stop
                                      : Icons.play_arrow,
                                ),
                          onPressed: () async {
                            setState(() {
                              loading.addAll({
                                controller.containers[index]: 'start/stop',
                              });
                            });

                            if (controller.containers[index].state ==
                                'running') {
                              await controller.stopContainer(
                                controller.containers[index],
                              );
                            } else {
                              await controller.startContainer(
                                controller.containers[index],
                              );
                            }

                            setState(() {
                              loading.remove(controller.containers[index]);
                            });
                          },
                        ),
                        // refresh icon button
                        IconButton(
                          icon: loading.containsKey(
                                      controller.containers[index]) &&
                                  loading[controller.containers[index]] ==
                                      'refresh'
                              ? const SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Icon(Icons.refresh),
                          onPressed: () async {
                            setState(() {
                              loading.addAll({
                                controller.containers[index]: 'refresh',
                              });
                            });

                            await controller.restartContainer(
                              controller.containers[index],
                            );

                            setState(() {
                              loading.remove(controller.containers[index]);
                            });
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        // status
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 60,
                              height: 0,
                            ),
                            if (controller.containers[index].composeStack !=
                                null) ...[
                              Text(
                                controller.containers[index].composeStack ?? '',
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                            ],
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: controller.containers[index].state ==
                                        'running'
                                    ? context.theme.primaryColor
                                    : context.theme.secondaryHeaderColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
