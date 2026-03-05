import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import 'dashboard_controller.dart';
import '../shared/app_drawer.dart';
import '../shared/main_layout.dart';
import '../tickets/ticket_list_controller.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Authority Portal',
                style: Theme.of(context).textTheme.titleLarge),
            Text('Role: Main Body',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              icon: const Icon(LucideIcons.bell),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              GestureDetector(
                onTap: () => Get.toNamed('/search'),
                child: AbsorbPointer(
                  child: const AppTextField(
                    hintText: 'Search tickets by ID, location...',
                    prefixIcon: Icon(LucideIcons.search, size: 20),
                    readOnly: true,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Overview',
                      style: Theme.of(context).textTheme.displaySmall),
                  Obx(() => Text(
                        'Total Tickets: ${controller.totalTickets.value}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.lightSecondaryText,
                            ),
                      )),
                ],
              ),
              const SizedBox(height: 16),

              // KPI Cards Grid (2x2)
              Obx(() => GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.6,
                    children: [
                      _buildKPICard(
                        context,
                        'Open Issues',
                        controller.openTickets.value.toString(),
                        AppColors.warning,
                      ),
                      _buildKPICard(
                        context,
                        'Resolved',
                        controller.closedTickets.value.toString(),
                        AppColors.success,
                      ),
                      _buildKPICard(
                        context,
                        'Rework Rate',
                        '${controller.reworkRate.value}%',
                        AppColors.error,
                      ),
                      _buildKPICard(
                        context,
                        'High Severity',
                        controller.highSeverityTickets.value.toString(),
                        AppColors.error,
                        onTap: () {
                          // Change the bottom navigation index to Tickets (index 2)
                          if (Get.isRegistered<MainLayoutController>()) {
                            Get.find<MainLayoutController>().changePage(2);
                          }
                          // Apply the filters to the TicketListController
                          if (Get.isRegistered<TicketListController>()) {
                            final listController =
                                Get.find<TicketListController>();
                            listController.filterStatus.value = 'All';
                            listController.filterSeverity.value = 'High';
                          } else {
                            // If it's not registered yet (e.g. first click), put it with arguments
                            Get.put(TicketListController(), permanent: true);
                            final listController =
                                Get.find<TicketListController>();
                            listController.filterStatus.value = 'All';
                            listController.filterSeverity.value = 'High';
                          }
                        },
                      ),
                    ],
                  )),

              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Tickets',
                      style: Theme.of(context).textTheme.displaySmall),
                  TextButton(
                    onPressed: () {
                      // Navigate to full list
                      // Get.toNamed('/tickets');
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Recent Tickets List
              Obx(() => ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.recentTickets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final ticket = controller.recentTickets[index];
                      return AppCard(
                        onTap: () {
                          Get.toNamed('/tickets/${ticket['id']}');
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'ID: #${ticket['id']} • ${ticket['defect_type']}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(
                                    ticket['location'].toString(),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color:
                                    _getStatusColor(ticket['status'].toString())
                                        .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                ticket['status'].toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: _getStatusColor(
                                          ticket['status'].toString()),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKPICard(
      BuildContext context, String title, String value, Color color,
      {VoidCallback? onTap}) {
    return AppCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'NEW':
        return AppColors.info;
      case 'ASSIGNED':
        return AppColors.warning;
      case 'REPAIRED':
        return AppColors.gradientStart;
      case 'INSPECTED':
        return AppColors.success;
      case 'REWORK':
        return AppColors.error;
      default:
        return AppColors.lightSecondaryText;
    }
  }
}
