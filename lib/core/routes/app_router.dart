import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/calendar/presentation/screens/calendar_screen.dart';
import '../../features/canvas/presentation/screens/canvas_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/notebooks/presentation/screens/notebook_list_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: authState.isAuthenticated ? '/notebooks' : '/login',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isLogin = state.matchedLocation == '/login';

      if (!isAuth && !isLogin) return '/login';
      if (isAuth && isLogin) return '/notebooks';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/notebooks',
        builder: (context, state) => const NotebookListScreen(),
        routes: [
          GoRoute(
            path: 'note/:pageId',
            builder: (context, state) => CanvasScreen(
              pageId: state.pathParameters['pageId']!,
            ),
          ),
          GoRoute(
            path: 'canvas/:pageId',
            builder: (context, state) => CanvasScreen(
              pageId: state.pathParameters['pageId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/calendar',
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
