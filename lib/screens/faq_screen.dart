import 'package:flutter/material.dart';
import '../widgets/t_text.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {

  static const List<String> _faqQuestionKeys = [
    'faq_q_deposit',
    'faq_q_cancel_retrait',
    'faq_q_commissions',
    'faq_q_client_no_request',
    'faq_q_change_pin',
  ];

  static const List<String> _faqAnswerKeys = [
    'faq_a_deposit',
    'faq_a_cancel_retrait',
    'faq_a_commissions',
    'faq_a_client_no_request',
    'faq_a_change_pin',
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
        title: const TText(
          'settings_faq_title',
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
        itemCount: _faqQuestionKeys.length,
        itemBuilder: (context, index) {
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
                title: TText(
                  _faqQuestionKeys[index],
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
                    child: TText(
                      _faqAnswerKeys[index],
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
