import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/utils/api_client.dart';
import '../../../features/shared/widgets/luxor_widgets.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _balance = 0;
  int _totalSpent = 0;
  bool _isLoading = true;

  Future<void> _loadBalance() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.dio.get('/diamonds/balance');
      if (response.data['success'] == true) {
        setState(() {
          _balance = response.data['data']['balance'] ?? 0;
          _totalSpent = response.data['data']['total_spent'] ?? 0;
        });
      }
    } catch (e) {
      // error
    } finally {
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
      appBar: AppBar(title: const Text('Mi Billetera')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(LuxorSpacing.lg),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(LuxorSpacing.xl),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [LuxorColors.primary, LuxorColors.tertiary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(LuxorRadius.lg),
                    ),
                    child: Column(children: [
                      const Text('Diamantes', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.diamond, color: Colors.white, size: 32), const SizedBox(width: 8), Text('$_balance', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold))]),
                    ]),
                  ),
                  const SizedBox(height: LuxorSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(LuxorSpacing.md),
                    decoration: BoxDecoration(color: LuxorColors.surface, borderRadius: BorderRadius.circular(LuxorRadius.md)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      Column(children: [const Text('Gastados', style: TextStyle(color: LuxorColors.textSecondary, fontSize: 12)), Text('$_totalSpent', style: const TextStyle(fontWeight: FontWeight.bold))]),
                      Column(children: [const Text('Recibidos', style: TextStyle(color: LuxorColors.textSecondary, fontSize: 12)), Text('0', style: const TextStyle(fontWeight: FontWeight.bold))]),
                    ]),
                  ),
                  const Spacer(),
                  LuxorButton(label: 'Comprar Diamantes', onPressed: () => context.go('/wallet/buy')),
                ],
              ),
            ),
    );
  }
}