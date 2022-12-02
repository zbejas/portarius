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
                        'Input server details',
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
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          hintText: 'My server',
                          contentPadding: EdgeInsets.all(10),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a name';
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
                        decoration: const InputDecoration(
                          labelText: 'Base URL',
                          hintText: 'https://example.com/portainer',
                          contentPadding: EdgeInsets.all(10),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a base URL';
                          }

                          if (!Uri.tryParse(value)!.isAbsolute) {
                            return 'Please enter a valid URL';
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
                        decoration: const InputDecoration(
                          labelText: 'Local URL',
                          hintText: '(optional) http://192.168.x.x/portainer',
                          contentPadding: EdgeInsets.all(10),
                        ),
                        validator: (value) {
                          if (!isLocalEnabled || value!.isEmpty) {
                            return null;
                          }

                          if (!Uri.tryParse(value)!.isAbsolute) {
                            return 'Please enter a valid URL';
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
                        decoration: const InputDecoration(
                          labelText: 'API token',
                          hintText: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
                          contentPadding: EdgeInsets.all(10),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter an API key';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      /*Text(
                        'If you are using a self-signed certificate, you may need to enable that in the settings.',
                        style: context.textTheme.caption,
                        textAlign: TextAlign.center,
                      ),*/
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'If you are using a self-signed certificate, you may need to enable that in the ',
                              style: TextStyle(
                                color:
                                    Theme.of(context).textTheme.caption!.color,
                              ),
                            ),
                            TextSpan(
                              text: 'settings.',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  PortariusDrawerController drawerController =
                                      Get.find();
                                  // if any text controller has any value, alert the user that they will be lost
                                  if (nameController.text.isNotEmpty ||
                                      urlController.text.isNotEmpty ||
                                      localUrlController.text.isNotEmpty ||
                                      tokenController.text.isNotEmpty) {
                                    Get.defaultDialog(
                                      title: 'Are you sure?',
                                      middleText:
                                          'Any unsaved changes will be lost.',
                                      textConfirm: 'Yes',
                                      textCancel: 'No',
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
                              text: 'How to get an API token? ',
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
                            child: const Text('Test connection'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) {
                                return;
                              }
                              if (!_hasConnectionBeenTested) {
                                Get.snackbar(
                                  'Connection not tested',
                                  'Please test the connection before adding the server',
                                  snackPosition: SnackPosition.TOP,
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
                                localUrl: _fixUrl(localUrlController.text),
                              );

                              if (Get.isSnackbarOpen) {
                                await Get.closeCurrentSnackbar();
                                await Future<void>.delayed(
                                  const Duration(milliseconds: 100),
                                );
                              }
                              Get.back();
                              userDataController.addServer(serverData);
                            },
                            child: const Text('Add'),
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

  void _testConnection() async {
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
        'Connection failed',
        testResult,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
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
          'No endpoints found',
          'Please create an endpoint in Portainer',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
        );
      }

      _hasConnectionBeenTested = true;
      if (localTestResult == null) {
        Get.defaultDialog(
          title: 'Success',
          content: const Text(
            'You may now add the server.',
          ),
          textCancel: 'OK',
        );
      } else {
        Get.defaultDialog(
          title: 'Warning',
          content: const Text(
            'The base URL is accessible, but the local URL is not. '
            'This means that local the app may be able to switch to the local URL when available.'
            '\n\nYou can still add the server, since the base URL is accessible.',
            textAlign: TextAlign.center,
          ),
          textCancel: 'Continue',
        );
      }
    }
  }
}
