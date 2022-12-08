import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:portarius/services/controllers/logger_controller.dart';

class LogViewPage extends GetView<LoggerController> {
  const LogViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<OutputEvent> logs = controller.logs;
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
      body: Padding(
        padding: const EdgeInsets.only(
          top: 20,
          left: 5,
          right: 5,
          bottom: 20,
        ),
        child: Obx(
          () => ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  _removeColorsFromLog(logs[index].lines.join('\n')),
                  style: context.textTheme.bodySmall!.copyWith(
                    fontSize: 8,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _removeColorsFromLog(String log) {
    return log.replaceAll(RegExp('\u001B\\[[;\\d]*m'), '');
  }
}
