import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/auth/auth_provider.dart';

// Import Screens
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/records/screens/records_list_screen.dart';
import '../features/records/screens/record_detail_screen.dart';
import '../features/records/screens/create_record_screen.dart';
import '../features/voice/screens/voice_screen.dart';
import '../features/alerts/screens/alerts_screen.dart';
import '../features/reports/screens/reports_screen.dart';
import '../features/growth/screens/growth_screen.dart';
import '../features/attendance/screens/attendance_screen.dart';
import '../features/visits/screens/visits_screen.dart';
import '../features/activity/screens/activity_screen.dart';
import '../features/knowledge/screens/knowledge_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/photo/screens/photo_check_screen.dart';
import '../features/more/screens/more_menu_screen.dart';

// ── Navigator Keys ────────────────────────────────────────────────────────────
// Declared at file scope so they are true singletons — never recreated.
final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

// ── Auth Listenable ───────────────────────────────────────────────────────────
// A thin ChangeNotifier that GoRouter watches for redirect re-evaluation.
// We update it via ref.listen so the GoRouter instance is never recreated.
class _AuthRouterNotifier extends ChangeNotifier {
  AuthState _authState = AuthState(isLoading: true);

  AuthState get authState => _authState;

  void update(AuthState next) {
    _authState = next;
    notifyListeners();
  }
}

final _authRouterNotifierProvider =
    Provider<_AuthRouterNotifier>((ref) => _AuthRouterNotifier());

// ── Router Provider ───────────────────────────────────────────────────────────
// Created exactly once. Auth changes are pushed into the refreshListenable
// so GoRouter re-evaluates redirect() without rebuilding the router.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_authRouterNotifierProvider);

  // Push auth state changes into the listenable.
  ref.listen<AuthState>(authStateProvider, (_, next) {
    notifier.update(next);
  });

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: notifier,
    redirect: (BuildContext context, GoRouterState state) {
      final auth = notifier.authState;

      // While loading, stay put.
      if (auth.isLoading) return null;

      final isLoggedIn = auth.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithBottomNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/records',
            builder: (context, state) => const RecordsListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const CreateRecordScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final childId = int.parse(state.pathParameters['id']!);
                  return RecordDetailScreen(childId: childId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/voice',
            builder: (context, state) => const VoiceScreen(),
          ),
          GoRoute(
            path: '/alerts',
            builder: (context, state) => const AlertsScreen(),
          ),
          GoRoute(
            path: '/more',
            builder: (context, state) => const MoreMenuScreen(),
            routes: [
              GoRoute(
                path: 'reports',
                builder: (context, state) => const ReportsScreen(),
              ),
              GoRoute(
                path: 'attendance',
                builder: (context, state) => const AttendanceScreen(),
              ),
              GoRoute(
                path: 'visits',
                builder: (context, state) => const VisitsScreen(),
              ),
              GoRoute(
                path: 'activity',
                builder: (context, state) => const ActivityScreen(),
              ),
              GoRoute(
                path: 'knowledge',
                builder: (context, state) => const KnowledgeScreen(),
              ),
              GoRoute(
                path: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
              GoRoute(
                path: 'photo',
                builder: (context, state) => const PhotoCheckScreen(),
              ),
              GoRoute(
                path: 'growth/:childId',
                builder: (context, state) {
                  final childId =
                      int.parse(state.pathParameters['childId']!);
                  return GrowthScreen(childId: childId);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

// ── Bottom Navigation Shell ───────────────────────────────────────────────────
class ScaffoldWithBottomNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithBottomNavBar({
    super.key,
    required this.child,
  });

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/records')) return 1;
    if (location.startsWith('/voice')) return 2;
    if (location.startsWith('/alerts')) return 3;
    if (location.startsWith('/more')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/home');
      case 1:
        GoRouter.of(context).go('/records');
      case 2:
        GoRouter.of(context).go('/voice');
      case 3:
        GoRouter.of(context).go('/alerts');
      case 4:
        GoRouter.of(context).go('/more');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) => _onItemTapped(index, context),
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'मुख्य (Home)',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              activeIcon: Icon(Icons.people_rounded),
              label: 'रिकॉर्ड (Records)',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mic_none_rounded, size: 28),
              activeIcon: Icon(Icons.mic_rounded, size: 30),
              label: 'आवाज़ (Voice)',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warning_amber_rounded),
              activeIcon: Icon(Icons.warning_rounded),
              label: 'अलर्ट (Alerts)',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'अन्य (More)',
            ),
          ],
        ),
      ),
    );
  }
}
