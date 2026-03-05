import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_card.dart';
import 'ticket_detail_controller.dart';

class TicketDetailScreen extends GetView<TicketDetailController> {
  const TicketDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Details'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.download),
            onPressed: () => controller.generateAndDownloadPdf(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final ticket = controller.ticket.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Setup
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ticket #${ticket['id']}',
                            style: Theme.of(context).textTheme.displaySmall),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(ticket['status'].toString())
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            ticket['status'].toString(),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: _getStatusColor(
                                          ticket['status'].toString()),
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                        context, 'Type', ticket['defect_type'].toString()),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                        context, 'Severity', ticket['severity'].toString()),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                        context, 'Location', ticket['location'].toString()),
                    if (ticket['contractor'] != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(context, 'Contractor',
                          ticket['contractor'].toString()),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Panels
              _buildActionPanels(context),

              const SizedBox(height: 24),

              // Images Section
              Text('Evidence & AI Analysis',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildImage(
                        context, 'Original', ticket['before_image']),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildImage(
                        context, 'AI Mask', ticket['ai_processed_image']),
                  ),
                ],
              ),
              if (ticket['status'] == 'REPAIRED' ||
                  ticket['status'] == 'INSPECTED' ||
                  ticket['status'] == 'CLOSED') ...[
                const SizedBox(height: 16),
                _buildImage(
                    context, 'Repair Evidence (After)', ticket['after_image']),
              ],

              const SizedBox(height: 32),

              _buildTimeline(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActionPanels(BuildContext context) {
    if (controller.ticket.value['status'] == 'NEW') {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assign Contractor',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('This ticket is awaiting assignment to begin repairs.',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            AppPrimaryButton(
              onPressed: () => _showAssignmentModal(context),
              text: 'Assign Now',
            ),
          ],
        ),
      );
    }

    if (controller.ticket.value['status'] == 'INSPECTED') {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Final Verification',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
                'Inspection has been completed. Verify the fixes and close the ticket to release payment.',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Obx(() => AppPrimaryButton(
                  isLoading: controller.isApproving.value,
                  onPressed: controller.isRejecting.value
                      ? null
                      : controller.approveTicket,
                  text: 'Verify & Close',
                )),
            const SizedBox(height: 16),
            Obx(() => AppSecondaryButton(
                  onPressed: (controller.isApproving.value ||
                          controller.isRejecting.value)
                      ? null
                      : controller.rejectTicket,
                  text: controller.isRejecting.value
                      ? 'Sending...'
                      : 'Reject & Send for Rework',
                )),
          ],
        ),
      );
    }

    return const SizedBox.shrink(); // No actions for other states
  }

  void _showAssignmentModal(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assign Contractor',
                style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 24),

            // Select Contractor Section
            Text('Select Contractor',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Obx(() {
              if (controller.isContractorsLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).inputDecorationTheme.fillColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedContractor.value.isEmpty
                        ? null
                        : controller.selectedContractor.value,
                    isExpanded: true,
                    hint: const Text('Choose a contractor'),
                    items: controller.availableContractors
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) =>
                        controller.selectedContractor.value = val!,
                  ),
                ),
              );
            }),

            const SizedBox(height: 32),

            // Action Button
            Obx(() => AppPrimaryButton(
                  onPressed: controller.assignContractor,
                  isLoading: controller.isAssigning.value,
                  text: 'Confirm Assignment',
                ))
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildTimeline(BuildContext context) {
    final timeline = controller.ticket.value['activity_timeline'] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Activity Timeline',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: timeline.length,
            itemBuilder: (context, index) {
              final item = timeline[index];
              final isLast = index == timeline.length - 1;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.gradientStart,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 40,
                          color: AppColors.lightDivider,
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['action'],
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(
                              '${item['timestamp'].toString().split('T')[0]} • By ${item['user']}',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImage(BuildContext context, String title, dynamic base64Data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).inputDecorationTheme.fillColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          clipBehavior: Clip.antiAlias,
          child: (base64Data != null && base64Data.toString().isNotEmpty)
              ? FutureBuilder<Uint8List>(
                  future: compute((String s) {
                    final cleanString =
                        s.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '');
                    return base64Decode(cleanString);
                  }, base64Data.toString()),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const Center(
                        child: Icon(LucideIcons.imageOff,
                            size: 40, color: AppColors.error),
                      );
                    }
                    return Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    );
                  },
                )
              : const Center(
                  child: Icon(LucideIcons.image,
                      size: 40, color: AppColors.lightHintText),
                ),
        ),
        const SizedBox(height: 8),
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.lightHintText)),
        ),
        Expanded(
          child: Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500)),
        ),
      ],
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
