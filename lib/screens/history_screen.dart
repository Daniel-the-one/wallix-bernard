// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../model/transaction_item.dart';
import '../services/transaction_service.dart';
import '../widgets/t_text.dart';
import 'transaction_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with AutomaticKeepAliveClientMixin {
  final TransactionService _transactionService = TransactionService();
  final TextEditingController _searchController = TextEditingController();
  List<TransactionItem> _allTransactions = [];
  bool _isLoading = false;
  String _searchQuery = '';
  TransactionType? _selectedType;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    try {
      final list = await _transactionService.transactionHistory();
      setState(() {
        _allTransactions = list;
      });
    } catch (e) {
      debugPrint('Error fetching transaction history: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    List<TransactionItem> filteredList = _allTransactions.where((tx) {
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
              onRefresh: _fetchHistory,
              color: AppColors.primaryGreen,
              child: _isLoading && _allTransactions.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                  : filteredList.isEmpty && _allTransactions.isNotEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 100),
                            Center(child: TText('no_transactions')),
                          ],
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            if (sortedDates.isNotEmpty)
                              ...sortedDates.map((dateKey) {
                                final transactions = groupedTransactions[dateKey]!;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildDateHeader(dateKey),
                                    ...transactions.map((tx) => _buildHistoryItem(tx)),
                                  ],
                                );
                              })
                            else
                              _buildDefaultHistoryData(),
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
          hintText: 'Rechercher une transaction',
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
          _buildChip('Tous', null),
          _buildChip('Dépôts', TransactionType.depot),
          _buildChip('Retraits', TransactionType.retrait),
        ],
      ),
    );
  }

  Widget _buildChip(String label, TransactionType? type) {
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
        child: Text(
          label,
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

  Widget _buildDefaultHistoryData() {
    final List<Map<String, dynamic>> defaultGroups = [
      {
        'date': '20/08/2026',
        'items': [
          {'name': 'Ditoma', 'date': '20/08/2026 à 20:19', 'amount': '5 000 XOF', 'isRetrait': true},
        ]
      },
      {
        'date': '16/08/2026',
        'items': [
          {'name': 'Ditoma', 'date': '16/08/2026 à 15:59', 'amount': '5 000 XOF', 'isRetrait': true},
        ]
      },
      {
        'date': '10/08/2026',
        'items': [
          {'name': 'Bernard', 'date': '10/08/2026 à 15:46', 'amount': '700 XOF', 'isRetrait': false},
          {'name': 'Bernard', 'date': '10/08/2026 à 12:10', 'amount': '1 000 XOF', 'isRetrait': true},
          {'name': 'Bernard', 'date': '10/08/2026 à 12:08', 'amount': '3 000 XOF', 'isRetrait': false},
        ]
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: defaultGroups.map((group) {
        final items = group['items'] as List<Map<String, dynamic>>;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(group['date'] as String),
            ...items.map((item) {
              final bool isRetrait = item['isRetrait'] as bool;
              final txItem = TransactionItem(
                id: 'hist_${item['name']}',
                title: item['name'] as String,
                subtitle: item['date'] as String,
                amount: 5000,
                amountShow: item['amount'] as String,
                date: DateTime.now(),
                type: isRetrait ? TransactionType.retrait : TransactionType.depot,
              );

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TransactionDetailScreen(item: txItem)),
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
                            Text(
                              item['name'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['date'] as String,
                              style: const TextStyle(fontSize: 12, color: Colors.black45),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        item['amount'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isRetrait ? Colors.red : AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      }).toList(),
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
                  Text(
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
