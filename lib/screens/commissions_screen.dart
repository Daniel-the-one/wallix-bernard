// lib/screens/commissions_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../widgets/t_text.dart';
import '../services/transaction_service.dart';
import '../services/amount_formatter.dart';
import '../model/commission_response.dart';

class CommissionsScreen extends StatefulWidget {
  const CommissionsScreen({super.key});

  @override
  State<CommissionsScreen> createState() => _CommissionsScreenState();
}

class _CommissionsScreenState extends State<CommissionsScreen> {
  final TransactionService _transactionService = TransactionService();
  CommissionResponse? _data;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchCommissions();
  }

  Future<void> _fetchCommissions() async {
    setState(() => _isLoading = true);
    try {
      final res = await _transactionService.getCommissions();
      setState(() => _data = res);
    } catch (e) {
      debugPrint('Error fetching commissions: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _data?.items.where((item) {
          return DateFormat('yyyy-MM-dd').format(item.date) ==
              DateFormat('yyyy-MM-dd').format(_selectedDate);
        }).toList() ??
        [];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const TText('comm_title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCommissions,
        color: AppColors.primaryGreen,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSummaryCard(_data?.totalGains ?? 0, _data?.gainsToday ?? 0),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const TText('comm_list', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  DateFormat.yMMMMd(Localizations.localeOf(context).languageCode).format(_selectedDate),
                  style: const TextStyle(color: Colors.black45, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading && _data == null)
              const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
            else if (filteredItems.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: TText('comm_empty')),
              )
            else
              ...filteredItems.map(_buildCommissionTile),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double total, double today) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TText('comm_total', style: TextStyle(color: Colors.white60, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    '${AmountFormatter.format(total)} XOF',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Icon(Icons.trending_up, color: AppColors.primaryGreen),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TText('comm_today', style: TextStyle(color: Colors.white60, fontSize: 12)),
              Text(
                '+${AmountFormatter.format(today)} XOF',
                style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionTile(CommissionItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primaryGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.description, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(item.transactionRef, style: const TextStyle(fontSize: 11, color: Colors.black38)),
              ],
            ),
          ),
          Text(
            '+${AmountFormatter.format(item.amount)}',
            style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
