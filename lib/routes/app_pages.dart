import 'package:get/get.dart';
import 'app_routes.dart';

// Import screens and bindings
import '../modules/auth/login_view.dart';
import '../modules/auth/login_binding.dart';
import '../modules/shared/main_layout.dart';
import '../modules/tickets/ticket_detail_view.dart';
import '../modules/tickets/ticket_detail_binding.dart';
import '../modules/search/search_view.dart';
import '../modules/search/search_binding.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const MainLayoutScreen(),
      binding: MainLayoutBinding(),
    ),
    GetPage(
      name: '/tickets/:id',
      page: () => const TicketDetailScreen(),
      binding: TicketDetailBinding(),
    ),
    GetPage(
      name: Routes.SEARCH,
      page: () => const SearchScreen(),
      binding: SearchBinding(),
    ),
  ];
}
