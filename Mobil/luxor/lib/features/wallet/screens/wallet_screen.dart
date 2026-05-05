import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/api_client.dart';
import '../../../core/utils/format_utils.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _balance = 0;
  int _totalSpent = 0;
  int _totalEarned = 0;
  bool _isLoading = true;

  Future<void> _loadBalance() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.dio.get('/diamonds/balance');
      if (response.data['success'] == true) {
        final data = response.data['data'];
        setState(() {
          _balance = (data['balance'] as num?)?.toInt() ?? 0;
          _totalSpent = (data['totalSpent'] as num?)?.toInt() ?? 0;
          _totalEarned = (data['totalEarned'] as num?)?.toInt() ?? 0;
        });
      }
    } catch (e) {} finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

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
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LuxorColors.gradientPrimary,
                          ),
                          child: const Icon(Icons.diamond, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        const Text('Wallet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Balance card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LuxorColors.gradientCard,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Text('SALDO DISPONIBLE', style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.diamond, color: Colors.white, size: 28),
                              const SizedBox(width: 8),
                              Text(
                                formatCount(_balance),
                                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\u2248 \$${(_balance * 0.01).toStringAsFixed(2)} USD',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_circle_outline, color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text('Cargar Diamantes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Stats grid
                    Row(
                      children: [
                        _StatCard(label: 'TOTAL GASTADO', value: '$_totalSpent', icon: Icons.shopping_bag, iconColor: LuxorColors.error),
                        const SizedBox(width: 10),
                        _StatCard(label: 'TOTAL GANADO', value: '$_totalEarned', icon: Icons.diamond, iconColor: LuxorColors.diamond),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _StatCard(label: 'COMPRAR', value: '+', icon: Icons.add_circle, iconColor: LuxorColors.primary),
                        const SizedBox(width: 10),
                        _StatCard(label: 'CONVERTIR', value: '→', icon: Icons.currency_exchange, iconColor: LuxorColors.secondary),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Performance chart placeholder
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
                          const Row(
                            children: [
                              Text('Ingresos Mensuales', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              Spacer(),
                              Icon(Icons.more_vert, color: LuxorColors.textMuted, size: 20),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Chart placeholder
                          SizedBox(
                            height: 120,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _ChartBar(height: 40, label: 'LUN'),
                                _ChartBar(height: 55, label: 'MAR'),
                                _ChartBar(height: 45, label: 'MIE'),
                                _ChartBar(height: 70, label: 'JUE'),
                                _ChartBar(height: 90, label: 'VIE', highlighted: true),
                                _ChartBar(height: 60, label: 'SAB'),
                                _ChartBar(height: 50, label: 'DOM'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Withdrawal methods
                    const Text('Métodos de Retiro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        _WithdrawMethod(icon: Icons.flash_on, label: 'Pix', color: const Color(0xFF00B4D8)),
                        const SizedBox(width: 12),
                        _WithdrawMethod(icon: Icons.payment, label: 'Mercado\nPago', color: const Color(0xFF00B4FF)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Transactions
                    Row(
                      children: [
                        const Text('Transacciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {},
                          child: const Text('Ver Todo', style: TextStyle(color: LuxorColors.primary, fontSize: 13, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _TransactionTile(icon: Icons.diamond, iconColor: LuxorColors.diamond, title: 'Tip de @ale_music', subtitle: 'Hace 2 horas', amount: '+50', amountColor: LuxorColors.success, status: 'Completado'),
                    _TransactionTile(icon: Icons.account_balance, iconColor: LuxorColors.secondary, title: 'Retiro a Pix', subtitle: 'Ayer, 14:20', amount: '-2,500', amountColor: LuxorColors.error, status: 'Pendiente'),
                    _TransactionTile(icon: Icons.star, iconColor: LuxorColors.primary, title: 'Suscripción Premium', subtitle: '28 Ago, 2023', amount: '+250', amountColor: LuxorColors.success, status: 'Completado'),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatCard({required this.label, required this.value, required this.icon, required this.iconColor});

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
            Text(label, style: const TextStyle(color: LuxorColors.textMuted, fontSize: 9, letterSpacing: 0.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(icon, color: iconColor, size: 16),
                const SizedBox(width: 6),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  final double height;
  final String label;
  final bool highlighted;

  const _ChartBar({required this.height, required this.label, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: height,
          decoration: BoxDecoration(
            gradient: highlighted ? LuxorColors.gradientPrimaryVertical : null,
            color: highlighted ? null : LuxorColors.primary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: LuxorColors.textMuted, fontSize: 9, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _WithdrawMethod extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _WithdrawMethod({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: LuxorColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: LuxorColors.surfaceElevated.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String amount;
  final Color amountColor;
  final String status;

  const _TransactionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: LuxorColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: TextStyle(color: amountColor, fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 2),
              Text(status, style: const TextStyle(color: LuxorColors.textMuted, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
