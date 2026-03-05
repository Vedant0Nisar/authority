import 'package:get/get.dart';
import '../../data/services/auth_service.dart';

class LoginController extends GetxController {
  final isLoading = false.obs;

  // These will be used for the textual inputs
  final emailController = ''.obs;
  final passwordController = ''.obs;
  final isPasswordVisible = false.obs;
  final formKey = null; // Will hook this up in UI

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    if (emailController.value.isEmpty || passwordController.value.isEmpty) {
      Get.snackbar('Error', 'Please enter email and password');
      return;
    }

    isLoading.value = true;

    try {
      final authService = Get.find<AuthService>();
      final success = await authService.login(
          emailController.value, passwordController.value);

      if (success) {
        Get.offAllNamed('/dashboard');
      } else {
        Get.snackbar('Login Failed',
            'Unable to authenticate. Please check credentials.');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }
}
