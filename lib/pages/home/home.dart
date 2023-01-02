import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portarius/components/models/docker/simple_container.dart';
import 'package:portarius/components/models/view/container_grid.dart';
import 'package:portarius/components/models/view/container_list.dart';
import 'package:portarius/components/widgets/drawer.dart';
import 'package:portarius/components/widgets/split_view.dart';
import 'package:portarius/services/controllers/docker_controller.dart';
import 'package:portarius/services/controllers/settings_controller.dart';
import 'package:portarius/services/controllers/userdata_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserDataController userDataController = Get.find();

    final DockerController dockerController = Get.put(DockerController());
    final SettingsController settingsController = Get.find();

    final bool poppedFromServerAdd =
        (Get.arguments is bool ? Get.arguments : false) as bool;

    // If there are no servers, show the server add dialog
    // todo: Get.isLogEnabled is a hack to prevent this from getting this every time the page is rebuilt, but it's not ideal
    if (userDataController.serverList.isEmpty &&
        !poppedFromServerAdd &&
        !Get.isLogEnable) {
      Future.delayed(const Duration(milliseconds: 750), () {
        Get.defaultDialog(
          title: 'dialog_add_server_title'.tr,
          middleText: 'dialog_add_server_content'.tr,
          textConfirm: 'dialog_yes'.tr,
          textCancel: 'dialog_cancel_not_now'.tr,
          confirmTextColor: Colors.white,
          onConfirm: () async {
            Get.back();
            await Future.delayed(
              const Duration(
                milliseconds: 250,
              ),
            );
            await Get.toNamed('/userdata/add_server');
            // 250ms delay to allow the server to be added
            await Future.delayed(
              const Duration(
                milliseconds: 250,
              ),
            );

            // Refresh the page
            Get.offAllNamed('/home', arguments: true);
          },
        );
      });
    }

    return WillPopScope(
      onWillPop: () async {
        return await Get.defaultDialog(
          title: 'dialog_exit_title'.tr,
          middleText: 'dialog_exit_content'.tr,
          textConfirm: 'dialog_yes'.tr,
          textCancel: 'dialog_cancel_not_now'.tr,
          onConfirm: () => Get.back(result: true),
          onCancel: () => Get.back(result: false),
        ) as bool;
      },
      child: SplitView(
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
        /*floatingActionButton: FloatingActionButton(
          onPressed: () => _showSearchDialog(dockerController),
          child: const Icon(Icons.search),
        ),?*/
        menuBuilder: (context) => const PortariusDrawer(),
        contentBuilder: (context) => userDataController.serverList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'home_no_server'.tr,
                      style: context.textTheme.headline5,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'home_add_server'.tr,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                await Get.toNamed('/userdata/add_server');
                                // 250ms delay to allow the server to be added
                                await Future.delayed(
                                  const Duration(
                                    milliseconds: 250,
                                  ),
                                );

                                // Refresh the page
                                Get.offAllNamed('/home', arguments: true);
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : userDataController.currentServer == null
                ? Center(
                    child: Text(
                      'home_no_server_selected'.tr,
                      style: context.textTheme.headline5,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => dockerController.updateContainers(),
                    child: settingsController.listView.value
                        ? const ContainerList()
                        : const ContainerGrid(),
                  ),
      ),
    );
  }

  // this is a test, final search will not be a dialog
  // ignore: unused_element
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
            // set focus to the search field
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
                  suffixIcon: Icon(Icons.search),
                ),
                autofocus: true,
                padding: EdgeInsets.all(12),
              ),
            ),
            dropdownDecoratorProps: const DropDownDecoratorProps(
              textAlign: TextAlign.center,
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
