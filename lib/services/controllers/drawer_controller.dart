import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class PortariusDrawerController extends GetxController {
  final RxString pickedPage = '/'.obs;

  void setPage(String page) {
    pickedPage.value = page;
  }
}
