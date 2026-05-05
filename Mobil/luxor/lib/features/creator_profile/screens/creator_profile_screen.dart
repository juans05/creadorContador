import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/api_client.dart';
import '../../../core/utils/format_utils.dart';
import '../../../features/shared/widgets/luxor_widgets.dart';

class CreatorProfileScreen extends StatefulWidget {
  final String username;
  final bool isGridView;
  const CreatorProfileScreen({super.key, required this.username, this.isGridView = false});

  @override
  State<CreatorProfileScreen> createState() => _CreatorProfileScreenState();
}

class _CreatorProfileScreenState extends State<CreatorProfileScreen> {
  Map<String, dynamic>? _creator;
  List<dynamic> _grid = [];
  bool _isLoading = true;
  int _selectedTab = 0;
  bool _isGridView = false;
  final _tabs = ['Feed', 'Videoteca', 'Shout Outs', 'Sobre mi'];

  Future<void> _load() async {
    try {
      // Load profile
      final resp = await ApiClient.dio.get('/influencers/${widget.username}');
      if (resp.data['success'] == true) {
        setState(() => _creator = resp.data['data']);
      }
    } catch (e) {} finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadGrid() async {
    try {
      final resp = await ApiClient.dio.get('/influencers/${widget.username}/grid');
      if (resp.data['success'] == true) {
        setState(() => _grid = resp.data['data']['grid'] ?? []);
      }
    } catch (e) {}
  }

  @override
  void initState() { 
    super.initState(); 
    _load();
    if (widget.isGridView) {
      _selectedTab = 1;
      _loadGrid();
    }
  }

  void _onTabTap(int index) {
    setState(() => _selectedTab = index);
    if (index == 1 && _grid.isEmpty) {
      _loadGrid();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: LuxorColors.primary)),
      );
    }
    if (_creator == null) {
      return Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: const Center(child: Text('Creador no encontrado')),
      );
    }

    final name = _creator!['name'] ?? '';
    final username = _creator!['username'] ?? widget.username;
    final bio = _creator!['bio'] ?? '';
    final avatar = _creator!['avatar'] ?? '';
    final coverUrl = _creator!['cover_url'] ?? '';
    final fans = (_creator!['fans_count'] as num?)?.toInt() ?? 0;
    final likes = (_creator!['likes_count'] as num?)?.toInt() ?? 0;
    final subscriptionPrice = _creator!['subscription_price'] ?? 9.99;
    final tags = (_creator!['tags'] as List<dynamic>?)?.cast<String>() ?? [];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Cover + profile header
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Cover image
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: LuxorColors.surface,
                    image: coverUrl.isNotEmpty
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(coverUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, LuxorColors.background.withValues(alpha: 0.9)],
                      ),
                    ),
                  ),
                ),

                // Back button + header
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 12,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.black38,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                      onPressed: () => context.pop(),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),

                // Profile info overlapping cover
                Positioned(
                  top: 120,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LuxorColors.gradientPrimary,
                            border: Border.all(color: LuxorColors.background, width: 3),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: CircleAvatar(
                            radius: 36,
                            backgroundColor: LuxorColors.background,
                            backgroundImage: avatar.isNotEmpty ? CachedNetworkImageProvider(avatar) : null,
                            child: avatar.isEmpty
                                ? Text(name.isNotEmpty ? name[0] : '?', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700))
                                : null,
                          ),
                        ),
                        const Spacer(),
                        // Stats
                        _MiniStat(value: formatCount(fans), label: 'FANS'),
                        const SizedBox(width: 20),
                        _MiniStat(value: formatCount(likes), label: 'LIKES'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(child: const SizedBox(height: 70)),

          // Name + bio
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.verified, color: LuxorColors.primary, size: 18),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('@$username', style: const TextStyle(color: LuxorColors.textSecondary, fontSize: 14)),
                  if (bio.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(bio, style: const TextStyle(color: LuxorColors.textSecondary, fontSize: 13, height: 1.5)),
                  ],
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags.map((t) => LuxorTag(label: '#$t')).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Subscribe button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LuxorColors.gradientPrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.star, size: 18),
                        label: Text('Suscribirse  \$$subscriptionPrice/mes', style: const TextStyle(fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Tabs
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_tabs.length, (i) {
                          final selected = _selectedTab == i;
                          return GestureDetector(
                            onTap: () => _onTabTap(i),
                            child: Container(
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: selected ? LuxorColors.primary : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                _tabs[i],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                                  color: selected ? Colors.white : LuxorColors.textMuted,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  if (_selectedTab == 1)
                    IconButton(
                      icon: Icon(_isGridView ? Icons.view_carousel : Icons.grid_view, color: Colors.white70),
                      onPressed: () => setState(() => _isGridView = !_isGridView),
                    ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Content based on tab
          _selectedTab == 1 ? _buildGridContent() : _buildFeedContent(),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildGridContent() {
    if (_grid.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.photo_library, size: 48, color: LuxorColors.textMuted),
                const SizedBox(height: 16),
                const Text('No hay contenido disponible', style: TextStyle(color: LuxorColors.textMuted)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadGrid,
                  child: const Text('Recargar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_isGridView) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = _grid[index];
              final thumbnail = item['thumbnail'] ?? item['url'] ?? '';
              final hasAccess = item['hasAccess'] == true;
              final isVideo = item['type'] == 'video';
              
              return GestureDetector(
                onTap: () {
                  if (hasAccess) {
                    // Open content viewer
                  } else {
                    // Show unlock dialog
                  }
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: thumbnail,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: LuxorColors.surface),
                      errorWidget: (_, __, ___) => Container(color: LuxorColors.surface),
                    ),
                    if (isVideo)
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.play_arrow, color: Colors.white, size: 12),
                        ),
                      ),
                    if (!hasAccess)
                      Container(
                        color: Colors.black54,
                        child: Center(
                          child: Icon(Icons.lock, color: LuxorColors.primary, size: 20),
                        ),
                      ),
                  ],
                ),
              );
            },
            childCount: _grid.length,
          ),
        ),
      );
    }

    // List view (Videoteca style)
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = _grid[index];
          return _ContentPost(content: item);
        },
        childCount: _grid.length,
      ),
    );
  }

  Widget _buildFeedContent() {
    final photos = _creator?['photos'] as List? ?? [];
    if (photos.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Text(
              'No hay contenido disponible',
              style: TextStyle(color: LuxorColors.textMuted),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final content = photos[index];
          return _ContentPost(content: content);
        },
        childCount: photos.length,
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  const _MiniStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: LuxorColors.textMuted, fontSize: 9, letterSpacing: 0.5, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _ContentPost extends StatelessWidget {
  final Map<String, dynamic> content;
  const _ContentPost({required this.content});

  @override
  Widget build(BuildContext context) {
    final description = content['description'] ?? '';
    final thumbnail = content['thumbnail_url'] ?? '';
    final views = (content['views_count'] as num?)?.toInt() ?? 0;
    final comments = (content['comments_count'] as num?)?.toInt() ?? 0;
    final isLocked = content['visibility'] == 'ppv' || content['visibility'] == 'subscribers';
    final ppvPrice = content['ppv_price_diamonds'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Creator header
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: LuxorColors.surface,
                child: const Icon(Icons.person, color: LuxorColors.textMuted, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(content['creator_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(width: 6),
                      if (isLocked)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: LuxorColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Exclusivo', style: TextStyle(color: LuxorColors.primary, fontSize: 9, fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                  if (description.isNotEmpty)
                    Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: LuxorColors.textSecondary, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Thumbnail
          if (thumbnail.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedNetworkImage(
                      imageUrl: thumbnail,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: LuxorColors.surface),
                      errorWidget: (_, __, ___) => Container(color: LuxorColors.surface),
                    ),
                  ),
                  if (isLocked)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lock, color: LuxorColors.primary, size: 28),
                              const SizedBox(height: 8),
                              const Text('Contenido Exclusivo', style: TextStyle(fontWeight: FontWeight.w600)),
                              if (ppvPrice != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LuxorColors.gradientPrimary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Desbloquear por \$$ppvPrice',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.visibility, size: 14, color: LuxorColors.textMuted),
                const SizedBox(width: 4),
                Text(formatCount(views), style: const TextStyle(color: LuxorColors.textMuted, fontSize: 12)),
                const SizedBox(width: 16),
                const Icon(Icons.chat_bubble_outline, size: 14, color: LuxorColors.textMuted),
                const SizedBox(width: 4),
                Text(formatCount(comments), style: const TextStyle(color: LuxorColors.textMuted, fontSize: 12)),
              ],
            ),
          ),

          const Divider(color: LuxorColors.surfaceElevated, height: 1),
        ],
      ),
    );
  }
}
