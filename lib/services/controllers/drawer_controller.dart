import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class PortariusDrawerController extends GetxController {
  final RxString pickedPage = '/'.obs;

  void setPage(String page) {
    pickedPage.value = page;
  }
}
