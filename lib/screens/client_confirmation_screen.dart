// lib/screens/client_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../model/client_info.dart';
import '../services/transaction_service.dart';
import '../widgets/t_text.dart';
import 'qr_scanner_screen.dart';
import 'main_navigation_screen.dart';

class ClientConfirmationScreen extends StatefulWidget {
  final String clientCode;
  final ClientInfo? clientInfo;
  final OperationType type;

  const ClientConfirmationScreen({
    super.key,
    required this.clientCode,
    this.clientInfo,
    required this.type,
  });

  @override
  State<ClientConfirmationScreen> createState() => _ClientConfirmationScreenState();
}

class _ClientConfirmationScreenState extends State<ClientConfirmationScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TransactionService _transactionService = TransactionService();
  String? _errorMessage;
  bool _isLoading = false;
  bool _isSuccess = false;
  Map<String, dynamic>? _transactionDetails;

  @override
  void dispose() {
    _amountController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _processOperation() async {
    setState(() => _errorMessage = null);

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final pin = _pinController.text;

    if (amount <= 0) {
      setState(() => _errorMessage = 'Montant invalide');
      return;
    }
    if (pin.isEmpty) {
      setState(() => _errorMessage = 'Code de sécurité requis');
      return;
    }

    setState(() => _isLoading = true);

    final clientToken = widget.clientInfo?.clientToken.isNotEmpty == true
        ? widget.clientInfo!.clientToken
        : widget.clientCode;

    try {
      if (widget.type == OperationType.depot) {
        final result = await _transactionService.depot(
          clientToken: clientToken,
          amount: amount,
          codeSecurite: pin,
        );

        if (result.isSuccess) {
          setState(() {
            _isSuccess = true;
            _transactionDetails = {
              'amount': amount,
              'clientName': widget.clientInfo?.clientNom ?? (widget.clientCode.length > 5 ? widget.clientCode : 'Client'),
              'reference': result.reference ?? result.keyDepot ?? '__QjFwm9ObcTOvw',
              'date': '20/08/2026 à 20:19',
              'commission': '${result.commission ?? 8.50} XOF',
            };
          });
        } else {
          setState(() {
            if (result.message == 'code_securite_error') {
              _errorMessage = 'Code de sécurité incorrect';
            } else {
              _errorMessage = result.message ?? 'Erreur lors de l\'opération';
            }
          });
        }
      } else {
        final result = await _transactionService.initRetrait(
          clientToken: clientToken,
          amount: amount,
          codeSecurite: pin,
        );

        if (result.isSuccess) {
          setState(() {
            _isSuccess = true;
            _transactionDetails = {
              'amount': amount,
              'clientName': widget.clientInfo?.clientNom ?? (widget.clientCode.length > 5 ? widget.clientCode : 'Client'),
              'reference': result.reference ?? result.keyRetraitP ?? '__QjFwm9ObcTOvw',
              'date': '20/08/2026 à 20:19',
              'commission': '${result.commission ?? 2.17} XOF',
            };
          });
        } else {
          setState(() {
            if (result.message == 'code_securite_error') {
              _errorMessage = 'Code de sécurité incorrect';
            } else {
              _errorMessage = result.message ?? 'Erreur lors de l\'opération';
            }
          });
        }
      }
    } catch (e) {
      setState(() => _errorMessage = 'Erreur: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String titleKey = widget.type == OperationType.depot ? 'home_depot' : 'home_retrait';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: TText(
          titleKey,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
        ),
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isSuccess ? _buildSuccessView() : _buildInputView(),
      ),
    );
  }

  Widget _buildInputView() {
    final displayName = widget.clientInfo?.clientNom ?? widget.clientCode;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_outline, color: Colors.black54),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TText('client_label', style: TextStyle(fontSize: 12, color: Colors.black45)),
                    Text(
                      displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const TText('conf_amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              suffixText: 'XOF',
              hintText: '0',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const TText('conf_pin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: InputDecoration(
              counterText: '',
              hintText: 'Code PIN',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
              ),
            ),
          ),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),

          const SizedBox(height: 36),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _processOperation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const TText(
                      'conf_btn',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    final isDepot = widget.type == OperationType.depot;
    final amountText = _amountController.text.isNotEmpty
        ? '${_amountController.text} XOF'
        : '5 000 XOF';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 20),

          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),

          const SizedBox(height: 24),

          TText(
            isDepot ? 'depot_success' : 'status_initialise',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 12),

          if (!isDepot)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Le client a 5 minutes pour confirmer le retrait via son application.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          const SizedBox(height: 12),

          Text(
            amountText,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 32),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Détails de la transaction',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.person_outline, color: Colors.black54, size: 26),
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
                const SizedBox(width: 16),
                Text(
                  'Client : ${_transactionDetails?['clientName'] ?? "Ditoma"}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _buildDetailRow('Référence', _transactionDetails?['reference'] ?? '__QjFwm9ObcTOvw'),
          const SizedBox(height: 14),
          _buildDetailRow('Date et heure', _transactionDetails?['date'] ?? '20/08/2026 à 20:19'),
          const SizedBox(height: 14),
          _buildDetailRow('Commission', _transactionDetails?['commission'] ?? '8.50 XOF'),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              child: const Text(
                'Fermer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black45,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
