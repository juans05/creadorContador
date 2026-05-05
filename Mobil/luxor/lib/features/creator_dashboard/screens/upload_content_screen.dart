import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/utils/api_client.dart';
import '../../../core/utils/format_utils.dart';
import '../../../features/shared/widgets/luxor_widgets.dart';
import 'camera_screen.dart';

class UploadContentScreen extends StatefulWidget {
  const UploadContentScreen({super.key});

  @override
  State<UploadContentScreen> createState() => _UploadContentScreenState();
}

class _UploadContentScreenState extends State<UploadContentScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String _visibility = 'public';
  int _ppvPrice = 50;
  XFile? _selectedFile;
  bool _isVideo = false;
  bool _isNsfw = false;
  String? _error;
  final _hashtags = ['#LatamCreator', '#Música', '#Vlog', '#Exclusivo'];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: LuxorColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: LuxorColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: LuxorColors.primary),
                title: const Text('Grabar con cámara', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final path = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(builder: (_) => const CameraScreen()),
                  );
                  if (path != null && path.isNotEmpty) {
                    setState(() {
                      _selectedFile = XFile(path);
                      _isVideo = path.endsWith('.mp4') || path.endsWith('.mov') || path.endsWith('.webm');
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam_outlined, color: LuxorColors.textSecondary),
                title: const Text('Seleccionar video'),
                subtitle: const Text('MP4, MOV o HEVC (Max 2GB)', style: TextStyle(color: LuxorColors.textMuted, fontSize: 12)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final file = await _picker.pickVideo(source: ImageSource.gallery);
                  if (file != null) setState(() { _selectedFile = file; _isVideo = true; });
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_outlined, color: LuxorColors.textSecondary),
                title: const Text('Seleccionar imagen'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final file = await _picker.pickImage(source: ImageSource.gallery);
                  if (file != null) setState(() { _selectedFile = file; _isVideo = false; });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _upload() async {
    if (_selectedFile == null) {
      setState(() => _error = 'Selecciona un video o imagen primero');
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      setState(() => _error = 'Ingresa un título');
      return;
    }

    setState(() { _isLoading = true; _error = null; });
    try {
      final formData = FormData.fromMap({
        'media': await MultipartFile.fromFile(
          _selectedFile!.path,
          filename: _selectedFile!.name,
        ),
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'visibility': _visibility,
        'ppv_price_diamonds': _ppvPrice,
      });

      final response = await ApiClient.dio.post(
        '/content/upload',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      if (response.data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contenido publicado exitosamente')),
          );
          context.go('/dashboard');
        }
      } else {
        setState(() => _error = response.data['message'] ?? 'Error al publicar');
      }
    } on DioException catch (e) {
      setState(() => _error = extractApiError(e.response?.data) ?? 'Error de conexión. Intenta nuevamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  ),
                  const Text('Create Content', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LuxorColors.gradientPrimary,
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 18),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Upload area
              GestureDetector(
                onTap: _isLoading ? null : _pickMedia,
                child: Container(
                  height: _selectedFile != null ? 220 : 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: LuxorColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedFile != null ? LuxorColors.primary.withValues(alpha: 0.5) : LuxorColors.surfaceElevated,
                      width: _selectedFile != null ? 1.5 : 1,
                    ),
                  ),
                  child: _selectedFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: LuxorColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.add, color: LuxorColors.primary, size: 28),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Arrastra y suelta o selecciona\narchivos',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: LuxorColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'MP4, MOV o HEVC (Max 2GB)',
                              style: TextStyle(color: LuxorColors.textMuted, fontSize: 12),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('VISTA PREVIA', style: TextStyle(color: LuxorColors.textMuted, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 12),
                            Container(
                              width: 120, height: 80,
                              decoration: BoxDecoration(
                                color: LuxorColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(_isVideo ? Icons.videocam : Icons.image, color: LuxorColors.primary, size: 32),
                                  Positioned(
                                    bottom: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: LuxorColors.primary.withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.photo_camera, color: Colors.white, size: 10),
                                          SizedBox(width: 4),
                                          Text('Cambiar', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                _selectedFile!.name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: LuxorColors.textSecondary, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              LuxorTextField(
                controller: _titleController,
                hintText: 'Escribe un título cautivador...',
                labelText: 'TÍTULO DEL VIDEO',
              ),
              const SizedBox(height: LuxorSpacing.md),

              // Description
              LuxorTextField(
                controller: _descController,
                hintText: 'Comparte los detalles de tu creación con la comunidad...',
                labelText: 'DESCRIPCIÓN',
                maxLines: 3,
              ),

              const SizedBox(height: 20),

              // Hashtags
              const Text('HASHTAGS', style: TextStyle(color: LuxorColors.textMuted, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _hashtags.map((tag) => LuxorTag(label: tag, selected: true)).toList(),
              ),

              const SizedBox(height: 24),

              // Visibility
              const Text('VISIBILIDAD Y MONETIZACIÓN', style: TextStyle(color: LuxorColors.textMuted, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              _VisibilityOption(
                icon: Icons.public,
                title: 'Público (Gratis)',
                subtitle: 'Visible para todos los usuarios',
                selected: _visibility == 'public',
                onTap: () => setState(() => _visibility = 'public'),
              ),
              const SizedBox(height: 8),
              _VisibilityOption(
                icon: Icons.star,
                title: 'Premium (Suscriptores)',
                subtitle: 'Solo para tus seguidores de pago',
                selected: _visibility == 'subscribers',
                onTap: () => setState(() => _visibility = 'subscribers'),
              ),
              const SizedBox(height: 8),
              _VisibilityOption(
                icon: Icons.lock,
                title: 'Exclusivo (PPV)',
                subtitle: 'Pago por evento individual',
                selected: _visibility == 'ppv',
                onTap: () => setState(() => _visibility = 'ppv'),
              ),

              if (_visibility == 'ppv') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.diamond, color: LuxorColors.diamond, size: 16),
                    const SizedBox(width: 8),
                    const Text('Precio en Diamantes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: LuxorColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: LuxorColors.surfaceElevated),
                      ),
                      child: SizedBox(
                        width: 50,
                        child: TextField(
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            filled: false,
                          ),
                          controller: TextEditingController(text: '$_ppvPrice'),
                          onChanged: (v) => _ppvPrice = int.tryParse(v) ?? 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // NSFW toggle
              _VisibilityOption(
                icon: Icons.eighteen_up_rating,
                title: 'Contenido para adultos (NSFW)',
                subtitle: 'Requiere verificación de edad',
                selected: _isNsfw,
                onTap: () => setState(() => _isNsfw = !_isNsfw),
                isToggle: true,
              ),

              if (_error != null) ...[
                const SizedBox(height: LuxorSpacing.md),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: LuxorColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_error!, style: const TextStyle(color: LuxorColors.error, fontSize: 13)),
                ),
              ],

              const SizedBox(height: 24),

              // Publish button
              LuxorGradientButton(
                label: 'Publicar Ahora',
                icon: Icons.rocket_launch,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _upload,
              ),

              const SizedBox(height: 8),
              Text(
                'Al publicar, aceptas nuestras Normas de la Comunidad y garantizas poseer los derechos de este contenido.',
                textAlign: TextAlign.center,
                style: TextStyle(color: LuxorColors.textMuted, fontSize: 10, height: 1.4),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _VisibilityOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final bool isToggle;

  const _VisibilityOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.isToggle = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? LuxorColors.primary.withValues(alpha: 0.08) : LuxorColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? LuxorColors.primary.withValues(alpha: 0.4) : LuxorColors.surfaceElevated.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? LuxorColors.primary : LuxorColors.textMuted, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: selected ? Colors.white : LuxorColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: LuxorColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
            if (isToggle)
              Switch(
                value: selected,
                onChanged: (_) => onTap(),
                activeColor: LuxorColors.primary,
              )
            else
              Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? LuxorColors.primary : Colors.transparent,
                  border: Border.all(color: selected ? LuxorColors.primary : LuxorColors.textMuted, width: 1.5),
                ),
                child: selected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
              ),
          ],
        ),
      ),
    );
  }
}
