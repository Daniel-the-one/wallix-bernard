
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/t_text.dart';
import '../providers/qr_provider.dart';
import 'client_confirmation_screen.dart';
import 'retraits_screen.dart';

enum OperationType { depot, retrait }

class QrScannerScreen extends StatefulWidget {
  final OperationType operationType;

  const QrScannerScreen({super.key, required this.operationType});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _isProcessing = false;

  Future<void> _onCodeFound(String code) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final qrResponse = await context.read<QrProvider>().checkQrCode(code);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ClientConfirmationScreen(
              clientCode: qrResponse.nomComplet ?? code,
              clientInfo: qrResponse.clientInfo,
              type: widget.operationType,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ClientConfirmationScreen(
              clientCode: code,
              type: widget.operationType,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDepot = widget.operationType == OperationType.depot;

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.6),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Container(
              height: MediaQuery.of(context).size.height * 0.72,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),


                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TText(
                          isDepot ? 'depot_physique' : 'home_retrait',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!isDepot)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RetraitsScreen()),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.primaryGreen, width: 1.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.format_list_bulleted_rounded,
                                color: AppColors.primaryGreen,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  const TText(
                    'scan_title',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 28),


                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: SizedBox(
                        width: 270,
                        height: 270,
                        child: Stack(
                          children: [
                            MobileScanner(
                              onDetect: (capture) {
                                if (_isProcessing) return;
                                final List<Barcode> barcodes = capture.barcodes;
                                for (final barcode in barcodes) {
                                  if (barcode.rawValue != null) {
                                    _onCodeFound(barcode.rawValue!);
                                    break;
                                  }
                                }
                              },
                            ),



                            if (kDebugMode)
                              GestureDetector(
                                onTap: () => _onCodeFound('AGENT_TEST_CLIENT_001'),
                                child: Container(
                                  color: Colors.transparent,
                                  alignment: Alignment.center,
                                ),
                              ),
                            if (_isProcessing)
                              Container(
                                color: Colors.black54,
                                child: const Center(
                                  child: CircularProgressIndicator(color: AppColors.primaryGreen),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
