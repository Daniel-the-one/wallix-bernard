
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
        title: const TText(
          'notifications_title',
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
                _buildEmptyState(),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }



  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.notifications_off_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const TText(
            'notifications_empty',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
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
        title: const TText('delete_all'),
        content: const TText('delete_all_confirm'),
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
            child: const TText('delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
