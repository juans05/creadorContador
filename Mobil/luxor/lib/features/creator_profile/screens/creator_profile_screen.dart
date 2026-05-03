import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/utils/api_client.dart';

class CreatorProfileScreen extends StatefulWidget {
  final String username;
  const CreatorProfileScreen({super.key, required this.username});

  @override
  State<CreatorProfileScreen> createState() => _CreatorProfileScreenState();
}

class _CreatorProfileScreenState extends State<CreatorProfileScreen> {
  Map<String, dynamic>? _creator;
  bool _isLoading = true;

  Future<void> _load() async {
    try {
      final resp = await ApiClient.dio.get('/influencers/${widget.username}');
      if (resp.data['success'] == true) setState(() => _creator = resp.data['data']);
    } catch (e) {} finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() { super.initState(); _load(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _creator == null ? const Center(child: Text('No encontrado')) : CustomScrollView(
        slivers: [
          SliverAppBar(expandedHeight: 200, pinned: true, flexibleSpace: FlexibleSpaceBar(title: Text(_creator!['username'] ?? ''))),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(LuxorSpacing.lg), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_creator!['name'] ?? '', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(_creator!['bio'] ?? '', style: const TextStyle(color: LuxorColors.textSecondary)),
            const SizedBox(height: 16),
            Row(children: [
              _Stat(label: 'Suscriptores', value: _creator!['suscriptores_count'] ?? 0),
              const SizedBox(width: 24),
              _Stat(label: 'Contenido', value: _creator!['content_count'] ?? 0),
            ]),
          ]))),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label; final int value;
  const _Stat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(children: [Text('$value', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(color: LuxorColors.textSecondary, fontSize: 12))]);
}