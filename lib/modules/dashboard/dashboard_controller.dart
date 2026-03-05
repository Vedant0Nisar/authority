import 'package:get/get.dart';
import '../../data/services/ticket_service.dart';

class DashboardController extends GetxController {
  final openTickets = 0.obs;
  final closedTickets = 0.obs;
  final reworkRate = 0.0.obs;
  final avgResolutionDays = 0.0.obs;
  final isLoadingStats = true.obs;
  final totalTickets = 0.obs;
  final highSeverityTickets = 0.obs;

  final recentTickets = <Map<String, dynamic>>[].obs;
  final isLoadingTickets = true.obs;

  late final TicketService _ticketService;

  @override
  void onInit() {
    super.onInit();
    _ticketService = Get.find<TicketService>();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    isLoadingStats.value = true;
    isLoadingTickets.value = true;

    try {
      // Fetch Stats
      final stats = await _ticketService.fetchDashboardStats();
      openTickets.value = stats['new'] ?? 0;
      closedTickets.value = stats['closed'] ?? 0;
      totalTickets.value = stats['total'] ?? 0;
      reworkRate.value = (stats['rework_rate'] ?? 0.0).toDouble();
      avgResolutionDays.value =
          (stats['avg_resolution_days'] ?? 0.0).toDouble();

      // Fetch Recent Tickets (Taking first 5 for dashboard)
      final tickets = await _ticketService.fetchAllTickets();
      recentTickets.value =
          tickets.map((e) => Map<String, dynamic>.from(e)).toList();

      // Calculate High Severity Tickets count
      highSeverityTickets.value =
          recentTickets.where((t) => t['severity'] == 'High').length;
    } catch (e) {
      Get.snackbar('Dashboard Error', 'Could not load the latest data.');
      print('Dashboard error: $e');
    } finally {
      isLoadingStats.value = false;
      isLoadingTickets.value = false;
    }
  }
}
