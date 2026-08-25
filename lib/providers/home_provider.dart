
import 'package:flutter/material.dart';
import '../model/transaction_item.dart';
import '../services/home_service.dart';
import '../services/transaction_service.dart';
import '../model/home/infos_accueil.dart';

class HomeProvider extends ChangeNotifier {
  final HomeService _homeService = HomeService();
  final TransactionService _transactionService = TransactionService();

  String _soldeShow = '0 XOF';
  double _solde = 0.0;
  double _totalDepots = 0.0;
  String _agentName = 'Agent';
  List<TransactionItem> _recentTransactions = [];
  bool _isLoading = false;
  String? _error;

  String get soldeShow => _soldeShow;
  double get solde => _solde;
  double get totalDepots => _totalDepots;
  String get agentName => _agentName;
  List<TransactionItem> get recentTransactions => _recentTransactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchHomeData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final InfosAccueil? info = await _homeService.loadHomeData();

      if (info != null) {
        _soldeShow = info.soldeShow;
        _solde = info.solde;
        _totalDepots = info.totalDepots;
        _agentName = info.agentName;
        _recentTransactions = info.transactions;
      } else {
        final txs = await _transactionService.transactionHistory();
        if (txs.isNotEmpty) {
          _recentTransactions = txs.take(5).toList();
        }
      }
    } catch (e) {
      _error = 'Erreur de connexion';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
