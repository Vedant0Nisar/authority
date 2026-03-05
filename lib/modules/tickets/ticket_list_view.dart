import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import 'ticket_list_controller.dart';
import '../shared/app_drawer.dart';

class TicketListScreen extends GetView<TicketListController> {
  const TicketListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // If controller is not yet initialized through routing, initialize here for safety within IndexedStack
    Get.put(TicketListController(), permanent: true);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('All Defect Tickets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download), // For Evidence Pack Mock
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 12),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => Get.toNamed('/search'),
                  child: AbsorbPointer(
                    child: const AppTextField(
                      hintText: 'Search tickets by ID, location...',
                      prefixIcon: Icon(Icons.search, size: 20),
                      readOnly: true,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .inputDecorationTheme
                                  .fillColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: controller.filterStatus.value,
                                isExpanded: true,
                                hint: const Text('Status'),
                                items: controller.availableStatuses
                                    .map((s) => DropdownMenuItem(
                                        value: s, child: Text(s)))
                                    .toList(),
                                onChanged: (val) =>
                                    controller.updateStatusFilter(val!),
                              ),
                            ),
                          )),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .inputDecorationTheme
                                  .fillColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: controller.filterSeverity.value,
                                isExpanded: true,
                                hint: const Text('Severity'),
                                items: controller.availableSeverities
                                    .map((s) => DropdownMenuItem(
                                        value: s, child: Text(s)))
                                    .toList(),
                                onChanged: (val) =>
                                    controller.updateSeverityFilter(val!),
                              ),
                            ),
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.fetchTickets,
              child: Obx(() {
                final tickets = controller.filteredTickets;

                if (tickets.isEmpty) {
                  return const SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: 400,
                      child: Center(
                        child: Text('No tickets found matching filters.'),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 12),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: tickets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    return AppCard(
                      onTap: () {
                        Get.toNamed('/tickets/${ticket['id']}');
                      },
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14.0, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ID: #${ticket['id']}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                          ticket['status'].toString())
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  ticket['status'].toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: _getStatusColor(
                                            ticket['status'].toString()),
                                        fontWeight: FontWeight.w400,
                                      ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${ticket['defect_type']}',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${ticket['severity']} Severity',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              Spacer(),
                              Text(
                                'Reported: ${ticket['created_at'].toString().split('T')[0]}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Divider(
                            height: 4,
                            thickness: 0.5,
                            color: AppColors.lightHintText,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on,
                                  size: 16, color: AppColors.lightHintText),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(ticket['location'].toString(),
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    );
                  },
                );
              }),
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
