import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/services/ticket_service.dart';

class TicketDetailController extends GetxController {
  final isLoading = true.obs;
  final ticketId = 0.obs;

  final Rx<Map<String, dynamic>> ticket = Rx<Map<String, dynamic>>({});

  final selectedContractor = ''.obs;
  final availableContractors = <String>[].obs;

  final isAssigning = false.obs;
  final isContractorsLoading = false.obs;
  final isApproving = false.obs;
  final isRejecting = false.obs;

  late final TicketService _ticketService;

  @override
  void onInit() {
    super.onInit();
    _ticketService = Get.find<TicketService>();

    // Attempt to grab ID from GetX parameters (e.g., Get.toNamed('/tickets/105'))
    final idParam = Get.parameters['id'];
    if (idParam != null && int.tryParse(idParam) != null) {
      ticketId.value = int.parse(idParam);
      fetchTicketDetails();
    } else {
      Get.back();
      Get.snackbar('Error', 'Invalid Ticket ID');
    }
  }

  Future<void> fetchTicketDetails() async {
    isLoading.value = true;
    try {
      final data = await _ticketService.fetchTicketById(ticketId.value);
      ticket.value = data;

      // If ticket is NEW, pre-load the contractors list
      if (ticket.value['status'] == 'NEW') {
        _fetchContractors();
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not load ticket details.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchContractors() async {
    isContractorsLoading.value = true;
    try {
      final list = await _ticketService.fetchContractors();
      availableContractors.value =
          list.map((e) => e['name'].toString()).toList();
    } catch (e) {
      print('Failed to load contractors for dropdown');
    } finally {
      isContractorsLoading.value = false;
    }
  }

  void assignContractor() async {
    if (selectedContractor.value.isEmpty) {
      Get.snackbar('Error', 'Please select a contractor to assign');
      return;
    }

    isAssigning.value = true;
    try {
      final success = await _ticketService.assignTicket(
        ticketId.value,
        selectedContractor.value,
      );
      if (success) {
        Get.back(); // Close Modal
        Get.snackbar(
          'Success',
          'Ticket assigned to ${selectedContractor.value}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
          colorText: Get.theme.colorScheme.primary,
        );

        // Success - Navigate back to ticket list as it's no longer "NEW"
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.of(Get.context!).pop();
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Assignment failed');
    } finally {
      isAssigning.value = false;
    }
  }

  final isPaymentSuccessful = false.obs;
  String generatedTxnId = '';
  String paymentDate = '';

  void processPayment() async {
    if (isApproving.value) return; // Prevent multiple taps
    isApproving.value = true;

    // Simulate payment processing UI spinner requirement (from doc)
    await Future.delayed(const Duration(seconds: 2, milliseconds: 500));

    try {
      final success = await _ticketService.approveTicket(ticketId.value);
      if (success) {
        generatedTxnId =
            'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
        final now = DateTime.now();
        final hour =
            now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
        final amPm = now.hour >= 12 ? 'PM' : 'AM';
        paymentDate =
            '${now.month}/${now.day}/${now.year}, ${hour}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} $amPm';

        isPaymentSuccessful.value = true;
        fetchTicketDetails(); // Reload to show timeline
      } else {
        if (Get.isDialogOpen == true) {
          Get.back(); // safely close dialog
        }
        Get.snackbar('Error', 'Approval failed');
      }
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back(); // safely close dialog
      }
      Get.snackbar('Error', 'Approval failed');
    } finally {
      isApproving.value = false;
    }
  }

  void closePaymentSuccess() {
    if (Get.isDialogOpen == true) {
      Get.back(); // close dialog
    }
    // Navigate back to the ticket list as the ticket is now closed
    Future.delayed(const Duration(milliseconds: 300), () {
      Get.back(); // pop TicketDetailScreen
    });
  }

  void rejectTicket() async {
    isRejecting.value = true;
    try {
      final success = await _ticketService.rejectTicket(ticketId.value);
      if (success) {
        Get.snackbar('Success', 'Ticket Sent for Rework',
            snackPosition: SnackPosition.TOP);
        Future.delayed(const Duration(milliseconds: 100), () {
          Navigator.of(Get.context!).pop();
        });
        fetchTicketDetails();
      }
    } catch (e) {
      Get.snackbar('Error', 'Rejection failed');
    } finally {
      isRejecting.value = false;
    }
  }

  Future<void> generateAndDownloadPdf() async {
    if (ticket.value.isEmpty) {
      Get.snackbar('Error', 'No ticket data available to generate PDF');
      return;
    }

    final t = ticket.value;
    final pdf = pw.Document();

    // Helper to decode Base64 strings to pw.MemoryImage
    pw.MemoryImage? decodeImage(dynamic base64Data) {
      if (base64Data != null && base64Data.toString().isNotEmpty) {
        try {
          final cleanString = base64Data
              .toString()
              .replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '');
          final bytes = base64Decode(cleanString);
          return pw.MemoryImage(bytes);
        } catch (e) {
          print('Error decoding image for PDF: $e');
        }
      }
      return null;
    }

    final beforeImage = decodeImage(t['before_image']);
    final aiImage = decodeImage(t['ai_processed_image']);
    final afterImage = decodeImage(t['after_image']);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(level: 0, child: pw.Text('Ticket Details - #${t['id']}')),
            pw.SizedBox(height: 20),
            pw.Text('Status: ${t['status']}'),
            pw.Text('Type: ${t['defect_type']}'),
            pw.Text('Severity: ${t['severity']}'),
            pw.Text('Location: ${t['location']}'),
            if (t['contractor'] != null)
              pw.Text('Contractor: ${t['contractor']}'),
            pw.SizedBox(height: 20),

            // Images Section
            pw.Header(level: 1, child: pw.Text('Evidence Images')),
            pw.SizedBox(height: 10),

            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (beforeImage != null)
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          pw.Text('Original'),
                          pw.SizedBox(height: 5),
                          pw.Image(beforeImage,
                              height: 150, fit: pw.BoxFit.contain),
                        ],
                      ),
                    ),
                  if (aiImage != null)
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          pw.Text('AI Mask'),
                          pw.SizedBox(height: 5),
                          pw.Image(aiImage,
                              height: 150, fit: pw.BoxFit.contain),
                        ],
                      ),
                    ),
                ]),

            pw.SizedBox(height: 15),
            if (afterImage != null)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Repair Evidence (After)'),
                  pw.SizedBox(height: 5),
                  pw.Image(afterImage, height: 150, fit: pw.BoxFit.contain),
                  pw.SizedBox(height: 15),
                ],
              ),

            pw.SizedBox(height: 20),
            pw.Header(level: 1, child: pw.Text('Activity Timeline')),
            ...(t['activity_timeline'] as List)
                .map((timelineItem) => pw.Padding(
                    padding: pw.EdgeInsets.only(bottom: 8.0),
                    child: pw.Text(
                        '${timelineItem['timestamp'].toString().split('T')[0]} - ${timelineItem['action']} (By ${timelineItem['user']})')))
                .toList(),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Ticket_${t['id']}_Report.pdf',
    );
  }
}
