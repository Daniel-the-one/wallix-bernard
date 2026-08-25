
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../services/auth_service.dart';
import '../widgets/t_text.dart';

class ForgotCodeScreen extends StatefulWidget {
  const ForgotCodeScreen({super.key});

  @override
  State<ForgotCodeScreen> createState() => _ForgotCodeScreenState();
}

class _ForgotCodeScreenState extends State<ForgotCodeScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _requestSent = false;

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
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
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
                          TText(
                            'country_picker_title',
                            style: const TextStyle(
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
                          hintText: TText.of(context).translate('country_picker_search'),
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

  void _sendResetRequest() async {
    if (_phoneController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final phone = '+${_selectedCountry.phoneCode}${_phoneController.text}';

      final result = await context.read<AuthService>().forgotPassword(phone);

      if (!mounted) return;
      if (result.isSuccess) {
        setState(() {
          _isLoading = false;
          _requestSent = true;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? TText.of(context).translate('forgot_error')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${TText.of(context).translate('error')} : $e')),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
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

              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: _requestSent ? _buildSuccessView() : _buildFormView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TText('forgot_pin', style: AppTextStyles.title),
        const SizedBox(height: 8),
        TText(
          'forgot_desc',
          style: AppTextStyles.description,
        ),

        const SizedBox(height: 40),

        TText('phone_label', style: AppTextStyles.button),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: _openCountryPicker,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                decoration: InputDecoration(
                  hintText: '90 00 00 00',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sendResetRequest,
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
                : TText(
                    'forgot_submit',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: AppColors.primaryGreen,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          const TText(
            'forgot_success_title',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TText(
              'forgot_success_desc',
              textAlign: TextAlign.center,
              style: AppTextStyles.description,
            ),
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const TText(
              'forgot_back_login',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
