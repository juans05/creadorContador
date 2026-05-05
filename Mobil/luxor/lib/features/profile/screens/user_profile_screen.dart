import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/api_client.dart';
import '../../../core/utils/format_utils.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  String? _error;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final resp = await ApiClient.dio.get('/auth/me');
      if (resp.data['success'] == true) {
        setState(() => _user = resp.data['data']);
      } else {
        setState(() => _error = resp.data['message']);
      }
    } on DioException catch (_) {
      setState(() => _error = 'Error de conexión');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void refresh() {
    _loadProfile();
  }

  Future<void> _logout() async {
    await ApiClient.clearTokens();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: LuxorColors.primary))
          : _error != null
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(_error!, style: const TextStyle(color: LuxorColors.error)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _loadProfile, child: const Text('Reintentar')),
                  ]),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                          child: Row(
                            children: [
                              const Text(
                                'Mi Perfil',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Avatar
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LuxorColors.gradientPrimary,
                          ),
                          padding: const EdgeInsets.all(3),
                          child: CircleAvatar(
                            radius: 42,
                            backgroundColor: LuxorColors.background,
                            backgroundImage: (_user?['avatar'] ?? '').isNotEmpty
                                ? CachedNetworkImageProvider(_user!['avatar'])
                                : null,
                            child: (_user?['avatar'] ?? '').isEmpty
                                ? Text(
                                    (_user?['name'] ?? 'U').substring(0, 1).toUpperCase(),
                                    style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                        ),

                        const SizedBox(height: 14),
                        Text(
                          _user?['name'] ?? '',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${_user?['username'] ?? _user?['email']?.split('@')[0] ?? ''}',
                          style: const TextStyle(color: LuxorColors.textSecondary, fontSize: 14),
                        ),
                        if ((_user?['bio'] ?? '').isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              _user!['bio'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: LuxorColors.textSecondary, fontSize: 13, height: 1.4),
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _StatItem(
                              value: formatCount((_user?['followers_count'] as num?)?.toInt() ?? 0),
                              label: 'SEGUIDORES',
                            ),
                            Container(
                              width: 1, height: 30,
                              margin: const EdgeInsets.symmetric(horizontal: 24),
                              color: LuxorColors.surfaceElevated,
                            ),
                            _StatItem(
                              value: formatCount((_user?['following_count'] as num?)?.toInt() ?? 0),
                              label: 'SIGUIENDO',
                            ),
                            Container(
                              width: 1, height: 30,
                              margin: const EdgeInsets.symmetric(horizontal: 24),
                              color: LuxorColors.surfaceElevated,
                            ),
                            _StatItem(
                              value: formatCount((_user?['diamonds_count'] as num?)?.toInt() ?? 0),
                              label: 'DIAMANTES',
                              valueColor: LuxorColors.primary,
                              icon: Icons.diamond,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Action buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: LuxorColors.surfaceElevated),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Editar Perfil', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => context.go('/dashboard'),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: LuxorColors.surfaceElevated),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Creator Studio', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Content tabs
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              _TabButton(icon: Icons.grid_view_rounded, label: 'Contenido', selected: _selectedTab == 0, onTap: () => setState(() => _selectedTab = 0)),
                              _TabButton(icon: Icons.bookmark_border, label: 'Guardado', selected: _selectedTab == 1, onTap: () => setState(() => _selectedTab = 1)),
                              _TabButton(icon: Icons.favorite_border, label: 'Me gusta', selected: _selectedTab == 2, onTap: () => setState(() => _selectedTab = 2)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Content grid placeholder
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 4,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: 9,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: LuxorColors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Icon(Icons.play_circle_outline, color: LuxorColors.textMuted, size: 24),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Logout
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextButton.icon(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout, color: LuxorColors.error, size: 18),
                            label: const Text('Cerrar sesión', style: TextStyle(color: LuxorColors.error)),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;
  final IconData? icon;

  const _StatItem({required this.value, required this.label, this.valueColor, this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: valueColor ?? Colors.white, size: 14),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: valueColor ?? Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(color: LuxorColors.textMuted, fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? LuxorColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? Colors.white : LuxorColors.textMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? Colors.white : LuxorColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
