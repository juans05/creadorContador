import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/utils/api_client.dart';
import '../../../features/shared/widgets/luxor_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      final response = await ApiClient.dio.post('/auth/register', data: {
        'email': _emailController.text,
        'password': _passwordController.text,
        'confirmPassword': _confirmPasswordController.text,
        'name': _nameController.text,
        'phone': _phoneController.text,
        'dateOfBirth': '2000-01-01',
        'ageConfirmed': true,
        'termsAccepted': true,
        'privacyAccepted': true,
      });
      if (response.data['success'] == true) {
        if (mounted) context.go('/login');
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
          onPressed: () => context.go('/login'),
        ),
        title: const Text('Crear Cuenta'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Únete a la\nRevolución',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1),
              ),
              const SizedBox(height: 8),
              const Text(
                'Transforma tu pasión en ingresos reales.',
                style: TextStyle(color: LuxorColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 28),

              LuxorTextField(
                controller: _nameController,
                hintText: 'Maria Garcia',
                labelText: 'Nombre Completo',
                prefixIcon: const Icon(Icons.person_outline, color: LuxorColors.textMuted, size: 20),
              ),
              const SizedBox(height: LuxorSpacing.md),
              LuxorTextField(
                controller: _emailController,
                hintText: 'nombre@latam.com',
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined, color: LuxorColors.textMuted, size: 20),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: LuxorSpacing.md),
              LuxorTextField(
                controller: _phoneController,
                hintText: '987 654 321',
                labelText: 'Teléfono',
                prefixIcon: const Icon(Icons.phone_outlined, color: LuxorColors.textMuted, size: 20),
                keyboardType: TextInputType.phone,
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
              const SizedBox(height: LuxorSpacing.md),
              LuxorTextField(
                controller: _confirmPasswordController,
                hintText: '••••••••',
                labelText: 'Confirmar Contraseña',
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline, color: LuxorColors.textMuted, size: 20),
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
                label: 'Crear Cuenta',
                isLoading: _isLoading,
                onPressed: _register,
              ),
              const SizedBox(height: LuxorSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿Ya tienes cuenta? ', style: TextStyle(color: LuxorColors.textSecondary, fontSize: 13)),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: const Text(
                      'Inicia Sesión',
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
