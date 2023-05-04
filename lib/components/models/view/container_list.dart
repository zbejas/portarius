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
  Map<String, String> loading = {};
  final DockerController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    if (!controller.isRefreshing.value && mounted && loading.isEmpty) {
      Future.delayed(Duration(seconds: controller.refreshInterval.value),
          () async {
        if (mounted) {
          await controller.updateContainers();
          setState(() {});
        }
      });
    }

    print(loading);

    return Obx(
      () {
        if (controller.containers.isEmpty && controller.isLoaded.value) {
          return Center(
            child: Text(
              'home_no_containers_found'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          );
        }

        if (!controller.isLoaded.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
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
            child: InkWell(
              onTap: () {
                Get.toNamed(
                  '/home/details/${controller.containers[index].id}',
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: ListTile(
                  title: Text(
                    controller.containers[index].name ?? '',
                    style: context.textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    controller.containers[index].status ?? '',
                  ),
                  dense: false,
                  leading: loading.containsKey(controller.containers[index])
                      ? const CircularProgressIndicator(
                          strokeWidth: 3,
                        )
                      : PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'start/stop',
                              child: Row(
                                children: [
                                  Icon(
                                    controller.containers[index].state ==
                                            'running'
                                        ? Icons.stop
                                        : Icons.play_arrow,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    controller.containers[index].state ==
                                            'running'
                                        ? 'stop'.tr
                                        : 'start'.tr,
                                    style: context.textTheme.bodyText1,
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'restart',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.delete,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'restart'.tr,
                                    style: context.textTheme.bodyText1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) async {
                            if (value == 'start/stop') {
                              setState(() {
                                loading.addAll({
                                  controller.containers[index].id: 'start/stop',
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

                              loading.remove(controller.containers[index].id);
                              setState(() {});
                            } else if (value == 'restart') {
                              setState(() {
                                loading.addAll({
                                  controller.containers[index].id: 'restart',
                                });
                              });

                              await controller.restartContainer(
                                controller.containers[index],
                              );

                              loading.remove(controller.containers[index].id);
                              setState(() {});
                            }
                          },
                        ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // icon dropdown menu with start/stop/restart
                      const SizedBox(
                        width: 10,
                      ),
                      // status
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
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
      },
    );
  }
}
