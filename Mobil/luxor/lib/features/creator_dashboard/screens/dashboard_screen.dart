import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/utils/api_client.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  Future<void> _load() async {
    try {
      final resp = await ApiClient.dio.get('/influencers/dashboard/stats');
      if (resp.data['success'] == true) setState(() => _stats = resp.data['data']);
    } catch (_) {} finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() { super.initState(); _load(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'), actions: [IconButton(icon: const Icon(Icons.settings), onPressed: () {})]),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(LuxorSpacing.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            _StatCard(icon: Icons.attach_money, label: 'Ganancias', value: 'S/ ${_stats?['total_earnings'] ?? 0}'),
            const SizedBox(width: 16),
            _StatCard(icon: Icons.people, label: 'Suscriptores', value: '${_stats?['suscriptores_count'] ?? 0}'),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            _StatCard(icon: Icons.visibility, label: 'Vistas', value: '${_stats?['views_count'] ?? 0}'),
            const SizedBox(width: 16),
            _StatCard(icon: Icons.photo_library, label: 'Contenido', value: '${_stats?['content_count'] ?? 0}'),
          ]),
          const SizedBox(height: LuxorSpacing.xl),
          ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text('Subir Contenido'), onPressed: () => context.go('/dashboard/upload')),
        ]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon; final String label; final String value;
  const _StatCard({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(LuxorSpacing.md),
      decoration: BoxDecoration(color: LuxorColors.surface, borderRadius: BorderRadius.circular(LuxorRadius.md)),
      child: Column(children: [Icon(icon, color: LuxorColors.primary, size: 28), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(color: LuxorColors.textSecondary, fontSize: 12))]),
    ),
  );
}