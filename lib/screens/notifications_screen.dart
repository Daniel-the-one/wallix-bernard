// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/notification_provider.dart';
import '../theme/app_colors.dart';
import '../model/notification_model.dart';
import '../widgets/t_text.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.black, size: 24),
            onPressed: () => _showClearAllDialog(context),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          final notifs = provider.notifications;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              if (notifs.isNotEmpty)
                ...notifs.map((notif) => _buildNotificationTile(notif))
              else
                ..._buildDefaultNotifications(),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildDefaultNotifications() {
    final List<Map<String, dynamic>> defaultData = [
      {
        'title': 'Dépôt effectué',
        'time': '20:19',
        'body': 'Dépôt de 5 000 Fcfa au client Ditoma. Commission de 8.50 Fcfa ajoutée à votre solde.',
        'date': '20 août 2026',
        'isRetrait': false,
      },
      {
        'title': 'Dépôt effectué',
        'time': '15:59',
        'body': 'Dépôt de 5 000 Fcfa au client Ditoma. Commission de 8.50 Fcfa ajoutée à votre solde.',
        'date': '16 août 2026',
        'isRetrait': false,
      },
      {
        'title': 'Retrait effectué',
        'time': '15:46',
        'body': 'Vous avez effectué un retrait de 700 Fcfa au client Bernard. Commission de 2.17 Fcfa ajoutée à votre solde.',
        'date': '10 août 2026',
        'isRetrait': true,
      },
      {
        'title': 'Dépôt effectué',
        'time': '12:10',
        'body': 'Dépôt de 1 000 Fcfa au client Bernard. Commission de 1.70 Fcfa ajoutée à votre solde.',
        'date': '10 août 2026',
        'isRetrait': false,
      },
    ];

    return defaultData.map((item) {
      final bool isRetrait = item['isRetrait'] as bool;
      final Color themeColor = isRetrait ? AppColors.primaryGreen : Colors.red;

      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['title'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  item['time'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item['body'] as String,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                item['date'] as String,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildNotificationTile(NotificationModel notif) {
    final bool isRetrait = notif.title.toLowerCase().contains('retrait');
    final Color themeColor = isRetrait ? AppColors.primaryGreen : Colors.red;
    final String timeStr = DateFormat.Hm().format(notif.timestamp);
    final String dateStr = DateFormat('d MMMM yyyy').format(notif.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                notif.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                timeStr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            notif.body,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              dateStr,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tout supprimer'),
        content: const Text('Voulez-vous supprimer toutes vos notifications ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const TText('cancel', style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              context.read<NotificationProvider>().clearAllNotifications();
              Navigator.pop(context);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
