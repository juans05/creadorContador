import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/utils/api_client.dart';
import '../../../core/utils/format_utils.dart';
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
  bool _obscurePassword = true;
  String? _error;
  String _selectedRole = 'fan'; // 'fan' or 'creator'

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
        setState(() => _error = response.data['message'] ?? 'Error al iniciar sesión');
      }
    } on DioException catch (e) {
      setState(() => _error = extractApiError(e.response?.data) ?? 'Error de conexión. Verifica tu red.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Logo
                  Center(
                    child: Text(
                      'Plataforma LATAM',
                      style: TextStyle(
                        color: LuxorColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  const Text(
                    'Únete a la\nRevolución',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Siente el ritmo de la economía creativa en LATAM. Elige cómo quieres ser parte de nuestra comunidad.',
                    style: TextStyle(color: LuxorColors.textSecondary, fontSize: 14, height: 1.5),
                  ),

                  const SizedBox(height: 32),

                  // Role selection cards
                  _RoleCard(
                    title: 'Soy Fan',
                    subtitle: 'Descubre contenido exclusivo, apoya a tus creadores favoritos y accede a una comunidad vibrante.',
                    label: 'EXPERIENCIA PREMIUM',
                    selected: _selectedRole == 'fan',
                    onTap: () => setState(() => _selectedRole = 'fan'),
                  ),
                  const SizedBox(height: 12),
                  _RoleCard(
                    title: 'Soy Creadora',
                    subtitle: 'Construye tu marca, monetiza tus pasiones con pagos seguros y conecta directamente con tu audiencia regional.',
                    label: 'MONETIZA TU TALENTO',
                    selected: _selectedRole == 'creator',
                    onTap: () => setState(() => _selectedRole = 'creator'),
                  ),

                  const SizedBox(height: 32),

                  // Create account section
                  const Text(
                    'Crea tu Cuenta',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 20),

                  LuxorTextField(
                    controller: _emailController,
                    hintText: 'nombre@latam.com',
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined, color: LuxorColors.textMuted, size: 20),
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
                        color: LuxorColors.textMuted,
                        size: 20,
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
                    label: 'Iniciar Sesión',
                    isLoading: _isLoading,
                    onPressed: _login,
                  ),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿No tienes cuenta? ', style: TextStyle(color: LuxorColors.textSecondary, fontSize: 13)),
                      GestureDetector(
                        onTap: () => context.go('/register'),
                        child: const Text(
                          'Crear Cuenta',
                          style: TextStyle(color: LuxorColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Security badges
                  const Text(
                    'SEGURIDAD LATAM GARANTIZADA',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: LuxorColors.textMuted, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SecurityBadge(icon: Icons.account_balance_wallet, label: 'Pix'),
                      const SizedBox(width: 16),
                      _SecurityBadge(icon: Icons.payment, label: 'Mercado Pago'),
                      const SizedBox(width: 16),
                      _SecurityBadge(icon: Icons.receipt_long, label: 'Boleto'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_user, color: LuxorColors.textMuted, size: 14),
                      const SizedBox(width: 4),
                      const Text('Tellete Local', style: TextStyle(color: LuxorColors.textMuted, fontSize: 11)),
                    ],
                  ),

                  const SizedBox(height: 32),
                  Text(
                    '© 2024 Plataforma LATAM. Orgullosamente Hecho en\nLatinoamérica.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: LuxorColors.textMuted, fontSize: 10, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: LuxorColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? LuxorColors.primary : LuxorColors.surfaceElevated,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: LuxorColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label,
                style: const TextStyle(color: LuxorColors.primary, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1),
              ),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: LuxorColors.textSecondary, fontSize: 13, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

class _SecurityBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SecurityBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: LuxorColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: LuxorColors.textMuted, size: 14),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: LuxorColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}
