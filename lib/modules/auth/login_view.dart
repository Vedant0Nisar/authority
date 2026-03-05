import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_text_field.dart';
import 'login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // App Logo or Banner Placeholder
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.gradientStart.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.shieldCheck,
                    size: 75,
                    color: AppColors.gradientStart,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              Text(
                'Welcome Back!',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to access the Authority Portal.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),

              // Login Form
              AppTextField(
                hintText: 'Email Address',
                prefixIcon: const Icon(LucideIcons.mail, size: 20),
                keyboardType: TextInputType.emailAddress,
                onChanged: (val) => controller.emailController.value = val,
              ),
              const SizedBox(height: 16),

              Obx(() => AppTextField(
                    hintText: 'Password',
                    obscureText: !controller.isPasswordVisible.value,
                    prefixIcon: const Icon(LucideIcons.lock, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? LucideIcons.eyeOff
                            : LucideIcons.eye,
                        size: 20,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                    onChanged: (val) =>
                        controller.passwordController.value = val,
                  )),

              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Forgot password logic here
                  },
                  child: Text(
                    'Forgot Password?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.gradientStart,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Obx(() => AppPrimaryButton(
                    text: 'Sign Into Portal',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.login,
                  )),

              const SizedBox(height: 48),
              Center(
                child: Text(
                  'Demo Accounts Information:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Main Body: admin@gov.in / adminpassword123\nInspector: inspector@gov.in / pass123\nContractor: contractor@gov.in / pass123',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
