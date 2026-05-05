import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/utils/api_client.dart';
import '../../../features/shared/widgets/luxor_widgets.dart';

class CreatorRegisterScreen extends StatefulWidget {
  const CreatorRegisterScreen({super.key});

  @override
  State<CreatorRegisterScreen> createState() => _CreatorRegisterScreenState();
}

class _CreatorRegisterScreenState extends State<CreatorRegisterScreen> {
  final _artistNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _yapeController = TextEditingController();
  final _plinController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;
  String _selectedCategory = 'Música';
  final _categories = ['Música', 'Lifestyle', 'Gaming', 'Educación'];

  Future<void> _registerCreator() async {
    if (_artistNameController.text.trim().isEmpty || _usernameController.text.trim().isEmpty) {
      setState(() => _error = 'Nombre artístico y username son requeridos');
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      final response = await ApiClient.dio.post('/auth/register-creator', data: {
        'artistName': _artistNameController.text.trim(),
        'username': _usernameController.text.trim(),
        'category': _selectedCategory.toLowerCase(),
        'bio': _bioController.text.trim(),
        'yapeNumber': _yapeController.text.trim(),
        'plinNumber': _plinController.text.trim(),
        'password': _passwordController.text,
      });
      if (response.data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro exitoso. Inicia sesión.')),
          );
          context.go('/login');
        }
      } else {
        setState(() => _error = response.data['message'] ?? 'Error al registrar');
      }
    } on DioException catch (e) {
      setState(() => _error = e.response?.data['message'] ?? 'Error de conexión');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'CREATOR PORTAL',
          style: TextStyle(
            color: LuxorColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Únete como\nCreadora',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1),
              ),
              const SizedBox(height: 10),
              const Text(
                'Empieza a monetizar tu contenido en LATAM',
                style: TextStyle(color: LuxorColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 28),

              LuxorTextField(
                controller: _artistNameController,
                hintText: 'Tu nombre público',
                labelText: 'Nombre Artístico',
                prefixIcon: const Icon(Icons.star_outline, color: LuxorColors.textMuted, size: 20),
              ),
              const SizedBox(height: LuxorSpacing.md),
              LuxorTextField(
                controller: _usernameController,
                hintText: 'username',
                labelText: 'Username',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 12, right: 0),
                  child: Text('@', style: TextStyle(color: LuxorColors.textMuted, fontSize: 18, fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(height: LuxorSpacing.md),

              // Category
              const Text(
                'Categoría',
                style: TextStyle(color: LuxorColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final selected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: selected ? LuxorColors.gradientPrimary : null,
                        color: selected ? null : LuxorColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: selected ? null : Border.all(color: LuxorColors.surfaceElevated),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: selected ? Colors.white : LuxorColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: LuxorSpacing.md),
              LuxorTextField(
                controller: _bioController,
                hintText: 'Cuéntanos sobre tu arte y lo que ofreces a tu comunidad...',
                labelText: 'Biografía',
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              // Payment section
              Container(
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
                        Icon(Icons.flash_on, color: LuxorColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Pagos Instantáneos (Perú)',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _PaymentField(
                      label: 'NÚMERO YAPE',
                      controller: _yapeController,
                      color: const Color(0xFF6B21A8),
                    ),
                    const SizedBox(height: 12),
                    _PaymentField(
                      label: 'NÚMERO PLIN',
                      controller: _plinController,
                      color: const Color(0xFF059669),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: LuxorSpacing.md),
              LuxorTextField(
                controller: _passwordController,
                hintText: '••••••••',
                labelText: 'Contraseña',
                obscureText: _obscurePassword,
                prefixIcon: const Icon(Icons.lock_outline, color: LuxorColors.textMuted, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: LuxorColors.textMuted, size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
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
              LuxorGradientButton(
                label: 'Unirme como Creadora',
                icon: Icons.rocket_launch,
                isLoading: _isLoading,
                onPressed: _registerCreator,
              ),

              const SizedBox(height: 24),

              // Community badge
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: LuxorColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.favorite, color: LuxorColors.primary, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'Comunidad Primero',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Creemos en el crecimiento orgánico. Al unirte, aceptas nuestras pautas de comunidad enfocadas en el respeto, la seguridad y la autenticidad local.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: LuxorColors.textSecondary, fontSize: 12, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿Ya tienes cuenta? ', style: TextStyle(color: LuxorColors.textSecondary, fontSize: 13)),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: const Text(
                      'Inicia sesión',
                      style: TextStyle(color: LuxorColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color color;

  const _PaymentField({required this.label, required this.controller, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.phone_android, color: color, size: 18),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1)),
              const SizedBox(height: 2),
              SizedBox(
                width: 160,
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: '987 654 321',
                    hintStyle: TextStyle(color: LuxorColors.textMuted, fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    filled: false,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
