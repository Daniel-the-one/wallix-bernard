
import 'package:flutter/material.dart';
import '../model/profile_data.dart';
import '../model/settings_item.dart';
import '../data/shared_prefs_helper.dart';

class ProfileService {
  final SharedPrefsHelper _prefs = SharedPrefsHelper();

  ProfileModel getProfile() {
    String savedPhone = _prefs.getPhoneNumber();
    String phoneToDisplay = savedPhone.isNotEmpty ? savedPhone : '90 00 00 00';
    String agentName = _prefs.getAgentName();
    String nameToDisplay = agentName.isNotEmpty ? agentName : 'Agent 0077';

    return ProfileModel(
      agentCode: nameToDisplay,
      phoneNumber: phoneToDisplay,
      isVerified: _prefs.getBool('agent_verified', defaultValue: true),
    );
  }

  List<SettingsSectionModel> getSettingsSections() {


    return const [
      SettingsSectionModel(
        titleKey: 'settings_section_account',
        items: [
          SettingsItemModel(
            icon: Icons.receipt_long_outlined,
            titleKey: 'settings_withdrawals_title',
            subtitleKey: 'settings_withdrawals_subtitle',
            route: '/withdrawals',
          ),
          SettingsItemModel(
            icon: Icons.credit_card_outlined,
            titleKey: 'settings_commissions_title',
            subtitleKey: 'settings_commissions_subtitle',
            route: '/commissions',
          ),
          SettingsItemModel(
            icon: Icons.lock_outline_rounded,
            titleKey: 'settings_change_pin_title',
            subtitleKey: 'settings_change_pin_subtitle',
            route: '/change-pin',
          ),
          SettingsItemModel(
            icon: Icons.language_outlined,
            titleKey: 'settings_change_language_title',
            subtitleKey: 'settings_change_language_subtitle',
            route: '/change-language',
          ),
        ],
      ),
      SettingsSectionModel(
        titleKey: 'settings_section_help',
        items: [
          SettingsItemModel(
            icon: Icons.help_outline_rounded,
            titleKey: 'settings_faq_title',
            subtitleKey: 'settings_faq_subtitle',
            route: '/faq',
          ),
          SettingsItemModel(
            icon: Icons.headset_mic_outlined,
            titleKey: 'settings_support_title',
            subtitleKey: 'settings_support_subtitle',
            route: '/support',
          ),
          SettingsItemModel(
            icon: Icons.logout_rounded,
            titleKey: 'settings_logout_title',
            subtitleKey: 'settings_logout_subtitle',
            type: SettingsItemType.destructive,
            route: '/logout',
          ),
        ],
      ),
    ];
  }
}
