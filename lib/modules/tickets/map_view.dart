import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../shared/app_drawer.dart';

class MapViewScreen extends StatelessWidget {
  const MapViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Defect Map'),
      ),
      body: Stack(
        children: [
          // Simulated Map Background
          Container(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1B2232)
                : const Color(0xFFE5E9EA),
            child: const Center(
              child: Text('Map View Implementation (Requires Maps SDK)'),
            ),
          ),

          // Floating overlay mock
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.my_location, color: AppColors.gradientStart),
                  const SizedBox(width: 12),
                  Text('Showing 42 defects in your area',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),

          // Map Marker Mock (To show styling)
          Positioned(
            top: 250,
            left: 150,
            child: GestureDetector(
              onTap: () {
                // Mock opening a marker detail
                Get.bottomSheet(
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pothole - High Severity',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text('Sector 45, Main Road',
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                              Get.toNamed('/tickets/105');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gradientStart,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('View Ticket Details'),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(Icons.warning, color: Colors.white, size: 20),
              ),
            ),
          )
        ],
      ),
    );
  }
}
