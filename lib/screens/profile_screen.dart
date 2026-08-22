// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../widgets/t_text.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/settings_section_widget.dart';
import '../widgets/language_bottom_sheet.dart';
import '../widgets/logout_confirm_dialog.dart';
import 'retraits_screen.dart';
import 'commissions_screen.dart';
import 'change_pin_screen.dart';
import 'faq_screen.dart';
import 'support_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with AutomaticKeepAliveClientMixin {
  final ProfileService _profileService = ProfileService();

  @override
  bool get wantKeepAlive => true;

  void _showLogoutDialog(BuildContext context) {
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

  void _handleItemTap(BuildContext context, String route) {
    switch (route) {
      case '/withdrawals':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const RetraitsScreen()));
        break;
      case '/commissions':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CommissionsScreen()));
        break;
      case '/change-pin':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePinScreen()));
        break;
      case '/change-language':
        LanguageBottomSheet.show(context);
        break;
      case '/faq':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen()));
        break;
      case '/support':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()));
        break;
      case '/logout':
        _showLogoutDialog(context);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final profile = _profileService.getProfile();
    final sections = _profileService.getSettingsSections();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        title: const TText(
          'profile_title',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          ProfileHeaderCard(profile: profile),
          const SizedBox(height: 24),
          ...sections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SettingsSectionWidget(
                section: section,
                onItemTap: (item) => _handleItemTap(context, item.route),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
