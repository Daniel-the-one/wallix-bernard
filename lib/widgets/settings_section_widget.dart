
import 'package:flutter/material.dart';
import '../model/settings_item.dart';
import 'settings_tile.dart';
import 't_text.dart';

class SettingsSectionWidget extends StatelessWidget {
  final SettingsSectionModel section;
  final void Function(SettingsItemModel) onItemTap;

  const SettingsSectionWidget({
    super.key,
    required this.section,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: TText(
            section.titleKey,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
        Column(
          children: section.items.map((item) {
            return SettingsTile(
              item: item,
              onTap: () => onItemTap(item),
            );
          }).toList(),
        ),
      ],
    );
  }
}
