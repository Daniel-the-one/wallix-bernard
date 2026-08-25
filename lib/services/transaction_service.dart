
import 'package:flutter/foundation.dart';
import '../api/api_config.dart';
import '../api/api_default.dart';
import '../api/api_status.dart';
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



  Future<TransactionResult> depot({
    required String clientToken,
    required double amount,
    required String codeSecurite,
  }) async {
    try {
      final response = await ApiDefault.postData(ApiConfig.agentDepot, {
        'numero_compte': _prefs.getPhoneNumber(),
        'receiver_phone': clientToken,
        'montant': amount,
        'montant_total': amount,
        'code_securite': codeSecurite,
      });

      if (kDebugMode) debugPrint('DEPOT STATUS: ${response['status']}');
      return TransactionResult.fromJson(response);
    } catch (e) {
      debugPrint('DEPOT ERROR: $e');
      return TransactionResult(
        status: 'error',
        message: 'Erreur lors du dépôt : $e',
      );
    }
  }






  Future<TransactionResult> initRetrait({
    required String clientToken,
    required double amount,
    required String codeSecurite,
  }) async {
    try {
      final response = await ApiDefault.postData(
        ApiConfig.agentInitRetrait,
        {
          'numero_compte': _prefs.getPhoneNumber(),
          'receiver_phone': clientToken,
          'montant': amount,
          'montant_total': amount,
          'code_securite': codeSecurite,
        },
      );

      return TransactionResult.fromJson(response);
    } catch (e) {
      debugPrint('TransactionService initRetrait error: $e');
      return TransactionResult(
        status: 'error',
        message: 'Erreur lors de l\'initialisation du retrait : $e',
      );
    }
  }



  Future<TransactionResult> sendMoney({
    required String receiverPhone,
    required double amount,
    required double totalAmount,
    required String codeSecurite,
  }) async {
    try {
      final response = await ApiDefault.postData(ApiConfig.operationsSendMoney, {
        'numero_compte': _prefs.getPhoneNumber(),
        'receiver_phone': receiverPhone,
        'montant': amount,
        'montant_total': totalAmount,
        'code_securite': codeSecurite,
      });

      return TransactionResult.fromJson(response);
    } catch (e) {
      debugPrint('TransactionService sendMoney error: $e');
      return TransactionResult(
        status: 'error',
        message: 'Erreur lors de l\'envoi d\'argent : $e',
      );
    }
  }



  Future<double> getTransactionFrais({
    required double amount,
    required String receiverPhone,
  }) async {
    try {
      final response = await ApiDefault.postData(ApiConfig.operationsGetFrais, {
        'numero_compte': _prefs.getPhoneNumber(),
        'amount': amount,
        'receiver_phone': receiverPhone,
      });

      if (ApiStatus.isSuccess(response['status'])) {
        return double.tryParse(response['frais']?.toString() ?? '0') ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      debugPrint('TransactionService getTransactionFrais error: $e');
      return 0.0;
    }
  }



  Future<SimpleResponse> cancelRetrait({
    required String keyRetraitP,
    required String codeSecurite,
  }) async {
    try {
      final response = await ApiDefault.postData(ApiConfig.agentCancelRetrait, {
        'r_identifiant': keyRetraitP,
        'code_securite': codeSecurite,
      });

      if (kDebugMode) debugPrint('CANCEL RETRAIT STATUS: ${response['status']}');
      return SimpleResponse.fromJson(response);
    } catch (e) {
      debugPrint('CANCEL RETRAIT ERROR: $e');
      return SimpleResponse(
        status: 'error',
        message: 'Erreur lors de l\'annulation du retrait : $e',
      );
    }
  }





  Future<CommissionResponse?> getCommissions() async {
    try {
      final response = await ApiDefault.postData(
        ApiConfig.agentAllCommission,
        {'to_identifiant': ''},
      );
      if (kDebugMode) debugPrint('COMMISSION STATUS: ${response['status']}');
      return CommissionResponse.fromJson(response);
    } catch (e) {
      debugPrint('COMMISSION ERROR: $e');
      return null;
    }
  }



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
