// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_picker/country_picker.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/t_text.dart';
import '../services/auth_service.dart';
import '../data/shared_prefs_helper.dart';
import 'main_navigation_screen.dart';
import 'forgot_code_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _isPasswordVisible = false;
  String _phoneError = '';
  String _codeError = '';
  bool _isLoading = false;
  final SharedPrefsHelper _prefs = SharedPrefsHelper();
  bool _rememberMe = false;

  static const int _codeLength = 4;

  Country _selectedCountry = Country(
    phoneCode: '228',
    countryCode: 'TG',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'Togo',
    example: 'Togo',
    displayName: 'Togo',
    displayNameNoCountryCode: 'Togo',
    e164Key: '',
  );

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  void _loadSavedData() {
    String savedPhone = _prefs.getString('phone_number');
    bool remember = _prefs.getBool('remember_me');

    if (savedPhone.isNotEmpty && remember) {
      _phoneController.text = savedPhone;
      _rememberMe = true;
      _validatePhone(savedPhone);
    }
  }

  int _getMaxLengthForCountry(String countryCode) {
    switch (countryCode) {
      case 'TG':
        return 8;
      case 'FR':
        return 10;
      case 'US':
        return 10;
      case 'BJ':
        return 8;
      case 'CI':
        return 8;
      case 'SN':
        return 9;
      case 'CM':
        return 9;
      default:
        return 8;
    }
  }

  bool _isValidPrefix(String phone, String countryCode) {
    String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.isEmpty) return false;

    switch (countryCode) {
      case 'TG':
        return cleaned.startsWith('70') ||
            cleaned.startsWith('71') ||
            cleaned.startsWith('73') ||
            cleaned.startsWith('79') ||
            cleaned.startsWith('90') ||
            cleaned.startsWith('91') ||
            cleaned.startsWith('92') ||
            cleaned.startsWith('93') ||
            cleaned.startsWith('96') ||
            cleaned.startsWith('97') ||
            cleaned.startsWith('98') ||
            cleaned.startsWith('99');
      case 'FR':
        return cleaned.startsWith('6') || cleaned.startsWith('7');
      case 'US':
        return cleaned.startsWith(RegExp(r'[2-9]'));
      case 'BJ':
        return cleaned.startsWith('90') ||
            cleaned.startsWith('91') ||
            cleaned.startsWith('94') ||
            cleaned.startsWith('95') ||
            cleaned.startsWith('97');
      case 'CI':
        return cleaned.startsWith('01') ||
            cleaned.startsWith('02') ||
            cleaned.startsWith('03') ||
            cleaned.startsWith('04') ||
            cleaned.startsWith('05') ||
            cleaned.startsWith('06') ||
            cleaned.startsWith('07') ||
            cleaned.startsWith('08');
      case 'SN':
        return cleaned.startsWith('70') ||
            cleaned.startsWith('75') ||
            cleaned.startsWith('76') ||
            cleaned.startsWith('77') ||
            cleaned.startsWith('78');
      case 'CM':
        return cleaned.startsWith('6') || cleaned.startsWith('9');
      default:
        return true;
    }
  }

  void _openCountryPicker() {
    final List<Country> allCountries = CountryService().getAll();
    String searchQuery = '';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredCountries = allCountries.where((country) {
              return country.name
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase());
            }).toList();

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SizedBox(
                width: double.maxFinite,
                height: 500,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Choisir un pays',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Rechercher un pays',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          setDialogState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredCountries.length,
                        itemBuilder: (context, index) {
                          final country = filteredCountries[index];
                          return ListTile(
                            leading: Text(
                              country.flagEmoji,
                              style: const TextStyle(fontSize: 22),
                            ),
                            title: Text(country.name),
                            trailing: Text('+${country.phoneCode}'),
                            onTap: () {
                              setState(() {
                                _selectedCountry = country;
                                _phoneError = '';
                                _phoneController.clear();
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _validatePhone(String phone) {
    if (phone.isEmpty) {
      setState(() {
        _phoneError = 'Le numéro est obligatoire';
      });
      return;
    }

    String cleanedPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (cleanedPhone.isEmpty) {
      setState(() {
        _phoneError = 'Numéro invalide';
      });
      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(cleanedPhone)) {
      setState(() {
        _phoneError = 'Numéro invalide (chiffres uniquement)';
      });
      return;
    }

    int maxLength = _getMaxLengthForCountry(_selectedCountry.countryCode);
    if (cleanedPhone.length != maxLength) {
      setState(() {
        _phoneError = 'Le numéro doit contenir exactement $maxLength chiffres';
      });
      return;
    }

    if (!_isValidPrefix(cleanedPhone, _selectedCountry.countryCode)) {
      setState(() {
        _phoneError = 'Numéro invalide.';
      });
      return;
    }

    setState(() {
      _phoneError = '';
    });
  }

  void _validateCode(String code) {
    setState(() {
      if (code.isEmpty) {
        _codeError = 'Le code est obligatoire';
      } else if (code.length < _codeLength) {
        _codeError = 'Le code doit contenir $_codeLength chiffres';
      } else {
        _codeError = '';
      }
    });
  }

  Future<void> _login() async {
    _validatePhone(_phoneController.text);
    _validateCode(_codeController.text);

    if (_phoneError.isNotEmpty || _codeError.isNotEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String cleanedPhone = _phoneController.text.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      String enteredPin = _codeController.text;

      final authService = context.read<AuthService>();
      final result = await authService.login(cleanedPhone, enteredPin);

      if (result['status'] == 'success') {
        await _prefs.savePinCode(enteredPin);

        if (_rememberMe) {
          await _prefs.saveBool('remember_me', true);
        }

        if (mounted) {
          debugPrint('--- CONNEXION REUSSIE, NAVIGATION VERS HOME ---');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const MainNavigationScreen(),
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
          _codeError = result['message'] ?? 'Erreur de connexion';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _phoneError = 'Une erreur est survenue. Veuillez réessayer.';
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                const TText('login_title', style: AppTextStyles.title),
                const SizedBox(height: 8),
                const TText(
                  'login_desc',
                  style: AppTextStyles.description,
                ),

                const SizedBox(height: 40),

                const TText('phone_label', style: AppTextStyles.button),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _openCountryPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _selectedCountry.flagEmoji,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 6),
                            Text('+${_selectedCountry.phoneCode}'),
                            const Icon(Icons.arrow_drop_down, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(
                            _getMaxLengthForCountry(_selectedCountry.countryCode),
                          ),
                        ],
                        onChanged: (value) {
                          _validatePhone(value);
                        },
                        decoration: InputDecoration(
                          hintText: _getHintTextForCountry(_selectedCountry.countryCode),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixText: _getCounterText(_phoneController.text),
                          suffixStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_phoneError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _phoneError,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                const SizedBox(height: 16),

                const TText('pin_label', style: AppTextStyles.button),
                const SizedBox(height: 8),
                TextField(
                  controller: _codeController,
                  obscureText: !_isPasswordVisible,
                  keyboardType: TextInputType.number,
                  maxLength: _codeLength,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: _validateCode,
                  decoration: InputDecoration(
                    hintText: 'Entrez votre code',
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                if (_codeError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _codeError,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotCodeScreen(),
                        ),
                      );
                    },
                    child: const TText(
                      'forgot_pin',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_isLoading || _phoneError.isNotEmpty || _codeError.isNotEmpty)
                        ? null
                        : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const TText(
                            'login_btn',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getHintTextForCountry(String countryCode) {
    switch (countryCode) {
      case 'TG':
        return '90 00 00 00';
      case 'FR':
        return '6 12 34 56 78';
      case 'US':
        return '555 123 4567';
      case 'BJ':
        return '90 00 00 00';
      case 'CI':
        return '00 00 00 00';
      case 'SN':
        return '77 123 45 67';
      case 'CM':
        return '6 55 55 55 55';
      default:
        return '00 00 00 00';
    }
  }

  String _getCounterText(String currentText) {
    String cleaned = currentText.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    int maxLength = _getMaxLengthForCountry(_selectedCountry.countryCode);
    return '${cleaned.length}/$maxLength';
  }
}
