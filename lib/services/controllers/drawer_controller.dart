import 'package:get/get.dart';

class PortariusDrawerController extends GetxController {
  final RxString pickedPage = '/'.obs;

  // ignore: use_setters_to_change_properties
  void setPage(String page) {
    pickedPage.value = page;
  }
}
