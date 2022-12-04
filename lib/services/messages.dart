// ignore_for_file: prefer_single_quotes

import 'package:get/get.dart';
import 'package:portarius/services/controllers/storage_controller.dart';

class Messages extends Translations {
  final StorageController storage = Get.find();
  @override
  Map<String, Map<String, String>> get keys => storage.languages;
}
