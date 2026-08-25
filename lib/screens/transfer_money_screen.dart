
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../services/amount_formatter.dart';
import '../widgets/t_text.dart';
import '../l10n/app_localizations.dart';
import '../providers/transaction_provider.dart';
import '../providers/home_provider.dart';

class TransferMoneyScreen extends StatefulWidget {
  const TransferMoneyScreen({super.key});

  @override
  State<TransferMoneyScreen> createState() => _TransferMoneyScreenState();
}

class _TransferMoneyScreenState extends State<TransferMoneyScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  Timer? _fraisDebounce;
  double _frais = 0.0;
  bool _isLoadingFrais = false;
  bool _isProcessing = false;
  String? _errorMessage;
  bool _isSuccess = false;

  @override
  void dispose() {
    _fraisDebounce?.cancel();
    _phoneController.dispose();
    _amountController.dispose();
    _pinController.dispose();
    super.dispose();
  }



  void _scheduleFraisCalculation() {
    _fraisDebounce?.cancel();
    _fraisDebounce = Timer(const Duration(milliseconds: 500), () {
      _calculateFrais();
    });
  }

  Future<void> _calculateFrais() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final phone = _phoneController.text;
    if (amount <= 0 || phone.isEmpty) return;

    setState(() => _isLoadingFrais = true);
    try {
      final frais = await context.read<TransactionProvider>().getTransactionFrais(
        amount: amount,
        receiverPhone: phone,
      );
      if (!mounted) return;


      final currentAmount = double.tryParse(_amountController.text) ?? 0.0;
      if (currentAmount != amount || _phoneController.text != phone) return;
      setState(() {
        _frais = frais;
        _isLoadingFrais = false;
      });
    } catch (_) {


      if (!mounted) return;
      setState(() => _isLoadingFrais = false);
    }
  }

  Future<void> _submitTransfer() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final phone = _phoneController.text;
    final pin = _pinController.text;

    if (phone.isEmpty || amount <= 0 || pin.isEmpty) {
      setState(() => _errorMessage = AppLocalizations.of(context).translate('error_fill_fields'));
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final result = await context.read<TransactionProvider>().sendMoney(
        receiverPhone: phone,
        amount: amount,
        totalAmount: amount + _frais,
        codeSecurite: pin,
      );

      if (!mounted) return;

      if (result.isSuccess) {
        setState(() => _isSuccess = true);

        context.read<TransactionProvider>().fetchAllData();
        context.read<HomeProvider>().fetchHomeData();
      } else {
        setState(() => _errorMessage = result.message ?? AppLocalizations.of(context).translate('transfert_error'));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = '${AppLocalizations.of(context).translate('error')}: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const TText('transfert_title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isSuccess ? _buildSuccessView() : _buildFormView(),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('transfert_receiver'),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration('90 00 00 00', prefix: const Icon(Icons.phone_iphone, size: 20)),
            onChanged: (v) {
              if (_amountController.text.isNotEmpty) _scheduleFraisCalculation();
            },
          ),

          const SizedBox(height: 20),

          _buildLabel('transfert_amount'),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _inputDecoration('0', suffix: 'XOF'),
            onChanged: (v) => _scheduleFraisCalculation(),
          ),

          if (_frais > 0 || _isLoadingFrais)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TText('transfert_fees', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                  _isLoadingFrais
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text('${AmountFormatter.format(_frais)} XOF', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                ],
              ),
            ),

          const SizedBox(height: 20),

          _buildLabel('conf_pin'),
          const SizedBox(height: 8),
          TextField(
            controller: _pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: _inputDecoration('pin_code'),
          ),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
            ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _submitTransfer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 0,
              ),
              child: _isProcessing
                ? const CircularProgressIndicator(color: Colors.black)
                : const TText('transfert_confirm_btn', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 80),
          const SizedBox(height: 24),
          const TText('transfert_success', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TText(
            'transfert_success_desc',
            args: {'amount': '${_amountController.text} XOF'},
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const TText('back'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String textKey) {
    return TText(textKey, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87));
  }

  InputDecoration _inputDecoration(String hint, {Widget? prefix, String? suffix}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefix,
      suffixText: suffix,
      counterText: '',
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2)),
    );
  }
}
