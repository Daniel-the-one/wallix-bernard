
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import '../widgets/t_text.dart';
import '../providers/transaction_provider.dart';

class ClientRegistrationScreen extends StatefulWidget {
  const ClientRegistrationScreen({super.key});

  @override
  State<ClientRegistrationScreen> createState() => _ClientRegistrationScreenState();
}

class _ClientRegistrationScreenState extends State<ClientRegistrationScreen> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  bool _isProcessing = false;
  String? _errorMessage;
  bool _isSuccess = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final phone = _phoneController.text.trim();
    final pin = _pinController.text.trim();

    if (nom.isEmpty || prenom.isEmpty || phone.isEmpty || pin.isEmpty) {
      setState(() => _errorMessage = TText.of(context).translate('error_fill_fields'));
      return;
    }
    if (pin.length < 4) {
      setState(() => _errorMessage = TText.of(context).translate('error_pin_length'));
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {

      final result = await context.read<AuthService>().createUserAccount(
        nom: nom,
        prenom: prenom,
        telephone: phone,
        codeSecurite: pin,
      );

      if (!mounted) return;
      if (result.isSuccess) {
        setState(() => _isSuccess = true);


        context.read<TransactionProvider>().fetchAllData();
      } else {
        setState(() {
          _errorMessage = result.message ?? TText.of(context).translate('register_error');
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = '${TText.of(context).translate('error')}: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const TText('register_client_title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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
          const TText(
            'register_client_desc',
            style: TextStyle(color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(height: 24),

          _buildLabel('lastname_label'),
          const SizedBox(height: 8),
          TextField(
            controller: _nomController,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration('register_lastname_hint', prefix: const Icon(Icons.person_outline, size: 20)),
          ),

          const SizedBox(height: 20),

          _buildLabel('firstname_label'),
          const SizedBox(height: 8),
          TextField(
            controller: _prenomController,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration('register_firstname_hint', prefix: const Icon(Icons.person_outline, size: 20)),
          ),

          const SizedBox(height: 20),

          _buildLabel('phone_label'),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration('90 00 00 00', prefix: const Icon(Icons.phone_iphone, size: 20)),
          ),

          const SizedBox(height: 20),

          _buildLabel('register_pin_label'),
          const SizedBox(height: 8),
          TextField(
            controller: _pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _inputDecoration('register_pin_hint'),
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
              onPressed: _isProcessing ? null : _submitRegistration,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 0,
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const TText('register_client_btn', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    final fullName = '${_prenomController.text} ${_nomController.text}'.trim();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 80),
          const SizedBox(height: 24),
          const TText('register_success_title', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TText(
            'register_success_desc',
            args: {'name': fullName},
            textAlign: TextAlign.center,
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

  InputDecoration _inputDecoration(String hintKey, {Widget? prefix}) {
    return InputDecoration(
      hintText: TText.of(context).translate(hintKey),
      prefixIcon: prefix,
      counterText: '',
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2)),
    );
  }
}
