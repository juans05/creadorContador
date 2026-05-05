import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/api_client.dart';
import '../../../core/utils/format_utils.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _stats;
  List<dynamic> _recentPosts = [];
  List<dynamic> _recentActivity = [];
  bool _isLoading = true;

  Future<void> _load() async {
    try {
      final resp = await ApiClient.dio.get('/influencers/dashboard/stats');
      if (resp.data['success'] == true) {
        setState(() {
          _stats = resp.data['data'];
          _recentPosts = resp.data['data']['recent_posts'] ?? [];
          _recentActivity = resp.data['data']['recent_activity'] ?? [];
        });
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() { super.initState(); _load(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: LuxorColors.primary))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Header
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LuxorColors.gradientPrimary,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: const CircleAvatar(
                            radius: 18,
                            backgroundColor: LuxorColors.background,
                            child: Icon(Icons.person, color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('Creator Studio', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Earnings card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: LuxorColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: LuxorColors.surfaceElevated.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('TOTAL EARNINGS', style: TextStyle(color: LuxorColors.textMuted, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w600)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: LuxorColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.account_balance_wallet, color: LuxorColors.primary, size: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${(_stats?['total_earnings'] ?? 0).toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('PENDING', style: TextStyle(color: LuxorColors.textMuted, fontSize: 9, letterSpacing: 0.5)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '\$${(_stats?['pending_earnings'] ?? 0).toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 40),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('NEXT PAYOUT', style: TextStyle(color: LuxorColors.textMuted, fontSize: 9, letterSpacing: 0.5)),
                                  const SizedBox(height: 2),
                                  Text(
                                    _stats?['next_payout'] ?? 'Oct 15',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Action buttons
                    Row(
                      children: [
                        _ActionButton(icon: Icons.upload_outlined, label: 'Upload', onTap: () => context.go('/dashboard/upload')),
                        const SizedBox(width: 12),
                        _ActionButton(icon: Icons.broadcast_on_personal, label: 'Go Live', onTap: () {}),
                        const SizedBox(width: 12),
                        _ActionButton(icon: Icons.store_outlined, label: 'Store', onTap: () {}),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Stats row
                    Row(
                      children: [
                        _MiniStatCard(
                          label: 'Subscribers',
                          value: formatCount((_stats?['suscriptores_count'] as num?)?.toInt() ?? 0),
                          change: '+${_stats?['new_subs'] ?? 0}',
                          changeColor: LuxorColors.success,
                        ),
                        const SizedBox(width: 12),
                        _MiniStatCard(
                          label: 'Views',
                          value: formatCount((_stats?['views_count'] as num?)?.toInt() ?? 0),
                          change: formatCount((_stats?['views_count'] as num?)?.toInt() ?? 0),
                          changeColor: LuxorColors.primary,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Recent Posts
                    Row(
                      children: [
                        const Text('Recent Posts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {},
                          child: const Text('VIEW ALL', style: TextStyle(color: LuxorColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (_recentPosts.isEmpty)
                      ..._buildPlaceholderPosts()
                    else
                      ..._recentPosts.map((p) => _RecentPostTile(post: p)),

                    const SizedBox(height: 24),

                    // Recent Activity
                    const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),

                    if (_recentActivity.isEmpty)
                      ..._buildPlaceholderActivity()
                    else
                      ..._recentActivity.map((a) => _ActivityTile(activity: a)),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }

  List<Widget> _buildPlaceholderPosts() {
    return [
      _PlaceholderPostTile(title: 'Exclusive DJ Set', badge: 'PREMIUM', views: '12.4k', earnings: '\$842'),
      _PlaceholderPostTile(title: 'Vlog: Life in Bogotá', badge: 'FREE', views: '31k', earnings: null),
      _PlaceholderPostTile(title: 'Behind the Scenes', badge: 'PREMIUM', views: '5.5k', earnings: '\$210'),
    ];
  }

  List<Widget> _buildPlaceholderActivity() {
    return [
      _PlaceholderActivityTile(icon: Icons.person_add, text: 'Maria subscribed to your tier', time: '2 MINUTES AGO'),
      _PlaceholderActivityTile(icon: Icons.diamond, text: 'Juan sent 50 Diamonds', time: '15 MINUTES AGO', iconColor: LuxorColors.diamond),
      _PlaceholderActivityTile(icon: Icons.favorite, text: 'Carlos liked your post', time: '1 HOUR AGO', iconColor: LuxorColors.primary),
    ];
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: LuxorColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: LuxorColors.surfaceElevated.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Icon(icon, color: LuxorColors.primary, size: 24),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: LuxorColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String change;
  final Color changeColor;

  const _MiniStatCard({required this.label, required this.value, required this.change, required this.changeColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LuxorColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: LuxorColors.surfaceElevated.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: LuxorColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Text(change, style: TextStyle(color: changeColor, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentPostTile extends StatelessWidget {
  final Map<String, dynamic> post;
  const _RecentPostTile({required this.post});

  @override
  Widget build(BuildContext context) {
    final isPremium = post['visibility'] == 'subscribers' || post['visibility'] == 'ppv';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LuxorColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 48, height: 48,
              color: LuxorColors.surfaceElevated,
              child: post['thumbnail_url'] != null
                  ? CachedNetworkImage(imageUrl: post['thumbnail_url'], fit: BoxFit.cover)
                  : const Icon(Icons.play_circle, color: LuxorColors.textMuted),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(post['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPremium ? LuxorColors.primary.withValues(alpha: 0.15) : LuxorColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isPremium ? 'PREMIUM' : 'FREE',
                        style: TextStyle(color: isPremium ? LuxorColors.primary : LuxorColors.success, fontSize: 9, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.visibility, size: 12, color: LuxorColors.textMuted),
                    const SizedBox(width: 4),
                    Text(formatCount((post['views_count'] as num?)?.toInt() ?? 0), style: const TextStyle(color: LuxorColors.textMuted, fontSize: 11)),
                    if (post['earnings'] != null) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.diamond, size: 12, color: LuxorColors.diamond),
                      const SizedBox(width: 4),
                      Text('\$${post['earnings']}', style: const TextStyle(color: LuxorColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderPostTile extends StatelessWidget {
  final String title;
  final String badge;
  final String views;
  final String? earnings;

  const _PlaceholderPostTile({required this.title, required this.badge, required this.views, this.earnings});

  @override
  Widget build(BuildContext context) {
    final isPremium = badge == 'PREMIUM';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LuxorColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 48, height: 48,
              color: LuxorColors.surfaceElevated,
              child: const Icon(Icons.play_circle, color: LuxorColors.textMuted, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPremium ? LuxorColors.primary.withValues(alpha: 0.15) : LuxorColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(badge, style: TextStyle(color: isPremium ? LuxorColors.primary : LuxorColors.success, fontSize: 9, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.visibility, size: 12, color: LuxorColors.textMuted),
                    const SizedBox(width: 4),
                    Text(views, style: const TextStyle(color: LuxorColors.textMuted, fontSize: 11)),
                    if (earnings != null) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.diamond, size: 12, color: LuxorColors.diamond),
                      const SizedBox(width: 4),
                      Text(earnings!, style: const TextStyle(color: LuxorColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderActivityTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final String time;
  final Color? iconColor;

  const _PlaceholderActivityTile({required this.icon, required this.text, required this.time, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? LuxorColors.textSecondary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 2),
                Text(time, style: const TextStyle(color: LuxorColors.textMuted, fontSize: 10, letterSpacing: 0.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final Map<String, dynamic> activity;
  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.notifications_outlined, color: LuxorColors.textSecondary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity['message'] ?? '', style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 2),
                Text(activity['time'] ?? '', style: const TextStyle(color: LuxorColors.textMuted, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
