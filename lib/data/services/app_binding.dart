import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import 'auth_service.dart';
import 'ticket_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Core Network
    Get.put(ApiClient(), permanent: true);

    // Services
    Get.put(AuthService(Get.find<ApiClient>()), permanent: true);
    Get.put(TicketService(Get.find<ApiClient>()), permanent: true);
  }
}
