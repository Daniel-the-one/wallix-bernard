
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../model/retrait_item.dart';
import '../providers/transaction_provider.dart';
import '../services/amount_formatter.dart';
import '../widgets/t_text.dart';

class RetraitsScreen extends StatefulWidget {
  const RetraitsScreen({super.key});

  @override
  State<RetraitsScreen> createState() => _RetraitsScreenState();
}

class _RetraitsScreenState extends State<RetraitsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {

      final provider = context.read<TransactionProvider>();
      if (provider.retraits.isEmpty) {
        provider.fetchRetraits();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshRetraits() async {
    await context.read<TransactionProvider>().fetchRetraits();
  }

  void _cancelRetrait(RetraitItem item) {
    final TextEditingController pinController = TextEditingController();

    final transactionProvider = context.read<TransactionProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const TText('cancel_op', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TText('cancel_confirm'),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                counterText: '',
                hintText: TText.of(context).translate('pin_code'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const TText('cancel', style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final res = await transactionProvider.cancelRetrait(
                keyRetraitP: item.keyRetrait,
                codeSecurite: pinController.text,
              );
              if (!mounted) return;
              if (res.isSuccess) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: TText('retrait_cancelled'), backgroundColor: AppColors.primaryGreen),
                );

                await transactionProvider.fetchAllData();
              } else {
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: TText('cancel_failed'), backgroundColor: Colors.red),
                );
              }
            },
            child: const TText('confirm', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final List<RetraitItem> retraits = transactionProvider.retraits;
    final bool isLoading = transactionProvider.isLoading;

    final filteredList = retraits.where((r) {
      final query = _searchQuery.toLowerCase();
      return r.clientName.toLowerCase().contains(query) ||
          r.clientPhone.contains(query) ||
          r.reference.toLowerCase().contains(query);
    }).toList();

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
          'retraits_title',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black, size: 24),
            onPressed: _refreshRetraits,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshRetraits,
              color: AppColors.primaryGreen,
              child: isLoading && retraits.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                  : filteredList.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(
                              child: TText(
                                'retraits_empty',
                                style: TextStyle(color: Colors.black45, fontSize: 14),
                              ),
                            ),
                          ],
                        )
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            ...filteredList.map(_buildRetraitTile),
                            const SizedBox(height: 40),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: TText.of(context).translate('retrait_search_hint'),
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  String _statusLabel(RetraitStatus status) {
    switch (status) {
      case RetraitStatus.accepte:
        return TText.of(context).translate('status_accepte');
      case RetraitStatus.refuse:
        return TText.of(context).translate('status_refuse');
      case RetraitStatus.annule:
        return TText.of(context).translate('status_annule');
      case RetraitStatus.initialise:
        return TText.of(context).translate('status_initialise');
      case RetraitStatus.unknown:
        return TText.of(context).translate('status_unknown');
    }
  }

  Widget _buildRetraitTile(RetraitItem item) {
    final String formattedDate = DateFormat("dd/MM/yyyy 'à' HH:mm").format(item.date);
    final String statusText = _statusLabel(item.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.clientName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: item.status == RetraitStatus.accepte
                            ? AppColors.primaryGreen
                            : (item.status == RetraitStatus.annule || item.status == RetraitStatus.refuse ? Colors.red : Colors.orange),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    TText(
                      'amount_prefix',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      '${AmountFormatter.format(item.amount)} XOF',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black45,
                  ),
                ),
                if (item.canBeCancelled) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _cancelRetrait(item),
                      child: const TText(
                        'cancel_op',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
