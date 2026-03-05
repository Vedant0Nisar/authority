import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'data/services/app_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await GetStorage.init();

  // Use FlutterSecureStorage for sensitive tokens
  const storage = FlutterSecureStorage();

  // Read token to determine initial route naturally
  final token = await storage.read(key: 'jwt_token');
  final String initialRoute =
      (token != null && token.isNotEmpty) ? Routes.DASHBOARD : Routes.LOGIN;

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Authority App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialBinding: AppBinding(),

      // Let splash controller take over here natively instead
      // initialRoute: Routes.SPLASH if we had one yet.
      initialRoute: initialRoute,

      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
