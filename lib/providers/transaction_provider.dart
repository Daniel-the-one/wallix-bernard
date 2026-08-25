
import 'package:flutter/material.dart';
import '../model/transaction_item.dart';
import '../model/retrait_item.dart';
import '../model/commission_response.dart';
import '../model/auth/simple_response.dart';
import '../model/transaction_result.dart';
import '../services/transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  List<TransactionItem> _transactions = [];
  List<RetraitItem> _retraits = [];
  CommissionResponse? _commissionData;
  bool _isLoading = false;
  String? _error;

  List<TransactionItem> get transactions => _transactions;
  List<RetraitItem> get retraits => _retraits;
  CommissionResponse? get commissionData => _commissionData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAllData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _transactionService.transactionHistory(),
        _transactionService.listRetraits(),
        _transactionService.getCommissions(),
      ]);

      _transactions = results[0] as List<TransactionItem>;
      _retraits = results[1] as List<RetraitItem>;
      _commissionData = results[2] as CommissionResponse?;

      _error = null;
    } catch (e) {
      _error = 'Erreur lors du chargement des données';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHistory() async {
    try {
      _transactions = await _transactionService.transactionHistory();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchRetraits() async {
    try {
      _retraits = await _transactionService.listRetraits();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchCommissions() async {
    try {
      _commissionData = await _transactionService.getCommissions();
      notifyListeners();
    } catch (_) {}
  }




  Future<SimpleResponse> cancelRetrait({
    required String keyRetraitP,
    required String codeSecurite,
  }) async {
    return _transactionService.cancelRetrait(
      keyRetraitP: keyRetraitP,
      codeSecurite: codeSecurite,
    );
  }









  Future<TransactionResult> sendMoney({
    required String receiverPhone,
    required double amount,
    required double totalAmount,
    required String codeSecurite,
  }) {
    return _transactionService.sendMoney(
      receiverPhone: receiverPhone,
      amount: amount,
      totalAmount: totalAmount,
      codeSecurite: codeSecurite,
    );
  }


  Future<double> getTransactionFrais({
    required double amount,
    required String receiverPhone,
  }) {
    return _transactionService.getTransactionFrais(
      amount: amount,
      receiverPhone: receiverPhone,
    );
  }


  Future<TransactionResult> depot({
    required String clientToken,
    required double amount,
    required String codeSecurite,
  }) {
    return _transactionService.depot(
      clientToken: clientToken,
      amount: amount,
      codeSecurite: codeSecurite,
    );
  }


  Future<TransactionResult> initRetrait({
    required String clientToken,
    required double amount,
    required String codeSecurite,
  }) {
    return _transactionService.initRetrait(
      clientToken: clientToken,
      amount: amount,
      codeSecurite: codeSecurite,
    );
  }
}
