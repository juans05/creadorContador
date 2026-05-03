import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/utils/api_client.dart';
import '../../../features/shared/widgets/luxor_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _login() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final response = await ApiClient.dio.post('/auth/login', data: {
        'email': _emailController.text,
        'password': _passwordController.text,
      });
      if (response.data['success'] == true) {
        await ApiClient.setTokens(
          response.data['data']['accessToken'],
          response.data['data']['refreshToken'],
        );
        if (mounted) context.go('/home');
      } else {
        setState(() => _error = response.data['message'] ?? 'Error al iniciar sesion');
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map) ? data['message']?.toString() : null;
      setState(() => _error = msg ?? 'Error de conexión. Verifica tu red.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LuxorSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.diamond, size: 64, color: LuxorColors.primary),
              const SizedBox(height: LuxorSpacing.md),
              Text('LUXOR', textAlign: TextAlign.center, style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: LuxorSpacing.xxl),
              LuxorTextField(
                controller: _emailController,
                hintText: 'Email',
                prefixIcon: const Icon(Icons.email, color: LuxorColors.textSecondary),
              ),
              const SizedBox(height: LuxorSpacing.md),
              LuxorTextField(
                controller: _passwordController,
                hintText: 'Contrasena',
                obscureText: true,
                prefixIcon: const Icon(Icons.lock, color: LuxorColors.textSecondary),
              ),
              if (_error != null) ...[
                const SizedBox(height: LuxorSpacing.md),
                Text(_error!, style: const TextStyle(color: LuxorColors.error, fontSize: 14)),
              ],
              const SizedBox(height: LuxorSpacing.lg),
              LuxorButton(label: 'Iniciar Sesion', isLoading: _isLoading, onPressed: _login),
              const SizedBox(height: LuxorSpacing.md),
              TextButton(
                onPressed: () => context.go('/register'),
                child: const Text('No tienes cuenta? Registrate', style: TextStyle(color: LuxorColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}