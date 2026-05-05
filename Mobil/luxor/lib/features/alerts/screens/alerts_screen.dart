import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/api_client.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<dynamic> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() => _isLoading = true);
    try {
      final resp = await ApiClient.dio.get('/notifications');
      if (resp.data['success'] == true) {
        final data = resp.data['data'];
        setState(() {
          _notifications = (data['notifications'] as List<dynamic>? ?? []);
          _unreadCount = (data['unreadCount'] as num?)?.toInt() ?? 0;
        });
      }
    } catch (e) {}
    finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAllRead() async {
    try {
      await ApiClient.dio.put('/notifications/read-all');
      _loadAlerts();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  const Text('Alertas', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                  if (_unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: LuxorColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$_unreadCount', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ],
                  const Spacer(),
                  if (_notifications.isNotEmpty)
                    TextButton(
                      onPressed: _markAllRead,
                      child: const Text('Marcar todo leído', style: TextStyle(color: LuxorColors.primary, fontSize: 12)),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: LuxorColors.primary))
                  : RefreshIndicator(
                      onRefresh: _loadAlerts,
                      color: LuxorColors.primary,
                      child: _notifications.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.notifications_none, size: 48, color: LuxorColors.textMuted),
                                  SizedBox(height: 16),
                                  Text('No hay notificaciones', style: TextStyle(color: LuxorColors.textMuted)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _notifications.length,
                              itemBuilder: (context, index) {
                                final notif = _notifications[index];
                                return _NotificationTile(
                                  title: notif['title'] ?? '',
                                  body: notif['body'] ?? '',
                                  time: _formatDate(notif['createdAt']),
                                  isRead: notif['isRead'] == true,
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes} min';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}d';
      return '${date.day}/${date.month}';
    } catch (e) {
      return '';
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final String title;
  final String body;
  final String time;
  final bool isRead;

  const _NotificationTile({
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRead ? Colors.transparent : LuxorColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LuxorColors.surfaceElevated.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: LuxorColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications, color: LuxorColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                if (body.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(body, style: const TextStyle(color: LuxorColors.textSecondary, fontSize: 12)),
                ],
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(color: LuxorColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          if (!isRead)
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(
                color: LuxorColors.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
