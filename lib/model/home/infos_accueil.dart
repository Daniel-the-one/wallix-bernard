// lib/model/home/infos_accueil.dart
import '../transaction_item.dart';

class InfosAccueil {
  final String agentName;
  final String soldeShow;
  final double solde;
  final double totalDepots;
  final List<TransactionItem> transactions;
  final List<dynamic> comptes;

  InfosAccueil({
    required this.agentName,
    required this.soldeShow,
    required this.solde,
    required this.totalDepots,
    required this.transactions,
    required this.comptes,
  });

  factory InfosAccueil.fromJson(Map<String, dynamic> json) {
    final name = json['agent_name']?.toString() ??
        json['agentName']?.toString() ??
        json['name']?.toString() ??
        'Agent';

    String soldeDisplay = json['solde_show']?.toString() ?? '';
    double soldeVal = 0.0;
    List<dynamic> comptesList = [];

    if (json['comptes'] is List) {
      comptesList = json['comptes'] as List;
      if (comptesList.isNotEmpty) {
        final defaultCompte = comptesList.firstWhere(
          (c) => c is Map && (c['is_default'] == 1 || c['is_default'] == '1'),
          orElse: () => comptesList.first,
        );
        if (defaultCompte is Map) {
          soldeDisplay = defaultCompte['montant_show']?.toString() ??
              '${defaultCompte['montant'] ?? defaultCompte['solde'] ?? "0"} XOF';
          soldeVal = _parseDouble(defaultCompte['montant'] ?? defaultCompte['solde']);
        }
      }
    }

    if (soldeDisplay.isEmpty) {
      soldeVal = _parseDouble(json['solde'] ?? json['balance']);
      soldeDisplay = '$soldeVal XOF';
    }

    final double totalDep = _parseDouble(json['total_depots'] ?? json['total_depot']);

    List<TransactionItem> txs = [];
    final rawTxs = json['transactions'] ?? json['operations'] ?? json['recent_transactions'];
    if (rawTxs is List) {
      txs = rawTxs
          .whereType<Map<String, dynamic>>()
          .map((t) => TransactionItem.fromJson(t))
          .toList();
    }

    return InfosAccueil(
      agentName: name,
      soldeShow: soldeDisplay,
      solde: soldeVal,
      totalDepots: totalDep,
      transactions: txs,
      comptes: comptesList,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      String cleaned = value.replaceAll(',', '.').replaceAll(' ', '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }
}
