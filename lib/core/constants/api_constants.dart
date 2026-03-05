class ApiConstants {
  static const String baseUrl = 'http://164.52.211.208:8001/api';

  // Auth
  static const String login = '$baseUrl/auth/login';

  // Tickets
  static const String stats = '$baseUrl/tickets/stats';
  static const String tickets = '$baseUrl/tickets';

  static String ticketDetails(int id) => '$baseUrl/tickets/$id';
  static String assignTicket(int id) => '$baseUrl/tickets/$id/assign';
  static String approveTicket(int id) => '$baseUrl/tickets/$id/approve';
  static String reworkTicket(int id) => '$baseUrl/tickets/$id/rework';
  static const String contractors = '$baseUrl/tickets/contractors';
}
