import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/utils/api_client.dart';
import '../widgets/content_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _contents = [];
  bool _isLoading = true;
  String? _error;
  String _category = 'all';

  Future<void> _loadFeed() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final response = await ApiClient.dio.get('/home/feed', queryParameters: {'category': _category});
      if (response.data['success'] == true) {
        setState(() => _contents = response.data['data']['contents'] ?? []);
      } else {
        setState(() => _error = response.data['message']);
      }
    } on DioException catch (e) {
      setState(() => _error = e.response?.data['message'] ?? 'Error de conexión');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LUXOR', style: TextStyle(fontWeight: FontWeight.bold, color: LuxorColors.primary)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: LuxorSpacing.md),
            child: Row(
              children: [
                _CategoryChip(label: 'Todo', isSelected: _category == 'all', onTap: () { setState(() => _category = 'all'); _loadFeed(); }),
                _CategoryChip(label: 'Música', isSelected: _category == 'music', onTap: () { setState(() => _category = 'music'); _loadFeed(); }),
                _CategoryChip(label: 'Conciertos', isSelected: _category == 'concert', onTap: () { setState(() => _category = 'concert'); _loadFeed(); }),
                _CategoryChip(label: 'Sensual', isSelected: _category == 'sensual', onTap: () { setState(() => _category = 'sensual'); _loadFeed(); }),
              ],
            ),
          ),
          const SizedBox(height: LuxorSpacing.md),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(_error!, style: const TextStyle(color: LuxorColors.error)), const SizedBox(height: 16), ElevatedButton(onPressed: _loadFeed, child: const Text('Reintentar'))]))
                    : RefreshIndicator(
                        onRefresh: _loadFeed,
                        child: _contents.isEmpty
                            ? const Center(child: Text('No hay contenido', style: TextStyle(color: LuxorColors.textSecondary)))
                            : ListView.builder(
                                itemCount: _contents.length,
                                itemBuilder: (context, index) => ContentCard(content: _contents[index]),
                              )),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: LuxorColors.primary,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(color: isSelected ? Colors.white : LuxorColors.textSecondary),
      ),
    );
  }
}