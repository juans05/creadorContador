import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/utils/api_client.dart';
import '../../../features/shared/widgets/luxor_widgets.dart';

class UploadContentScreen extends StatefulWidget {
  const UploadContentScreen({super.key});

  @override
  State<UploadContentScreen> createState() => _UploadContentScreenState();
}

class _UploadContentScreenState extends State<UploadContentScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;
  String _visibility = 'public';
  int _ppvPrice = 0;

  Future<void> _upload() async {
    setState(() => _isLoading = true);
    try {
      final formData = FormData.fromMap({
        'title': _titleController.text,
        'description': _descController.text,
        'visibility': _visibility,
        'ppv_price_diamonds': _ppvPrice,
      });
      final response = await ApiClient.dio.post('/content/upload', data: formData);
      if (response.data['success'] == true) {
        if (mounted) context.go('/dashboard');
      }
    } catch (e) {} finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subir Contenido')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(LuxorSpacing.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            height: 200,
            decoration: BoxDecoration(color: LuxorColors.surface, borderRadius: BorderRadius.circular(LuxorRadius.md), border: Border.all(color: LuxorColors.surfaceElevated)),
            child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add_photo_alternate, size: 48, color: LuxorColors.textSecondary), SizedBox(height: 8), Text('Toca para seleccionar', style: TextStyle(color: LuxorColors.textSecondary))])),
          ),
          const SizedBox(height: LuxorSpacing.lg),
          LuxorTextField(controller: _titleController, hintText: 'Título del contenido'),
          const SizedBox(height: LuxorSpacing.md),
          LuxorTextField(controller: _descController, hintText: 'Descripción (opcional)'),
          const SizedBox(height: LuxorSpacing.lg),
          const Text('Visibilidad', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(children: [
            _VisibilityChip(label: 'Público', value: 'public', selected: _visibility, onTap: (v) => setState(() => _visibility = v)),
            const SizedBox(width: 8),
            _VisibilityChip(label: 'Suscriptores', value: 'subscribers', selected: _visibility, onTap: (v) => setState(() => _visibility = v)),
            const SizedBox(width: 8),
            _VisibilityChip(label: 'PPV', value: 'ppv', selected: _visibility, onTap: (v) => setState(() => _visibility = v)),
          ]),
          if (_visibility == 'ppv') ...[
            const SizedBox(height: LuxorSpacing.md),
            TextField(
              decoration: const InputDecoration(labelText: 'Precio en diamantes', prefixIcon: Icon(Icons.diamond)),
              keyboardType: TextInputType.number,
              onChanged: (v) => _ppvPrice = int.tryParse(v) ?? 0,
            ),
          ],
          const SizedBox(height: LuxorSpacing.xl),
          LuxorButton(label: 'Publicar', isLoading: _isLoading, onPressed: _upload),
        ]),
      ),
    );
  }
}

class _VisibilityChip extends StatelessWidget {
  final String label, value, selected;
  final Function(String) onTap;
  const _VisibilityChip({required this.label, required this.value, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: selected == value ? LuxorColors.primary : LuxorColors.surface, borderRadius: BorderRadius.circular(8)),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: selected == value ? Colors.white : LuxorColors.textSecondary, fontSize: 12)),
      ),
    ),
  );
}