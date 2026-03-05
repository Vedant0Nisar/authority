import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';

class TicketService {
  final ApiClient _apiClient;

  TicketService(this._apiClient);

  Future<Map<String, dynamic>> fetchDashboardStats() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.stats);
      return response.data;
    } catch (e) {
      throw Exception('Failed to load dashboard statistics: $e');
    }
  }

  Future<List<dynamic>> fetchAllTickets() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.tickets);
      return response.data;
    } catch (e) {
      throw Exception('Failed to load tickets: $e');
    }
  }

  Future<Map<String, dynamic>> fetchTicketById(int id) async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.ticketDetails(id));
      return response.data;
    } catch (e) {
      throw Exception('Failed to load ticket details: $e');
    }
  }

  Future<List<dynamic>> fetchContractors() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.contractors);
      return response.data;
    } catch (e) {
      throw Exception('Failed to load contractors: $e');
    }
  }

  Future<bool> assignTicket(int id, String contractorName) async {
    try {
      final response = await _apiClient.dio.put(
        ApiConstants.assignTicket(id),
        data: {'contractor': contractorName},
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to assign ticket: $e');
    }
  }

  Future<bool> approveTicket(int id) async {
    try {
      final response = await _apiClient.dio.put(ApiConstants.approveTicket(id));
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to approve ticket: $e');
    }
  }

  Future<bool> rejectTicket(int id) async {
    try {
      final response = await _apiClient.dio
          .put(ApiConstants.reworkTicket(id), data: {'role': 'Main Body'});
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to reject ticket: $e');
    }
  }
}
