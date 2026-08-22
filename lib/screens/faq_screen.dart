import 'package:flutter/material.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final List<Map<String, String>> _faqItems = [
    {
      'question': 'Comment effectuer un dépôt ?',
      'answer': 'Pour effectuer un dépôt, cliquez sur l\'option "Dépôt" depuis la page d\'accueil ou scannez le QR code fourni par le client, puis saisissez le montant souhaité.',
    },
    {
      'question': 'Comment annuler un retrait ?',
      'answer': 'Tant que le retrait n\'a pas été validé par le client, vous pouvez l\'annuler depuis la liste des retraits ou contacter immédiatement le service client.',
    },
    {
      'question': 'Quand sont versées mes commissions ?',
      'answer': 'Vos commissions sont calculées automatiquement pour chaque transaction et versées directement sur votre solde agent.',
    },
    {
      'question': 'Le client ne reçoit pas la demande de retrait ?',
      'answer': 'Vérifiez la connexion réseau du téléphone client ou réessayez en générant un nouveau QR code de retrait.',
    },
    {
      'question': 'Comment changer mon code PIN ?',
      'answer': 'Rendez-vous dans la section Paramètres > Changer mon code de sécurité, puis entrez votre ancien code et votre nouveau code PIN.',
    },
  ];

  final Map<int, bool> _expandedState = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'FAQ',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: _faqItems.length,
        itemBuilder: (context, index) {
          final item = _faqItems[index];
          final isExpanded = _expandedState[index] ?? false;

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                title: Text(
                  item['question']!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                trailing: Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.black54,
                ),
                onExpansionChanged: (expanded) {
                  setState(() {
                    _expandedState[index] = expanded;
                  });
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Text(
                      item['answer']!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

