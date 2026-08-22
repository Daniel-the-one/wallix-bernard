// lib/screens/retraits_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../model/retrait_item.dart';
import '../services/transaction_service.dart';
import '../services/amount_formatter.dart';
import '../widgets/t_text.dart';

class RetraitsScreen extends StatefulWidget {
  const RetraitsScreen({super.key});

  @override
  State<RetraitsScreen> createState() => _RetraitsScreenState();
}

class _RetraitsScreenState extends State<RetraitsScreen> {
  final TransactionService _transactionService = TransactionService();
  final TextEditingController _searchController = TextEditingController();
  List<RetraitItem> _retraits = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchRetraits();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRetraits() async {
    setState(() => _isLoading = true);
    try {
      final list = await _transactionService.listRetraits();
      setState(() {
        _retraits = list;
      });
    } catch (e) {
      debugPrint('Error fetching retraits: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelRetrait(RetraitItem item) async {
    final TextEditingController pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                hintText: 'Code PIN',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const TText('cancel', style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final res = await _transactionService.cancelRetrait(
                keyRetraitP: item.keyRetrait,
                codeSecurite: pinController.text,
              );
              if (mounted) {
                if (res.isSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Retrait annulé avec succès'), backgroundColor: AppColors.primaryGreen),
                  );
                  _fetchRetraits();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res.message ?? 'échec de l\'annulation'), backgroundColor: Colors.red),
                  );
                }
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
    final filteredList = _retraits.where((r) {
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
            onPressed: _fetchRetraits,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchRetraits,
              color: AppColors.primaryGreen,
              child: _isLoading && _retraits.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                  : filteredList.isEmpty && _retraits.isNotEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 100),
                            Center(child: Text('Aucun retrait trouvé')),
                          ],
                        )
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            if (filteredList.isNotEmpty)
                              ...filteredList.map(_buildRetraitTile)
                            else
                              ..._buildDefaultRetraitItems(),
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
          hintText: 'Rechercher un client par nom ou numéro',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  List<Widget> _buildDefaultRetraitItems() {
    final List<Map<String, String>> defaultRetraits = [
      {'name': 'Bernard', 'amount': '700 XOF', 'date': '10/08/2026 à 15:44', 'status': 'Accepté'},
      {'name': 'Bernard', 'amount': '3 000 XOF', 'date': '10/08/2026 à 12:08', 'status': 'Accepté'},
      {'name': 'Bernard', 'amount': '5 000 XOF', 'date': '10/08/2026 à 11:47', 'status': 'Accepté'},
      {'name': 'Ditoma', 'amount': '200 XOF', 'date': '07/08/2026 à 15:20', 'status': 'Accepté'},
      {'name': 'Ditoma', 'amount': '1 200 XOF', 'date': '07/08/2026 à 09:46', 'status': 'Accepté'},
      {'name': 'Ditoma', 'amount': '5 000 XOF', 'date': '07/08/2026 à 09:31', 'status': 'Accepté'},
      {'name': 'Ditoma', 'amount': '500 XOF', 'date': '07/08/2026 à 09:27', 'status': 'Accepté'},
    ];

    return defaultRetraits.map((item) {
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
                        item['name']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        item['status']!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Text(
                        'Montant : ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        item['amount']!,
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
                    item['date']!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildRetraitTile(RetraitItem item) {
    final String formattedDate = DateFormat("dd/MM/yyyy 'à' HH:mm").format(item.date);
    final String statusText = item.statusLabel.isNotEmpty ? item.statusLabel : (item.status == RetraitStatus.accepte ? 'Accepté' : item.status.name);

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
                    const Text(
                      'Montant : ',
                      style: TextStyle(
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
