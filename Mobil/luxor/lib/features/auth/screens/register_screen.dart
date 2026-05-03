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
  String? _error;

  DateTime? _dateOfBirth;

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
        'dateOfBirth': _dateOfBirth?.toIso8601String().split('T')[0] ?? '2000-01-01',
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
        title: const Text('Regístrate'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(LuxorSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LuxorTextField(
                controller: _nameController,
                hintText: 'Nombre completo',
                prefixIcon: const Icon(Icons.person),
              ),
              const SizedBox(height: LuxorSpacing.md),
              LuxorTextField(
                controller: _emailController,
                hintText: 'Email',
                prefixIcon: const Icon(Icons.email),
              ),
              const SizedBox(height: LuxorSpacing.md),
              LuxorTextField(
                controller: _phoneController,
                hintText: 'Teléfono (9 dígitos)',
                prefixIcon: const Icon(Icons.phone),
              ),
              const SizedBox(height: LuxorSpacing.md),
              LuxorTextField(
                controller: _passwordController,
                hintText: 'Contraseña',
                obscureText: true,
                prefixIcon: const Icon(Icons.lock),
              ),
              const SizedBox(height: LuxorSpacing.md),
              LuxorTextField(
                controller: _confirmPasswordController,
                hintText: 'Confirmar contraseña',
                obscureText: true,
                prefixIcon: const Icon(Icons.lock),
              ),
              if (_error != null) ...[
                const SizedBox(height: LuxorSpacing.md),
                Text(_error!, style: const TextStyle(color: LuxorColors.error)),
              ],
              const SizedBox(height: LuxorSpacing.lg),
              LuxorButton(label: 'Registrarse', isLoading: _isLoading, onPressed: _register),
              const SizedBox(height: LuxorSpacing.md),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('¿Ya tienes cuenta? Inicia sesión', style: TextStyle(color: LuxorColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}