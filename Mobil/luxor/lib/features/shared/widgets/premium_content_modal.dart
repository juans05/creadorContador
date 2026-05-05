import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class PremiumContentModal extends StatelessWidget {
  final double subscriptionPrice;
  final double clipPrice;
  final VoidCallback? onSubscribe;
  final VoidCallback? onBuyClip;
  final VoidCallback? onClose;

  const PremiumContentModal({
    super.key,
    this.subscriptionPrice = 9.99,
    this.clipPrice = 4.99,
    this.onSubscribe,
    this.onBuyClip,
    this.onClose,
  });

  static Future<String?> show(
    BuildContext context, {
    double subscriptionPrice = 9.99,
    double clipPrice = 4.99,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PremiumContentModal(
        subscriptionPrice: subscriptionPrice,
        clipPrice: clipPrice,
        onSubscribe: () => Navigator.pop(context, 'subscribe'),
        onBuyClip: () => Navigator.pop(context, 'buy'),
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: LuxorColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: LuxorColors.surfaceElevated.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: LuxorColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.close, color: LuxorColors.textSecondary, size: 18),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Diamond icon
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              gradient: LuxorColors.gradientPrimary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.diamond, color: Colors.white, size: 28),
          ),

          const SizedBox(height: 20),

          const Text(
            'Contenido Premium',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Desbloquea este clip o suscríbete\npara acceso total.',
            textAlign: TextAlign.center,
            style: TextStyle(color: LuxorColors.textSecondary, fontSize: 14, height: 1.5),
          ),

          const SizedBox(height: 28),

          // Subscribe button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LuxorColors.gradientPrimary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ElevatedButton.icon(
                onPressed: onSubscribe,
                icon: const Icon(Icons.star, size: 18),
                label: Text(
                  'Suscribirse (\$${subscriptionPrice.toStringAsFixed(2)}/mes)',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Buy clip button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: onBuyClip,
              icon: const Icon(Icons.shopping_bag_outlined, size: 18, color: Colors.white),
              label: Text(
                'Comprar Clip  \$${clipPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.white),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: LuxorColors.surfaceElevated),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                backgroundColor: LuxorColors.surfaceElevated.withValues(alpha: 0.3),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Close text
          GestureDetector(
            onTap: onClose,
            child: const Text(
              'Cerrar',
              style: TextStyle(color: LuxorColors.textMuted, fontSize: 14),
            ),
          ),

          const SizedBox(height: 12),

          // Security info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_user, color: LuxorColors.success, size: 14),
              const SizedBox(width: 6),
              const Text(
                'PAGOS SEGUROS CON PIX & MERCADO PAGO',
                style: TextStyle(color: LuxorColors.textMuted, fontSize: 9, letterSpacing: 0.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
