import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/creator_register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/discover_screen.dart';
import '../../features/wallet/screens/wallet_screen.dart';
import '../../features/creator_profile/screens/creator_profile_screen.dart';
import '../../features/creator_dashboard/screens/dashboard_screen.dart';
import '../../features/creator_dashboard/screens/upload_content_screen.dart';
import '../../features/profile/screens/user_profile_screen.dart';
import '../../features/alerts/screens/alerts_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/checkout/screens/checkout_screen.dart';
import '../../features/shared/widgets/bottom_nav_bar.dart';

final storage = FlutterSecureStorage();

final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) async {
    final token = await storage.read(key: 'access_token');
    final isAuth = token != null;
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/register/creator';

    if (!isAuth && !isAuthRoute) return '/login';
    if (isAuth && isAuthRoute) return '/home';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(path: '/register/creator', builder: (context, state) => const CreatorRegisterScreen()),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/discover', builder: (context, state) => const DiscoverScreen()),
        GoRoute(path: '/wallet', builder: (context, state) => const WalletScreen()),
        GoRoute(path: '/creador/:username', builder: (context, state) => CreatorProfileScreen(username: state.pathParameters['username']!)),
        GoRoute(path: '/creador/:username/grid', builder: (context, state) => CreatorProfileScreen(username: state.pathParameters['username']!, isGridView: true)),
        GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
        GoRoute(path: '/dashboard/upload', builder: (context, state) => const UploadContentScreen()),
        GoRoute(path: '/profile', builder: (context, state) => const UserProfileScreen()),
        GoRoute(path: '/alerts', builder: (context, state) => const AlertsScreen()),
      ],
    ),
    GoRoute(
      path: '/chat/:username',
      builder: (context, state) => ChatScreen(username: state.pathParameters['username']!),
    ),
    GoRoute(
      path: '/checkout/:username',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return CheckoutScreen(
          creatorUsername: state.pathParameters['username']!,
          creatorAvatar: extra?['avatar'] ?? '',
          price: (extra?['price'] as num?)?.toDouble() ?? 9.99,
        );
      },
    ),
  ],
);

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _updateIndexFromLocation(String location) {
    if (location.startsWith('/home')) {
      _currentIndex = 0;
    } else if (location.startsWith('/discover')) {
      _currentIndex = 1;
    } else if (location.startsWith('/dashboard/upload')) {
      _currentIndex = 2;
    } else if (location.startsWith('/alerts')) {
      _currentIndex = 3;
    } else if (location.startsWith('/profile')) {
      _currentIndex = 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    _updateIndexFromLocation(location);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          switch (index) {
            case 0: context.go('/home'); break;
            case 1: context.go('/discover'); break;
            case 2: context.go('/dashboard/upload'); break;
            case 3: context.go('/alerts'); break;
            case 4: context.go('/profile'); break;
          }
        },
      ),
    );
  }
}
