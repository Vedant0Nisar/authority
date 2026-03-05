import 'package:get/get.dart';
import '../../data/services/ticket_service.dart';

class TicketListController extends GetxController {
  final isLoading = true.obs;

  // Filters
  final filterStatus = 'All'.obs;
  final filterSeverity = 'All'.obs;

  final availableStatuses = [
    'All',
    'NEW',
    'ASSIGNED',
    'REPAIRED',
    'INSPECTED',
    'CLOSED',
    'REWORK'
  ];
  final availableSeverities = ['All', 'Low', 'Medium', 'High'];

  final allTickets = <Map<String, dynamic>>[].obs;

  late final TicketService _ticketService;

  @override
  void onInit() {
    super.onInit();
    _ticketService = Get.find<TicketService>();

    // Apply initial arguments if available
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args.containsKey('status')) {
        filterStatus.value = args['status'];
      }
      if (args.containsKey('severity')) {
        filterSeverity.value = args['severity'];
      }
    }

    fetchTickets();
  }

  Future<void> fetchTickets() async {
    isLoading.value = true;
    try {
      final tickets = await _ticketService.fetchAllTickets();
      allTickets.value =
          tickets.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch tickets. Pull to refresh.');
      print('Ticket List error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Computed filtered list
  List<Map<String, dynamic>> get filteredTickets {
    return allTickets.where((ticket) {
      final matchesStatus =
          filterStatus.value == 'All' || ticket['status'] == filterStatus.value;
      final matchesSeverity = filterSeverity.value == 'All' ||
          ticket['severity'] == filterSeverity.value;

      return matchesStatus && matchesSeverity;
    }).toList();
  }

  void updateStatusFilter(String status) => filterStatus.value = status;
  void updateSeverityFilter(String severity) => filterSeverity.value = severity;
}
