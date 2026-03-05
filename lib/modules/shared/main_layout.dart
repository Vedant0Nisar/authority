import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../dashboard/dashboard_view.dart';
import '../dashboard/dashboard_controller.dart';
import '../tickets/ticket_list_view.dart';
import '../tickets/map_view.dart';
import 'app_drawer.dart';

// Controller for the Main Layout
class MainLayoutController extends GetxController {
  final currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }
}

class MainLayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainLayoutController>(() => MainLayoutController());
    Get.lazyPut<DashboardController>(() => DashboardController());
    // Put ticket list controller here when created
  }
}

class MainLayoutScreen extends GetView<MainLayoutController> {
  const MainLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: const [
              DashboardScreen(),
              MapViewScreen(),
              TicketListScreen(),
            ],
          )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changePage,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.layoutDashboard),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.map),
                label: 'Map',
              ),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.listTodo),
                label: 'Tickets',
              ),
            ],
          )),
    );
  }
}
