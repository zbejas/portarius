import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portarius/components/models/docker/simple_container.dart';
import 'package:portarius/services/controllers/docker_controller.dart';

class ContainerGrid extends StatefulWidget {
  const ContainerGrid({super.key});

  @override
  State<ContainerGrid> createState() => _ContainerGridState();
}

class _ContainerGridState extends State<ContainerGrid> {
  Map<SimpleContainer, String> loading = {};
  final DockerController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    if (!controller.isRefreshing.value && mounted && loading.isEmpty) {
      Future.delayed(Duration(seconds: controller.refreshInterval.value),
          () async {
        await controller.updateContainers();
        if (mounted) {
          setState(() {});
        }
      });
    }

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

        return GridView.builder(
          padding: const EdgeInsets.only(
            top: 15,
            bottom: 50,
            left: 15,
            right: 15,
          ),
          itemCount: controller.containers.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.05,
          ),
          itemBuilder: (context, index) => Card(
            elevation: 0,
            child: GridTile(
              header: Padding(
                padding: const EdgeInsets.all(15),
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Card(
                        child: Container(
                          width: 12,
                          height: 12,
                          color: controller.containers[index].state == 'running'
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).secondaryHeaderColor,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      child: Text(
                        controller.containers[index].name ?? 'Unknown',
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Flexible(
                      child: SizedBox(
                        width: 12,
                      ),
                    ),
                  ],
                ),
              ),
              footer: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // check if container is loading and what value it has
                    if (loading.containsKey(controller.containers[index]) &&
                        loading[controller.containers[index]] != 'restart') ...[
                      Padding(
                        padding: EdgeInsets.all(context.height * 0.011),
                        child: SizedBox(
                          height: context.height * 0.035,
                          width: context.height * 0.035,
                          child:
                              const CircularProgressIndicator(strokeWidth: 1.5),
                        ),
                      ),
                    ] else ...[
                      IconButton(
                        tooltip: controller.containers[index].state == 'running'
                            ? 'Stop'
                            : 'Start',
                        icon: controller.containers[index].state == 'running'
                            ? const Icon(Icons.stop_circle_outlined)
                            : const Icon(Icons.play_circle_outlined),
                        onPressed: () async {
                          if (controller.containers[index].state == 'running') {
                            setState(() {
                              loading[controller.containers[index]] = 'stop';
                            });
                            await controller
                                .stopContainer(controller.containers[index]);

                            setState(() {
                              loading.remove(controller.containers[index]);
                            });
                          } else {
                            setState(() {
                              loading[controller.containers[index]] = 'start';
                            });
                            await controller
                                .startContainer(controller.containers[index]);

                            setState(() {
                              loading.remove(controller.containers[index]);
                            });
                          }
                        },
                      ),
                    ],
                    if (loading.containsKey(controller.containers[index]) &&
                        loading[controller.containers[index]] == 'restart') ...[
                      Padding(
                        padding: EdgeInsets.all(context.height * 0.011),
                        child: SizedBox(
                          height: context.height * 0.035,
                          width: context.height * 0.035,
                          child:
                              const CircularProgressIndicator(strokeWidth: 1.5),
                        ),
                      ),
                    ] else ...[
                      IconButton(
                        tooltip: 'Restart',
                        icon: const Icon(Icons.restart_alt),
                        onPressed: () async {
                          setState(() {
                            loading[controller.containers[index]] = 'restart';
                          });
                          await controller
                              .restartContainer(controller.containers[index]);

                          setState(() {
                            loading.remove(controller.containers[index]);
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
              child: InkWell(
                onTap: () {
                  Get.toNamed(
                    '/home/details',
                    arguments: controller.containers[index].id,
                  );
                },
                onLongPress: () {},
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${controller.containers[index].composeStack}',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.caption!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 42.5,
                          top: 5,
                        ),
                        child: Text(
                          '${controller.containers[index].status}',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.caption,
                        ),
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
