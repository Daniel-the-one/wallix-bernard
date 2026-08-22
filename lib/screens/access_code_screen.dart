// lib/screens/access_code_screen.dart
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../theme/app_colors.dart';
import '../data/shared_prefs_helper.dart';
import '../widgets/logout_confirm_dialog.dart';
import 'login_screen.dart';
import 'main_navigation_screen.dart';

class AccessCodeScreen extends StatefulWidget {
  final String agentName;

  const AccessCodeScreen({super.key, required this.agentName});

  @override
  State<AccessCodeScreen> createState() => _AccessCodeScreenState();
}

class _AccessCodeScreenState extends State<AccessCodeScreen> {
  final TextEditingController _pinController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  final SharedPrefsHelper _prefs = SharedPrefsHelper();

  void _submitCode(String code) {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final bool isValid = _prefs.verifyPin(code);

      setState(() {
        _isLoading = false;
      });

      if (isValid) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      } else {
        setState(() {
          _errorMessage = 'Code incorrect, veuillez réessayer.';
        });
        _pinController.clear();
      }
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (dialogContext) => LogoutConfirmDialog(
        onConfirm: () async {
          await _prefs.clearAll();
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: _logout,
                    icon: const Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: Colors.black54,
                    ),
                    label: const Text(
                      'Déconnexion',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 2),

              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primaryGreen,
                    size: 40,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: Text(
                  'Bon retour, ${_prefs.getAgentName().isNotEmpty ? _prefs.getAgentName() : widget.agentName}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Center(
                child: Text(
                  'Entrez votre code PIN pour continuer',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black45,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              LayoutBuilder(
                builder: (context, constraints) {
                  const int length = 4;
                  const double separatorWidth = 12;
                  final double fieldWidth =
                      (constraints.maxWidth - separatorWidth * (length - 1)) / length;

                  final defaultPinTheme = PinTheme(
                    width: fieldWidth,
                    height: 64,
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  );

                  final focusedPinTheme = defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(
                        color: AppColors.primaryGreen,
                        width: 2,
                      ),
                    ),
                  );

                  final errorPinTheme = defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                  );

                  return Pinput(
                    controller: _pinController,
                    length: length,
                    obscureText: true,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    errorPinTheme: errorPinTheme,
                    forceErrorState: _errorMessage.isNotEmpty,
                    separatorBuilder: (index) =>
                        const SizedBox(width: separatorWidth),
                    onCompleted: _submitCode,
                  );
                },
              ),

              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primaryGreen),
                  ),
                ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
