import 'package:get/get.dart';
import '../../data/services/ticket_service.dart';

class AppSearchController extends GetxController {
  final searchQuery = ''.obs;
  final isLoading = false.obs;

  final allTickets = <Map<String, dynamic>>[].obs;
  late final TicketService _ticketService;

  @override
  void onInit() {
    super.onInit();
    _ticketService = Get.find<TicketService>();
    _fetchAllTicketsForSearch();

    // Auto-focus logic can be handled by the Search TextField
  }

  Future<void> _fetchAllTicketsForSearch() async {
    isLoading.value = true;
    try {
      final tickets = await _ticketService.fetchAllTickets();
      allTickets.value =
          tickets.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch tickets for search.');
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get searchResults {
    if (searchQuery.value.isEmpty) {
      return [];
    }
    final query = searchQuery.value.toLowerCase();

    return allTickets.where((ticket) {
      final matchId = ticket['id'].toString().contains(query);
      final matchLocation =
          ticket['location']?.toString().toLowerCase().contains(query) ?? false;
      final matchType =
          ticket['defect_type']?.toString().toLowerCase().contains(query) ??
              false;

      return matchId || matchLocation || matchType;
    }).toList();
  }

  void updateSearch(String query) => searchQuery.value = query;
}
