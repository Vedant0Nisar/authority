abstract class Routes {
  static const LOGIN = '/login';
  static const DASHBOARD = '/dashboard';
  static const TICKET_LIST = '/tickets';
  static const MAP_VIEW = '/map';
  static const SEARCH = '/search';

  static String ticketDetails(int id) => '/tickets/$id';
}
