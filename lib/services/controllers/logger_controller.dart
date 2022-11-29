import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class LoggerController extends GetxController {
  final RxList<OutputEvent> _log = <OutputEvent>[].obs;

  final Logger logger = Logger(
    output: ConsoleOutput(),
    printer: PrettyPrinter(
      printTime: true,
    ),
    level: Level.debug,
  );

  void addLog(OutputEvent log) {
    // If there is more than 100 logs, remove the oldest one
    if (_log.length > 100) {
      _log.removeAt(0);
    }

    _log.add(log);
  }

  List<OutputEvent> get logs => _log;

  void logWriterCallback(String text, {bool isError = false}) {
    if (isError) {
      logger.e(text);
    } else {
      logger.d(text);
    }
  }
}

class ConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    final LoggerController loggerController = Get.find();

    loggerController.addLog(event);

    if (!kDebugMode) return;

    // Print to console
    for (final String line in event.lines) {
      // ignore this since debug is checked above
      // ignore: avoid_print
      print(line);
    }
  }

  // add log file output maybe?
}
