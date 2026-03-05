import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor:
          isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard,
      child: Column(
        children: [
          // Top Section (User Info)
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color:
                  isDark ? AppColors.darkBackground : AppColors.lightBackground,
            ),
            accountName: Text(
              'User Name', // In a real app, fetch from user data
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            accountEmail: Text(
              'user@example.com',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkSecondaryText
                        : AppColors.lightSecondaryText,
                  ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.gradientStart.withOpacity(0.1),
              child: const Icon(
                LucideIcons.user,
                color: AppColors.gradientStart,
                size: 32,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Middle Section (Navigation Tabs)
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: LucideIcons.userCircle,
                  title: 'Profile',
                  onTap: () {
                    Get.back();
                    // Navigate to profile screen
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: LucideIcons.settings,
                  title: 'Settings',
                  onTap: () {
                    Get.back();
                    // Navigate to settings screen
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: LucideIcons.helpCircle,
                  title: 'Help / Support',
                  onTap: () {
                    Get.back();
                    // Navigate to help screen
                  },
                ),
              ],
            ),
          ),

          // Bottom Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color:
                      isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
              ),
            ),
            child: Column(
              children: [
                // Dark Mode Toggle
                ListTile(
                  leading: Icon(
                    isDark ? LucideIcons.moon : LucideIcons.sun,
                    color: isDark
                        ? AppColors.darkPrimaryText
                        : AppColors.lightPrimaryText,
                  ),
                  title: Text(
                    isDark ? 'Dark Mode' : 'Light Mode',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  trailing: Switch(
                    value: isDark,
                    activeColor: AppColors.gradientStart,
                    onChanged: (value) {
                      Get.changeThemeMode(
                          value ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),
                ),
                // Logout Button
                ListTile(
                  leading: const Icon(
                    LucideIcons.logOut,
                    color: AppColors.error,
                  ),
                  title: Text(
                    'Logout',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  onTap: () async {
                    Get.back(); // close drawer
                    final authService = Get.find<AuthService>();
                    await authService.logout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(
        icon,
        color:
            isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      onTap: onTap,
    );
  }
}
