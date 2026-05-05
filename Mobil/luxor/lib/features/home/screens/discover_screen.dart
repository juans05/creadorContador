import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/api_client.dart';
import '../../../features/shared/widgets/luxor_widgets.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  List<dynamic> _creators = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int _selectedTag = 0;
  final _tags = ['#Trending', '#New', '#Latam', '#Live'];

  @override
  void initState() {
    super.initState();
    _loadDiscover();
  }

  Future<void> _loadDiscover() async {
    setState(() => _isLoading = true);
    try {
      final resp = await ApiClient.dio.get('/home/feed', queryParameters: {'limit': 20, 'sort': 'trending'});
      if (resp.data['success'] == true) {
        setState(() {
          _creators = (resp.data['data']['creators'] as List<dynamic>? ?? []).take(20).toList();
        });
      }
    } catch (e) {}
    finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _search(String query) async {
    if (query.length < 2) return;
    try {
      final resp = await ApiClient.dio.get('/home/search', queryParameters: {'q': query, 'limit': 20});
      if (resp.data['success'] == true) {
        setState(() {
          _creators = resp.data['data']['creators'] as List<dynamic>? ?? [];
          _searchQuery = query;
        });
      }
    } catch (e) {}
  }

  void _showSearchModal(BuildContext ctx) {
    final controller = TextEditingController(text: _searchQuery);
    showDialog<String>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Buscar'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: 'Nombre del creador...')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(dialogCtx, controller.text), child: const Text('Buscar')),
        ],
      ),
    ).then((query) {
      if (query != null && query.isNotEmpty) _search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: LuxorColors.primary))
            : CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: LuxorColors.primary,
                            child: Icon(Icons.diamond, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'LUXOR',
                            style: TextStyle(
                              color: LuxorColors.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                          const Spacer(),
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: LuxorColors.surface,
                            child: const Icon(Icons.settings_outlined, color: Colors.white, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Search bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: GestureDetector(
                        onTap: () {
                          _showSearchModal(context);
                        },
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: LuxorColors.surface,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: LuxorColors.surfaceElevated.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              const Icon(Icons.search, color: LuxorColors.textMuted, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _searchQuery.isNotEmpty ? _searchQuery : 'Buscar creadores...',
                                style: TextStyle(color: LuxorColors.textMuted, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Tags
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: List.generate(_tags.length, (i) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: LuxorTag(
                              label: _tags[i],
                              selected: _selectedTag == i,
                              onTap: () => setState(() => _selectedTag = i),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Top Creators section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const Text(
                            'Top Creators',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'Ver todos',
                              style: TextStyle(color: LuxorColors.primary, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Top creators horizontal list
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _creators.isEmpty ? 4 : _creators.length,
                        itemBuilder: (context, index) {
                          if (_creators.isEmpty) {
                            return _buildCreatorPlaceholder(index);
                          }
                          final creator = _creators[index];
                          return _CreatorAvatar(
                            name: creator['username'] ?? 'Creator',
                            avatar: creator['profilePicture'] ?? '',
                            username: creator['username'] ?? '',
                            onTap: () => context.go('/creador/${creator['username']}'),
                          );
                        },
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Trending section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Text(
                        'Trending Ahora',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Trending grid
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.7,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (_creators.isEmpty) {
                            return _buildTrendingPlaceholder();
                          }
                          if (index >= _creators.length) return null;
                          final creator = _creators[index];
                          final preview = (creator['previewPhotos'] as List?)?.first;
                          return _TrendingCard(
                            thumbnail: preview?['thumbnail'] ?? preview?['url'] ?? '',
                            title: '@${creator['username'] ?? ''}',
                            onTap: () => context.go('/creador/${creator['username']}'),
                          );
                        },
                        childCount: _creators.isEmpty ? 6 : _creators.length,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
      ),
    );
  }

  Widget _buildCreatorPlaceholder(int index) {
    final names = ['Elena G.', 'Mateo V.', 'Sofia R.', 'Carlos M.'];
    return _CreatorAvatar(
      name: names[index % names.length],
      avatar: '',
      username: '',
      onTap: () {},
    );
  }

  Widget _buildTrendingPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: LuxorColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.play_circle_outline, color: LuxorColors.textMuted, size: 40),
      ),
    );
  }
}

class _CreatorAvatar extends StatelessWidget {
  final String name;
  final String avatar;
  final String username;
  final VoidCallback onTap;

  const _CreatorAvatar({
    required this.name,
    required this.avatar,
    required this.username,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 85,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LuxorColors.gradientPrimary,
                boxShadow: [
                  BoxShadow(
                    color: LuxorColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(2.5),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: LuxorColors.background,
                backgroundImage: avatar.isNotEmpty ? CachedNetworkImageProvider(avatar) : null,
                child: avatar.isEmpty
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: LuxorColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Follow',
                style: TextStyle(color: LuxorColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final String thumbnail;
  final String title;
  final VoidCallback onTap;

  const _TrendingCard({required this.thumbnail, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            thumbnail.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: thumbnail,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: LuxorColors.surface),
                    errorWidget: (_, __, ___) => Container(
                      color: LuxorColors.surface,
                      child: const Icon(Icons.play_circle_outline, color: LuxorColors.textMuted, size: 40),
                    ),
                  )
                : Container(
                    color: LuxorColors.surface,
                    child: const Icon(Icons.play_circle_outline, color: LuxorColors.textMuted, size: 40),
                  ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
