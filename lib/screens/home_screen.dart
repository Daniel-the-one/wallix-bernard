
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/transaction_item.dart';
import '../theme/app_colors.dart';
import '../providers/home_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/t_text.dart';
import 'qr_scanner_screen.dart';
import 'notifications_screen.dart';
import 'transaction_detail_screen.dart';
import 'main_navigation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  bool _isBalanceHidden = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().fetchHomeData();

      context.read<TransactionProvider>().fetchAllData();
    });
  }


  Future<void> _refreshAll() async {
    await Future.wait([
      context.read<HomeProvider>().fetchHomeData(),
      context.read<TransactionProvider>().fetchAllData(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Consumer<HomeProvider>(
          builder: (context, homeProvider, child) {
            return RefreshIndicator(
              onRefresh: _refreshAll,
              color: AppColors.primaryGreen,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  _buildTopBar(homeProvider.agentName),
                  const SizedBox(height: 24),
                  _buildBalanceCard(homeProvider.soldeShow),
                  const SizedBox(height: 36),
                  _buildQuickActions(),
                  const SizedBox(height: 32),
                  _buildTransactionHistory(homeProvider),
                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(String agentName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
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
            const SizedBox(width: 12),
            TText(
              'home_welcome',
              args: {'name': agentName},
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        _circleIconButton(
          Icons.notifications_none_rounded,
          () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
          },
          badgeCount: context.watch<NotificationProvider>().unreadCount,
        ),
      ],
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap, {int badgeCount = 0}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.black87, size: 22),
          ),
          if (badgeCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  badgeCount > 9 ? '9+' : '$badgeCount',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(String soldeShow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const TText(
              'home_solde',
              style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _isBalanceHidden = !_isBalanceHidden),
              child: Icon(
                _isBalanceHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.black54,
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(


          _isBalanceHidden ? '••••••••' : (soldeShow.isNotEmpty ? soldeShow : '— XOF'),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {


    return Row(
      children: [
        Expanded(
          child: _quickActionButton(
            labelKey: 'home_depot',
            assetPath: 'assets/images/depot.jpeg',
            fallbackIcon: Icons.savings_rounded,
            fallbackColor: Colors.pinkAccent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QrScannerScreen(operationType: OperationType.depot)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickActionButton(
            labelKey: 'home_retrait',
            assetPath: 'assets/images/retrait.jpeg',
            fallbackIcon: Icons.swap_horiz_rounded,
            fallbackColor: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QrScannerScreen(operationType: OperationType.retrait)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _quickActionButton({
    required String labelKey,
    required String assetPath,
    required IconData fallbackIcon,
    required Color fallbackColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Image.asset(
              assetPath,
              width: 36,
              height: 36,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(fallbackIcon, color: fallbackColor, size: 36);
              },
            ),
            const SizedBox(height: 12),
            TText(
              labelKey,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistory(HomeProvider homeProvider) {

    final transactionProvider = context.watch<TransactionProvider>();
    final recentTransactions = transactionProvider.transactions.isNotEmpty
        ? transactionProvider.transactions.take(5).toList()
        : homeProvider.recentTransactions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const TText(
              'home_history',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
            ),
            GestureDetector(
              onTap: () {
                final navState = context.findAncestorStateOfType<State<MainNavigationScreen>>();
                if (navState != null) {
                  (navState as dynamic).switchTab(1);
                }
              },
              child: const TText(
                'view_all',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if ((transactionProvider.isLoading || homeProvider.isLoading) && recentTransactions.isEmpty)
          const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
        else if (recentTransactions.isEmpty)
          _buildDefaultRecentTransactions()
        else
          ...recentTransactions.map(_buildTransactionTile),
      ],
    );
  }


  Widget _buildDefaultRecentTransactions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          TText(
            'home_history_empty',
            style: TextStyle(color: Colors.black45, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(TransactionItem item) {
    final bool isCredit = item.type == TransactionType.depot || item.type == TransactionType.reception;
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
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
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
                color: isCredit ? AppColors.primaryGreen : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
