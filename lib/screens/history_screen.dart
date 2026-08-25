
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../model/transaction_item.dart';
import '../providers/transaction_provider.dart';
import '../widgets/t_text.dart';
import 'transaction_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  TransactionType? _selectedType;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {

      final provider = context.read<TransactionProvider>();
      if (provider.transactions.isEmpty) {
        provider.fetchHistory();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshHistory() async {
    await context.read<TransactionProvider>().fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);


    final transactionProvider = context.watch<TransactionProvider>();
    final List<TransactionItem> allTransactions = transactionProvider.transactions;
    final bool isLoading = transactionProvider.isLoading;

    List<TransactionItem> filteredList = allTransactions.where((tx) {
      final matchesSearch = tx.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tx.subtitle.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _selectedType == null || tx.type == _selectedType;
      return matchesSearch && matchesType;
    }).toList();

    final Map<String, List<TransactionItem>> groupedTransactions =
        TransactionItem.groupByDate(filteredList);
    final List<String> sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const TText(
          'history_title',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshHistory,
              color: AppColors.primaryGreen,
              child: isLoading && allTransactions.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                  : filteredList.isEmpty && allTransactions.isNotEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 100),
                            Center(child: TText('no_transactions')),
                          ],
                        )
                      : allTransactions.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 120),
                                Center(
                                  child: TText(
                                    'history_empty',
                                    style: TextStyle(color: Colors.black45, fontSize: 14),
                                  ),
                                ),
                              ],
                            )
                          : ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              children: [
                                ...sortedDates.map((dateKey) {
                                  final transactions = groupedTransactions[dateKey]!;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildDateHeader(dateKey),
                                      ...transactions.map((tx) => _buildHistoryItem(tx)),
                                    ],
                                  );
                                }),
                                const SizedBox(height: 100),
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
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: TText.of(context).translate('search_hint'),
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildChip('filter_all', null),
          _buildChip('filter_depots', TransactionType.depot),
          _buildChip('filter_retraits', TransactionType.retrait),
        ],
      ),
    );
  }

  Widget _buildChip(String labelKey, TransactionType? type) {
    final bool isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: TText(
          labelKey,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader(String dateKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      child: Text(
        dateKey,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildHistoryItem(TransactionItem item) {
    final bool isDepot = item.type == TransactionType.depot;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TransactionDetailScreen(item: item)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_outline, color: Colors.black54, size: 24),
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
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TText(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                ],
              ),
            ),
            Text(
              item.amountShow,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDepot ? AppColors.primaryGreen : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
