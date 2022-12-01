import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portarius/components/models/portainer/endpoint.dart';
import 'package:portarius/components/models/serverdata.dart';
import 'package:portarius/services/api.dart';
import 'package:portarius/services/controllers/userdata_controller.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ServerAddPage extends StatefulWidget {
  ServerAddPage({super.key});

  @override
  State<ServerAddPage> createState() => _ServerAddPageState();
}

class _ServerAddPageState extends State<ServerAddPage> {
  bool _hasConnectionBeenTested = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ScrollController scrollController = ScrollController();

  final PortainerApiProvider apiProvider = PortainerApiProvider();
  final UserDataController userDataController = Get.find();

  final RxList<PortainerEndpoint> endpoints = <PortainerEndpoint>[].obs;

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
                          labelText: 'URL',
                          hintText: 'https://example.com/portainer',
                          contentPadding: EdgeInsets.all(10),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a URL';
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
                      Text(
                        'If you are using a self-signed certificate, you may need to enable that in the settings.',
                        style: context.textTheme.caption,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      // explain token with uri lanch to https://docs.portainer.io/api/access
                      RichText(
                        text: TextSpan(
                          style: context.textTheme.caption,
                          children: [
                            TextSpan(
                              text: 'How to get an API token? ',
                              style: const TextStyle(
                                color: Colors.blue,
                              ),
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

                              // check if url ends with a slash
                              // if it does, remove it
                              final String url = _fixUrl(urlController.text);

                              final ServerData serverData = ServerData(
                                name: nameController.text,
                                baseUrl: url,
                                token: tokenController.text,
                                endpoint: endpoints.first.id,
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

    Get.back();

    if (testResult != null) {
      Get.snackbar(
        'Connection failed',
        testResult,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
    } else {
      endpoints.value = await apiProvider.checkEndpoints(
            url: url,
            token: tokenController.text,
          ) ??
          <PortainerEndpoint>[];

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
      Get.defaultDialog(
        title: 'Success',
        content: const Text(
          'You may now add the server.',
        ),
        textCancel: 'OK',
      );
    }
  }
}
