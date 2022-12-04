// ignore_for_file: prefer_single_quotes

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:portarius/services/controllers/storage_controller.dart';

class Messages extends Translations {
  final StorageController storage = Get.find();
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': storage.languages['en_US']!,
      };
}
