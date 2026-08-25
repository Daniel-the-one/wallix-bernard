
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/transaction_item.dart';
import '../theme/app_colors.dart';
import '../widgets/t_text.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionItem item;

  const TransactionDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isDepot = item.type == TransactionType.depot;
    final String formattedDate = DateFormat("dd/MM/yyyy 'à' HH:mm").format(item.date);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const TText(
          'history_title',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),


              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDepot
                        ? AppColors.primaryGreen.withValues(alpha: 0.15)
                        : Colors.red.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDepot ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    color: isDepot ? AppColors.primaryGreen : Colors.red,
                    size: 40,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TText(
                item.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                item.amountShow,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDepot ? AppColors.primaryGreen : Colors.red,
                ),
              ),

              const SizedBox(height: 32),


              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.person_outline, color: Colors.black54, size: 26),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(1.5),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: AppColors.primaryGreen,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.subtitle.isNotEmpty ? item.subtitle : TText.of(context).translate('client_label'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TText(
                          'client_verified',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),


              _buildDetailRow(context, 'reference_label', item.id.isNotEmpty ? item.id : item.keyDepot ?? 'N/A'),
              const SizedBox(height: 14),
              _buildDetailRow(context, 'datetime_label', formattedDate),
              const SizedBox(height: 14),
              _buildDetailRow(context, 'status_label', item.status),
              if (item.montantTotal != null && item.montantTotal! > 0) ...[
                const SizedBox(height: 14),
                _buildDetailRow(context, 'amount_total', '${item.montantTotal} XOF'),
              ],

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: const TText(
                    'close',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String labelKey, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TText(
          labelKey,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black45,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
