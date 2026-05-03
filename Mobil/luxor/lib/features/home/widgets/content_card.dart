import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../features/shared/widgets/luxor_widgets.dart';

class ContentCard extends StatelessWidget {
  final Map<String, dynamic> content;
  const ContentCard({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final isLocked = content['ppv_price_diamonds'] != null && content['ppv_price_diamonds'] > 0;
    final isUnlocked = content['has_access'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: LuxorSpacing.md),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 9 / 16,
            child: CachedNetworkImage(
              imageUrl: content['thumbnail_url'] ?? '',
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: LuxorColors.surface),
              errorWidget: (_, __, ___) => Container(color: LuxorColors.surface, child: const Icon(Icons.image, color: LuxorColors.textSecondary)),
            ),
          ),
          if (isLocked && !isUnlocked)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(LuxorSpacing.md),
                  decoration: BoxDecoration(color: LuxorColors.surface, borderRadius: BorderRadius.circular(LuxorRadius.md)),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.lock, color: LuxorColors.primary, size: 32),
                    const SizedBox(height: 8),
                    DiamondChip(amount: content['ppv_price_diamonds'] ?? 0),
                    const SizedBox(height: 8),
                    const Text('Desbloquear', style: TextStyle(color: LuxorColors.primary, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(LuxorSpacing.sm),
              decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black87, Colors.transparent])),
              child: Row(children: [
                CircleAvatar(radius: 16, backgroundImage: CachedNetworkImageProvider(content['creator_avatar'] ?? '')),
                const SizedBox(width: 8),
                Expanded(child: Text(content['creator_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600))),
                if (content['likes_count'] != null) ...[const Icon(Icons.favorite, size: 16, color: LuxorColors.textSecondary), const SizedBox(width: 4), Text('${content['likes_count']}', style: const TextStyle(fontSize: 12))],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}