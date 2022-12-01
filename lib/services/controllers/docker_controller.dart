import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:portarius/components/models/docker/simple_container.dart';
import 'package:portarius/services/api.dart';
import 'package:portarius/services/controllers/settings_controller.dart';
import 'package:portarius/services/controllers/userdata_controller.dart';

import 'logger_controller.dart';

enum SortOptions {
  stack,
  name,
  status,
  created,
}

class DockerController extends GetxController {
  final Logger _logger = Get.find<LoggerController>().logger;
  final List<SimpleContainer> containers = <SimpleContainer>[].obs;
  final PortainerApiProvider _api = Get.find();
  final RxBool isRefreshing = false.obs;
  final RxInt refreshInterval = 5.obs;
  final RxString sortOption = SortOptions.stack.toString().obs;

  @override
  Future<void> onInit() async {
    final UserDataController userDataController = Get.find();
    final SettingsController settingsController = Get.find();

    refreshInterval.value = settingsController.refreshInterval.value;
    isRefreshing.value = settingsController.autoRefresh.value;
    sortOption.value = settingsController.sortOption.value;

    if (userDataController.currentServer != null) {
      _api.init(userDataController.currentServer!);

      containers.addAll(await _api.getContainers());
    } else {
      _logger.e('No server data found');
    }

    sort();

    super.onInit();
  }

  List<SimpleContainer> get runningContainers => containers
      .where((SimpleContainer container) => container.state == 'running')
      .toList();
  List<SimpleContainer> get stoppedContainers => containers
      .where((SimpleContainer container) => container.state == 'exited')
      .toList();

  Map<String, List<SimpleContainer>> mapSortedByStack() {
    final Map<String, List<SimpleContainer>> sorted =
        <String, List<SimpleContainer>>{};
    for (final SimpleContainer container in containers) {
      if (container.composeStack == null) {
        if (sorted['none'] == null) {
          sorted['none'] = <SimpleContainer>[];
        }
        sorted['none']!.add(container);
      } else {
        if (sorted[container.composeStack!] == null) {
          sorted[container.composeStack!] = <SimpleContainer>[];
        }
        sorted[container.composeStack!]!.add(container);
      }

      if (sorted.containsKey(container.composeStack)) {
        sorted[container.composeStack]!.add(container);
      } else {
        sorted[container.composeStack!] = <SimpleContainer>[container];
      }
    }
    return sorted;
  }

  Future<void> updateContainers() async {
    final List<SimpleContainer> newContainers = await _api.getContainers();
    containers.clear();
    containers.addAll(newContainers);
    sort();
  }

  Future<void> startContainer(SimpleContainer container) async {
    update();
    await _api.startContainer(container.id);
    await updateContainers();
  }

  Future<void> stopContainer(SimpleContainer container) async {
    update();
    await _api.stopContainer(container.id);
    await updateContainers();
  }

  Future<void> restartContainer(SimpleContainer container) async {
    update();
    await _api.restartContainer(container.id);
    await updateContainers();
  }

  void sort() {
    if (sortOption.value == SortOptions.name.toString()) {
      containers.sort((SimpleContainer a, SimpleContainer b) =>
          a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));
    } else if (sortOption.value == SortOptions.status.toString()) {
      containers.sort((SimpleContainer a, SimpleContainer b) =>
          a.state!.toLowerCase().compareTo(b.state!.toLowerCase()));
    } else if (sortOption.value == SortOptions.stack.toString()) {
      containers.sort(
        (SimpleContainer a, SimpleContainer b) =>
            a.composeStack!.compareTo(b.composeStack!),
      );
    } else if (sortOption.value == SortOptions.created.toString()) {
      containers.sort((SimpleContainer a, SimpleContainer b) =>
          a.created!.compareTo(b.created!));
    }
  }

  void setSortOption(SortOptions option) {
    sortOption.value = option.toString();
    sort();
  }

  SortOptions sortOptionFromString(String option) {
    if (option == SortOptions.name.toString()) {
      return SortOptions.name;
    } else if (option == SortOptions.status.toString()) {
      return SortOptions.status;
    } else if (option == SortOptions.stack.toString()) {
      return SortOptions.stack;
    } else if (option == SortOptions.created.toString()) {
      return SortOptions.created;
    } else {
      return SortOptions.stack;
    }
  }
}
