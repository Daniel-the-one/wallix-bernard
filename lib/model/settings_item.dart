import 'package:flutter/material.dart';

enum SettingsItemType { navigation, destructive }

class SettingsItemModel {
  final IconData icon;
  final String titleKey;
  final String? subtitleKey;
  final SettingsItemType type;
  final String route;

  const SettingsItemModel({
    required this.icon,
    required this.titleKey,
    this.subtitleKey,
    this.type = SettingsItemType.navigation,
    required this.route,
  });
}

class SettingsSectionModel {
  final String titleKey;
  final List<SettingsItemModel> items;

  const SettingsSectionModel({
    required this.titleKey,
    required this.items,
  });
}
