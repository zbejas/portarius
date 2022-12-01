import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portarius/components/models/docker/simple_container.dart';
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSearchDialog(dockerController),
        child: const Icon(Icons.search),
      ),
      menuBuilder: (context) => const PortariusDrawer(),
      contentBuilder: (context) => userDataController.serverList.isEmpty ||
              userDataController.currentServer == null
          ? Center(
              child: Text(
                'No servers added',
                style: context.textTheme.headline5,
              ),
            )
          : RefreshIndicator(
              onRefresh: () => dockerController.updateContainers(),
              child: const ContainerList(),
            ),
    );
  }

  void _showSearchDialog(DockerController dockerController) {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Search for a container',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.only(
            bottom: 20.0,
            left: 10.0,
            right: 10.0,
          ),
          child: DropdownSearch<SimpleContainer>(
            items: dockerController.containers,
            itemAsString: (item) => item.name ?? item.image,
            popupProps: const PopupProps.menu(
              showSearchBox: true,
              constraints: BoxConstraints(
                maxHeight: 250,
              ),
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                  labelText: 'Search',
                ),
                autofocus: true,
                padding: EdgeInsets.all(12),
              ),
            ),
            dropdownDecoratorProps: const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(8),
                labelText: 'Search',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
