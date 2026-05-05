import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/api_client.dart';
import '../../../core/utils/format_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  List<dynamic> _creators = [];
  bool _isLoading = true;
  String _category = 'adult';
  String _sort = 'trending';

  final _categories = ['Adult', 'Music', 'Gaming', 'Beauty', 'Influencer'];
  final _categorySlugs = ['adult', 'music', 'gaming', 'beauty', 'influencer'];
  final _tags = ['#Trending', '#New', '#Latam', '#Live'];
  final _sortValues = ['trending', 'new', 'latam', 'live'];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _loadFeed();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadFeed() async {
    setState(() => _isLoading = true);
    try {
      final resp = await ApiClient.dio.get('/home/feed', queryParameters: {
        'category': _category,
        'sort': _sort,
        'limit': 20,
      });
      if (resp.data['success'] == true) {
        setState(() {
          _creators = resp.data['data']['creators'] ?? [];
        });
      }
    } on DioException catch (_) {
      // keeps previous content on network error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onCategoryTap(int index) {
    setState(() {
      _category = _categorySlugs[index];
    });
    _pageController.jumpToPage(0);
    _loadFeed();
  }

  void _onSortTap(int index) {
    setState(() {
      _sort = _sortValues[index];
    });
    _pageController.jumpToPage(0);
    _loadFeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: LuxorColors.primary))
              : _creators.isEmpty
                  ? const Center(child: Text('No hay contenido', style: TextStyle(color: Colors.white)))
                  : PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      itemCount: _creators.length,
                      itemBuilder: (context, index) => _FeedItem(
                        creator: _creators[index],
                        index: index,
                        totalCreators: _creators.length,
                      ),
                    ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(children: [
                    const Text(
                      'LUXOR',
                      style: TextStyle(
                        color: LuxorColors.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () {}),
                  ]),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: List.generate(_categories.length, (i) {
                      final selected = _category == _categorySlugs[i];
                      return GestureDetector(
                        onTap: () => _onCategoryTap(i),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Column(children: [
                            Text(
                              _categories[i],
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.white54,
                                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (selected)
                              Container(width: 20, height: 2, color: LuxorColors.primary),
                          ]),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: List.generate(_tags.length, (i) {
                      final selected = _sort == _sortValues[i];
                      return GestureDetector(
                        onTap: () => _onSortTap(i),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: selected
                                ? LuxorColors.primary.withValues(alpha: 0.9)
                                : Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _tags[i],
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedItem extends StatefulWidget {
  final Map<String, dynamic> creator;
  final int index;
  final int totalCreators;

  const _FeedItem({required this.creator, required this.index, required this.totalCreators});

  @override
  State<_FeedItem> createState() => _FeedItemState();
}

class _FeedItemState extends State<_FeedItem> {
  bool _liked = false;
  int _likes = 1200000;
  int _comments = 24500;
  int _diamonds = 8200;

  @override
  Widget build(BuildContext context) {
    final username = widget.creator['username'] ?? '@creador';
    final avatar = widget.creator['profilePicture'] ?? '';
    final rating = (widget.creator['rating'] as num?)?.toDouble() ?? 0.0;
    final subscribers = (widget.creator['subscribersCount'] as num?)?.toInt() ?? 0;
    final previewPhotos = widget.creator['previewPhotos'] as List? ?? [];
    final isLive = widget.creator['isLive'] == true;
    final isFollowing = widget.creator['isSubscribed'] == true;

    // Get the first preview photo or use a placeholder
    final thumbnail = previewPhotos.isNotEmpty 
        ? (previewPhotos.first['thumbnail'] ?? previewPhotos.first['url'] ?? '')
        : '';

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: thumbnail,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: LuxorColors.surface),
            errorWidget: (_, __, ___) => Container(
              color: LuxorColors.surface,
              child: const Icon(Icons.person, size: 80, color: LuxorColors.textSecondary),
            ),
          ),

          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.4, 1.0],
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
          ),

          // Grid/Videoteca button
          if (thumbnail.isNotEmpty)
            Center(
              child: GestureDetector(
                onTap: () => context.go('/creador/$username/grid'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.grid_view, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('VER EN', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
                      Text('GRILLA / VIDEOTECA', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    ]),
                  ]),
                ),
              ),
            ),

          // Right action bar
          Positioned(
            right: 12,
            bottom: 120,
            child: Column(children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: avatar.isNotEmpty ? CachedNetworkImageProvider(avatar) : null,
                    backgroundColor: LuxorColors.surface,
                    child: avatar.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                  ),
                  if (isLive)
                    Positioned(
                      bottom: -10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: LuxorColors.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              _ActionButton(
                icon: _liked ? Icons.favorite : Icons.favorite_border,
                color: _liked ? LuxorColors.error : Colors.white,
                label: formatCount(_likes + (_liked ? 1 : 0)),
                onTap: () => setState(() => _liked = !_liked),
              ),
              const SizedBox(height: 16),
              _ActionButton(
                icon: Icons.chat_bubble_outline,
                label: formatCount(_comments),
                onTap: () => context.go('/chat/$username'),
              ),
              const SizedBox(height: 16),
              _ActionButton(
                icon: Icons.diamond_outlined,
                color: LuxorColors.diamond,
                label: formatCount(_diamonds),
                onTap: () {},
              ),
              const SizedBox(height: 16),
              _ActionButton(
                icon: Icons.reply,
                label: 'Share',
                onTap: () {},
              ),
            ]),
          ),

          // Bottom info
          Positioned(
            left: 16,
            right: 80,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('@$username', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () async {
                      try {
                        if (isFollowing) {
                          await ApiClient.dio.delete('/interactions/follow', data: {'influencerId': widget.creator['influencerId']});
                        } else {
                          await ApiClient.dio.post('/interactions/follow', data: {'influencerId': widget.creator['influencerId']});
                        }
                      } catch (_) {}
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: isFollowing ? null : const LinearGradient(colors: [LuxorColors.primary, LuxorColors.secondary]),
                        color: isFollowing ? Colors.white24 : null,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isFollowing ? 'Siguiendo' : 'Seguir',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.star, color: LuxorColors.secondary, size: 14),
                  const SizedBox(width: 4),
                  Text(rating.toStringAsFixed(1), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(width: 12),
                  Text('${formatCount(subscribers)} seguidores', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.music_note, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  const Text('Sonido original', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    this.color = Colors.white,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
