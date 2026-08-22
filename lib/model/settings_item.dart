import 'package:flutter/material.dart';

enum SettingsItemType { navigation, destructive }

class SettingsItemModel {
  final IconData icon;
  final String title;
  final String? subtitle;
  final SettingsItemType type;
  final String route;

  const SettingsItemModel({
    required this.icon,
    required this.title,
    this.subtitle,
    this.type = SettingsItemType.navigation,
    required this.route,
  });
}

class SettingsSectionModel {
  final String title;
  final List<SettingsItemModel> items;

  const SettingsSectionModel({
    required this.title,
    required this.items,
  });
}