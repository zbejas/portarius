import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portarius/components/models/portainer/endpoint.dart';
import 'package:portarius/components/models/serverdata.dart';
import 'package:portarius/services/api.dart';
import 'package:portarius/services/controllers/drawer_controller.dart';
import 'package:portarius/services/controllers/userdata_controller.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ServerAddPage extends StatefulWidget {
  const ServerAddPage({super.key});

  @override
  State<ServerAddPage> createState() => _ServerAddPageState();
}

class _ServerAddPageState extends State<ServerAddPage> {
  bool _hasConnectionBeenTested = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  final TextEditingController localUrlController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ScrollController scrollController = ScrollController();

  final PortainerApiProvider apiProvider = PortainerApiProvider();
  final UserDataController userDataController = Get.find();

  final RxList<PortainerEndpoint> endpoints = <PortainerEndpoint>[].obs;
  final bool isLocalEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.only(top: 25, left: 10, right: 10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Text(
                        'server_add_title'.tr,
                        style: context.textTheme.headline4,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      TextFormField(
                        autofocus: true,
                        controller: nameController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onEditingComplete: () {
                          FocusScope.of(context).nextFocus();
                        },
                        decoration: InputDecoration(
                          labelText: 'server_add_name_label'.tr,
                          hintText: 'server_add_name_hint'.tr,
                          contentPadding: EdgeInsets.all(10),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'server_add_name_empty'.tr;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: urlController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onEditingComplete: () {
                          FocusScope.of(context).nextFocus();
                        },
                        decoration: InputDecoration(
                          labelText: 'server_add_url_label'.tr,
                          hintText: 'server_add_url_hint'.tr,
                          contentPadding: EdgeInsets.all(10),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'server_add_url_empty'.tr;
                          }

                          if (!Uri.tryParse(value)!.isAbsolute) {
                            return 'server_add_url_invalid'.tr;
                          }

                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        enabled: isLocalEnabled,
                        controller: localUrlController,
                        onEditingComplete: () {
                          FocusScope.of(context).nextFocus();
                        },
                        decoration: InputDecoration(
                          labelText: 'server_add_local_url_label'.tr,
                          hintText: 'server_add_local_url_hint'.tr,
                          contentPadding: EdgeInsets.all(10),
                        ),
                        validator: (value) {
                          if (!isLocalEnabled || value!.isEmpty) {
                            return null;
                          }

                          if (!Uri.tryParse(value)!.isAbsolute) {
                            return 'server_add_local_url_invalid'.tr;
                          }

                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: tokenController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onEditingComplete: () {
                          // hide keyboard
                          if (formKey.currentState!.validate()) {
                            FocusScope.of(context).unfocus();
                            _testConnection();
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'server_add_token_label'.tr,
                          hintText: 'server_add_token_hint'.tr,
                          contentPadding: EdgeInsets.all(10),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'server_add_token_empty'.tr;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'server_add_info_self_signed'.trParams(
                                {
                                  'page': '',
                                },
                              ),
                              style: TextStyle(
                                color:
                                    Theme.of(context).textTheme.caption!.color,
                              ),
                            ),
                            TextSpan(
                              text: '${'settings'.tr}.',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  final PortariusDrawerController
                                      drawerController = Get.find();
                                  // if any text controller has any value, alert the user that they will be lost
                                  if (nameController.text.isNotEmpty ||
                                      urlController.text.isNotEmpty ||
                                      localUrlController.text.isNotEmpty ||
                                      tokenController.text.isNotEmpty) {
                                    Get.defaultDialog(
                                      title: 'dialog_server_add_exit'.tr,
                                      middleText:
                                          'dialog_server_add_exit_content'.tr,
                                      textConfirm: 'dialog_yes'.tr,
                                      textCancel: 'dialog_cancel_not_now'.tr,
                                      onConfirm: () {
                                        drawerController.setPage('/settings');
                                        Get.offAllNamed('/settings');
                                      },
                                    );
                                  } else {
                                    drawerController.setPage('/settings');
                                    Get.offAllNamed('/settings');
                                  }
                                },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      // explain token with uri lanch to https://docs.portainer.io/api/access
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: context.theme.primaryColor,
                          ),
                          children: [
                            TextSpan(
                              text: 'server_add_info_api_token'.tr,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  launchUrlString(
                                    'https://docs.portainer.io/api/access',
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _testConnection,
                            child: Text('server_add_button_test'.tr),
                          ),
                          ElevatedButton(
                            onPressed: _hasConnectionBeenTested
                                ? () async {
                                    if (!formKey.currentState!.validate()) {
                                      return;
                                    }
                                    if (!_hasConnectionBeenTested) {
                                      Get.snackbar(
                                        'snackbar_server_add_not_tested_title'
                                            .tr,
                                        'snackbar_server_add_not_tested_text'
                                            .tr,
                                        snackPosition: SnackPosition.top,
                                        backgroundColor:
                                            context.theme.errorColor,
                                        colorText: Get.theme.snackBarTheme
                                            .actionTextColor,
                                        margin: const EdgeInsets.all(10),
                                      );
                                      return;
                                    }
                                    if (Get.isSnackbarOpen) {
                                      await Get.closeCurrentSnackbar();
                                    }

                                    final ServerData serverData = ServerData(
                                      name: nameController.text,
                                      baseUrl: _fixUrl(urlController.text),
                                      token: tokenController.text,
                                      endpoint: endpoints.first.id,
                                      localUrl:
                                          _fixUrl(localUrlController.text),
                                    );

                                    if (Get.isSnackbarOpen) {
                                      await Get.closeCurrentSnackbar();
                                      await Future<void>.delayed(
                                        const Duration(milliseconds: 100),
                                      );
                                    }
                                    Get.back();
                                    userDataController.addServer(serverData);
                                  }
                                : null,
                            child: Text('server_add_button_save'.tr),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fixUrl(String url) {
    return url.endsWith('/')
        ? url.substring(
            0,
            url.length - 1,
          )
        : url;
  }

  Future<void> _showLoadingDialog() async {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
      await Future<void>.delayed(
        const Duration(milliseconds: 100),
      );
    }

    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _testConnection() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    _hasConnectionBeenTested = false;

    _showLoadingDialog();

    final String url = _fixUrl(urlController.text);

    final String? testResult = await apiProvider.testConnection(
      url: url,
      token: tokenController.text,
    );

    if (Get.isSnackbarOpen) {
      await Get.closeCurrentSnackbar();
    }

    if (testResult != null) {
      Get.back();
      Get.snackbar(
        'snackbar_server_add_test_error_title'.tr,
        'snackbar_server_add_test_error_content'.trParams(
          {
            'error': testResult,
            'name': nameController.text,
          },
        ),
        snackPosition: SnackPosition.bottom,
        backgroundColor: context.theme.errorColor,
        colorText: Get.theme.scaffoldBackgroundColor,
        margin: const EdgeInsets.all(10),
      );
    } else {
      // Test local connection
      final String localUrl = _fixUrl(localUrlController.text);
      String? localTestResult;

      if (localUrl.isNotEmpty) {
        localTestResult = await apiProvider.testConnection(
          url: localUrl,
          token: tokenController.text,
        );
      }

      endpoints.value = await apiProvider.checkEndpoints(
            url: url,
            token: tokenController.text,
          ) ??
          <PortainerEndpoint>[];
      if (Get.isSnackbarOpen) {
        await Get.closeCurrentSnackbar();
      }

      Get.back();
      if (endpoints.isEmpty) {
        Get.snackbar(
          'snackbar_server_add_test_no_endoint_title'.tr,
          'snackbar_server_add_test_no_endoint_content'.tr,
          snackPosition: SnackPosition.bottom,
          backgroundColor: context.theme.errorColor,
          colorText: Get.theme.scaffoldBackgroundColor,
          margin: const EdgeInsets.all(10),
        );
      }

      _hasConnectionBeenTested = true;
      setState(() {});
      if (localTestResult == null) {
        Get.defaultDialog(
          title: 'dialog_server_add_test_success_title'.tr,
          content: Text(
            'dialog_server_add_test_success_content'.trParams(
              {
                'url': url,
              },
            ),
            textAlign: TextAlign.center,
          ),
          textCancel: 'dialog_ok'.tr,
        );
      } else {
        Get.defaultDialog(
          title: 'snackbar_server_add_test_local_warning_title'.tr,
          content: Text(
            'snackbar_server_add_test_local_warning_content'.tr,
            textAlign: TextAlign.center,
          ),
          textCancel: 'dialog_ok'.tr,
        );
      }
    }
  }
}
