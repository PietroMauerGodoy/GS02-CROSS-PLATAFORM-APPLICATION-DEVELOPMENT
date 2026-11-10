import 'package:go_router/go_router.dart';

import '../../domain/models/enums.dart';
import '../../features/alertas/alerta_detalhe_page.dart';
import '../../features/alertas/alertas_page.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../features/decisoes/decisao_form_page.dart';
import '../../features/decisoes/decisoes_page.dart';
import '../../features/home/home_page.dart';
import '../../features/home/home_shell.dart';
import '../widgets/placeholder_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (_, __) => const PlaceholderScreen(
          title: 'Onboarding', subtitle: 'Escolha do território e perfil'),
    ),
    StatefulShellRoute.indexedStack(
      builder: (_, __, shell) => HomeShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const HomePage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/alertas',
            builder: (_, __) => const AlertasPage(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, s) =>
                    AlertaDetalhePage(id: s.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: 'decisao',
                    builder: (_, s) =>
                        DecisaoFormPage(alertaId: s.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/decisoes',
            builder: (_, __) => const DecisoesPage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/configuracoes',
            builder: (_, __) => const PlaceholderScreen(
                title: 'Configurações',
                subtitle: 'Acessibilidade e privacidade'),
          ),
        ]),
      ],
    ),
    GoRoute(
      path: '/dashboard/:tema',
      builder: (_, s) {
        final tema = Tema.values
                .where((t) => t.name == s.pathParameters['tema'])
                .firstOrNull ??
            Tema.clima;
        return DashboardPage(tema: tema);
      },
    ),
    GoRoute(
      path: '/territorios',
      builder: (_, __) => const PlaceholderScreen(title: 'Territórios'),
    ),
    GoRoute(
      path: '/sobre',
      builder: (_, __) =>
          const PlaceholderScreen(title: 'Fontes e limitações'),
    ),
  ],
);