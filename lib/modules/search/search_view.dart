import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';
import 'search_controller.dart';

class SearchScreen extends GetView<AppSearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppTextField(
          hintText: 'Search tickets by ID, location, or type...',
          prefixIcon: const Icon(LucideIcons.search, size: 20),
          autofocus: true,
          onChanged: controller.updateSearch,
        ),
        titleSpacing: 0,
        actions: [
          const SizedBox(width: 16),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.searchQuery.value.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.search,
                    size: 64, color: AppColors.lightHintText.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text('Type to start searching...',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: AppColors.lightSecondaryText)),
              ],
            ),
          );
        }

        final results = controller.searchResults;

        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.frown,
                    size: 64, color: AppColors.lightHintText.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text('No results found.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: AppColors.lightSecondaryText)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: results.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final ticket = results[index];
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
                        Text('ID: #${ticket['id']} • ${ticket['defect_type']}',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                          ticket['location'].toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(ticket['status'].toString())
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ticket['status'].toString(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getStatusColor(ticket['status'].toString()),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      }),
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
