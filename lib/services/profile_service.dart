// lib/services/profile_service.dart
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
        title: 'Détails du compte',
        items: [
          SettingsItemModel(
            icon: Icons.receipt_long_outlined,
            title: 'Liste des retraits',
            subtitle: 'Consulter vos retraits',
            route: '/withdrawals',
          ),
          SettingsItemModel(
            icon: Icons.credit_card_outlined,
            title: 'Commissions',
            subtitle: 'Voir vos gains',
            route: '/commissions',
          ),
          SettingsItemModel(
            icon: Icons.lock_outline_rounded,
            title: 'Changer mon code de sécurité',
            subtitle: 'Modifier votre code PIN',
            route: '/change-pin',
          ),
          SettingsItemModel(
            icon: Icons.language_outlined,
            title: 'Changer la langue',
            subtitle: 'Sélectionner une langue',
            route: '/change-language',
          ),
        ],
      ),
      SettingsSectionModel(
        title: 'Aide et support',
        items: [
          SettingsItemModel(
            icon: Icons.help_outline_rounded,
            title: 'FAQ',
            subtitle: 'Questions fréquentes',
            route: '/faq',
          ),
          SettingsItemModel(
            icon: Icons.headset_mic_outlined,
            title: 'Service client',
            subtitle: 'Nous contacter',
            route: '/support',
          ),
          SettingsItemModel(
            icon: Icons.logout_rounded,
            title: 'Déconnexion',
            type: SettingsItemType.destructive,
            route: '/logout',
          ),
        ],
      ),
    ];
  }
}
