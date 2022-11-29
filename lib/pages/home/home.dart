import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portarius/components/models/serverdata.dart';
import 'package:portarius/components/models/view/container_list.dart';
import 'package:portarius/components/widgets/drawer.dart';
import 'package:portarius/components/widgets/split_view.dart';
import 'package:portarius/services/controllers/docker_controller.dart';
import 'package:portarius/services/controllers/userdata_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserDataController userDataController = Get.find();

    if (userDataController.currentServer == null) {
      userDataController.setCurrentServer = ServerData(
        baseUrl: 'http://192.168.0.29:9000',
        endpoint: '1',
        token: 'ptr_57P6Iv0Ca0cRhUkdVEw35lzdPQSfgTl/gn0LzESSEvE=',
        name: 'test',
      );
    }

    final DockerController dockerController = Get.put(DockerController());

    return SplitView(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          'portarius',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      menuBuilder: (context) => const PortariusDrawer(),
      contentBuilder: (context) => const ContainerList(),
    );
  }
}
