
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import '../widgets/logout_confirm_dialog.dart';
import '../widgets/t_text.dart';
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




  int _failedAttempts = 0;
  DateTime? _lockUntil;

  bool get _isLocked => _lockUntil != null && DateTime.now().isBefore(_lockUntil!);

  int get _remainingLockSeconds =>
      _lockUntil == null ? 0 : _lockUntil!.difference(DateTime.now()).inSeconds.clamp(1, 3600);

  void _submitCode(String code) {
    if (_isLocked) {
      setState(() {
        _errorMessage = TText.of(context).translate(
          'too_many_attempts',
        ).replaceAll('{seconds}', '$_remainingLockSeconds');
      });
      _pinController.clear();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      final bool isValid = context.read<AuthService>().verifyPinLocal(code);

      setState(() {
        _isLoading = false;
      });

      if (isValid) {
        _failedAttempts = 0;
        _lockUntil = null;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      } else {
        _failedAttempts++;
        String message = TText.of(context).translate('incorrect_pin');
        if (_failedAttempts >= 3) {
          final int delaySeconds = 30 * (_failedAttempts - 2);
          _lockUntil = DateTime.now().add(Duration(seconds: delaySeconds));
          message = TText.of(context).translate(
            'too_many_attempts',
          ).replaceAll('{seconds}', '$delaySeconds');
        }
        setState(() {
          _errorMessage = message;
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
          await context.read<AuthService>().logout();
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
                    label: const TText(
                      'logout',
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
                child: TText(
                  'welcome_back_name',
                  args: {'name': context.watch<AuthService>().agentName?.isNotEmpty == true ? context.watch<AuthService>().agentName! : widget.agentName},
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
                child: TText(
                  'enter_pin',
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
