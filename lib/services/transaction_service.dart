// lib/services/transaction_service.dart
import 'package:flutter/foundation.dart';
import '../api/api_config.dart';
import '../api/api_default.dart';
import '../data/shared_prefs_helper.dart';
import '../model/transaction_item.dart';
import '../model/transaction_result.dart';
import '../model/operation_history_response.dart';
import '../model/commission_response.dart';
import '../model/retrait_item.dart';
import '../model/auth/simple_response.dart';

class TransactionService {
  static final TransactionService _instance = TransactionService._internal();
  factory TransactionService() => _instance;
  TransactionService._internal();

  final SharedPrefsHelper _prefs = SharedPrefsHelper();

  /// Récupère l'historique complet des opérations
  /// Endpoint: agents/operations
  Future<List<TransactionItem>> transactionHistory() async {
    try {
      final response = await ApiDefault.postData(ApiConfig.agentOperations, {
        'to_identifiant': '',
      });
      final historyResponse = OperationHistoryResponse.fromJson(response);
      if (historyResponse.isSuccess) {
        return historyResponse.operations;
      }
      return [];
    } catch (e) {
      debugPrint('TransactionService transactionHistory error: $e');
      return [];
    }
  }

  /// Exécute un dépôt pour un client
  /// Endpoint: agents/depot
  Future<TransactionResult> depot({
    required String clientToken,
    required double amount,
    required String codeSecurite,
  }) async {
    debugPrint('DEPOT REQUEST: client=$clientToken, amount=$amount');
    try {
      final response = await ApiDefault.postData(ApiConfig.agentDepot, {
        'numero_compte': _prefs.getPhoneNumber(),
        'receiver_phone': clientToken,
        'montant': amount,
        'montant_total': amount,
        'code_securite': codeSecurite,
      });

      debugPrint('DEPOT RESPONSE: $response');
      return TransactionResult.fromJson(response);
    } catch (e) {
      debugPrint('DEPOT ERROR: $e');
      return TransactionResult(
        status: 'error',
        message: 'Erreur lors du dépôt : $e',
      );
    }
  }

  /// Initialise un retrait
  /// Endpoint: agents/init_retrait
  Future<TransactionResult> initRetrait({
    required String clientToken,
    required double amount,
    required String codeSecurite,
  }) async {
    try {
      final response = await ApiDefault.postData(ApiConfig.agentInitRetrait, {
        'numero_compte': _prefs.getPhoneNumber(),
        'receiver_phone': clientToken,
        'montant': amount,
        'montant_total': amount,
        'code_securite': codeSecurite,
      });

      return TransactionResult.fromJson(response);
    } catch (e) {
      debugPrint('TransactionService initRetrait error: $e');
      return TransactionResult(
        status: 'error',
        message: 'Erreur lors de l\'initialisation du retrait : $e',
      );
    }
  }

  /// Annule une demande de retrait en attente
  /// Endpoint: agents/cancel_retrait
  Future<SimpleResponse> cancelRetrait({
    required String keyRetraitP,
    required String codeSecurite,
  }) async {
    debugPrint('CANCEL RETRAIT REQUEST: r_identifiant=$keyRetraitP');
    try {
      final response = await ApiDefault.postData(ApiConfig.agentCancelRetrait, {
        'r_identifiant': keyRetraitP,
        'code_securite': codeSecurite,
      });

      debugPrint('CANCEL RETRAIT RESPONSE: $response');
      return SimpleResponse.fromJson(response);
    } catch (e) {
      debugPrint('CANCEL RETRAIT ERROR: $e');
      return SimpleResponse(
        status: 'error',
        message: 'Erreur lors de l\'annulation du retrait : $e',
      );
    }
  }

  /// Récupère l'ensemble des commissions de l'agent
  /// Endpoint: agents/all_commission
  Future<CommissionResponse?> getCommissions() async {
    debugPrint('COMMISSION REQUEST:');
    try {
      final response = await ApiDefault.postData(ApiConfig.agentAllCommission, {
        'to_identifiant': '',
      });
      debugPrint('COMMISSION RESPONSE: $response');
      return CommissionResponse.fromJson(response);
    } catch (e) {
      debugPrint('COMMISSION ERROR: $e');
      return null;
    }
  }

  /// Récupère la liste des demandes et historiques de retrait
  /// Endpoint: agents/all_retrait
  Future<List<RetraitItem>> listRetraits() async {
    try {
      final response = await ApiDefault.postData(ApiConfig.agentAllRetrait, {
        'search_keyword': '',
      });
      final listResponse = RetraitListResponse.fromJson(response);
      return listResponse.listRetraits;
    } catch (e) {
      debugPrint('TransactionService listRetraits error: $e');
      return [];
    }
  }
}
