import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../features/shared/widgets/luxor_widgets.dart';

class CheckoutScreen extends StatefulWidget {
  final String creatorUsername;
  final String creatorAvatar;
  final double price;

  const CheckoutScreen({
    super.key,
    required this.creatorUsername,
    this.creatorAvatar = '',
    this.price = 9.99,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = 'card';
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Finalizar Compra', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // Subscription info
              Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LuxorColors.gradientPrimary,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: LuxorColors.background,
                      backgroundImage: widget.creatorAvatar.isNotEmpty
                          ? CachedNetworkImageProvider(widget.creatorAvatar)
                          : null,
                      child: widget.creatorAvatar.isEmpty
                          ? const Icon(Icons.person, color: Colors.white, size: 24)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Suscripción Mensual a', style: TextStyle(color: LuxorColors.textSecondary, fontSize: 12)),
                        Text(
                          '@${widget.creatorUsername}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${widget.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      const Text('USD / MES', style: TextStyle(color: LuxorColors.textMuted, fontSize: 9, letterSpacing: 0.5)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),
              const Text('MÉTODO DE PAGO', style: TextStyle(color: LuxorColors.textMuted, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),

              // Payment methods
              _PaymentMethodTile(
                icon: Icons.payment,
                title: 'Mercado Pago',
                subtitle: 'Paga con tu cuenta o tarjeta',
                selected: _paymentMethod == 'mercadopago',
                onTap: () => setState(() => _paymentMethod = 'mercadopago'),
              ),
              const SizedBox(height: 10),
              _PaymentMethodTile(
                icon: Icons.flash_on,
                title: 'Pix',
                subtitle: 'Aprobación instantánea',
                badge: 'RECOMENDADO',
                selected: _paymentMethod == 'pix',
                onTap: () => setState(() => _paymentMethod = 'pix'),
              ),
              const SizedBox(height: 10),
              _PaymentMethodTile(
                icon: Icons.credit_card,
                title: 'Tarjetas de Crédito / Débito',
                subtitle: 'Visa, Mastercard, Amex',
                selected: _paymentMethod == 'card',
                onTap: () => setState(() => _paymentMethod = 'card'),
              ),

              // Card form
              if (_paymentMethod == 'card') ...[
                const SizedBox(height: 20),
                LuxorTextField(
                  controller: _cardNumberController,
                  hintText: '0000 0000 0000 0000',
                  labelText: 'NÚMERO DE TARJETA',
                  keyboardType: TextInputType.number,
                  suffixIcon: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.credit_card, color: LuxorColors.textMuted, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: LuxorTextField(
                        controller: _expiryController,
                        hintText: 'MM/YY',
                        labelText: 'EXPIRACIÓN',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: LuxorTextField(
                        controller: _cvvController,
                        hintText: '•••',
                        labelText: 'CVC / CVV',
                        obscureText: true,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32),

              // Pay button
              LuxorGradientButton(
                label: 'Finalizar Pago',
                icon: Icons.lock,
                isLoading: _isLoading,
                onPressed: () {
                  setState(() => _isLoading = true);
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() => _isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pago procesado exitosamente')),
                      );
                      Navigator.pop(context, true);
                    }
                  });
                },
              ),

              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(color: LuxorColors.textMuted, fontSize: 11, height: 1.5),
                  children: [
                    TextSpan(text: 'Al hacer clic en "Finalizar Pago", aceptas nuestros\n'),
                    TextSpan(text: 'Términos de Servicio', style: TextStyle(decoration: TextDecoration.underline, color: LuxorColors.textSecondary)),
                    TextSpan(text: ' y la renovación automática mensual.'),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Security badge
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: LuxorColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_user, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'ENCRIPTACIÓN SSL DE 256 BITS',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1),
                    ),
                  ],
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

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? LuxorColors.primary.withValues(alpha: 0.06) : LuxorColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? LuxorColors.primary.withValues(alpha: 0.4) : LuxorColors.surfaceElevated.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? LuxorColors.primary : Colors.transparent,
                border: Border.all(color: selected ? LuxorColors.primary : LuxorColors.textMuted, width: 1.5),
              ),
              child: selected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
            ),
            const SizedBox(width: 14),
            Icon(icon, color: selected ? LuxorColors.primary : LuxorColors.textSecondary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: LuxorColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(badge!, style: const TextStyle(color: LuxorColors.success, fontSize: 8, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: LuxorColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
