import 'package:go_router/go_router.dart';

import '../../features/home/home_shell.dart';
import '../widgets/placeholder_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/onboarding',
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
            builder: (_, __) => const PlaceholderScreen(
                title: 'Visão Geral', subtitle: 'KPIs e alertas ativos'),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/alertas',
            builder: (_, __) => const PlaceholderScreen(
                title: 'Alertas', subtitle: 'Lista com filtros'),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, s) => PlaceholderScreen(
                    title: 'Alerta ${s.pathParameters['id']}',
                    subtitle: 'Justificativa, confiança e limitações'),
                routes: [
                  GoRoute(
                    path: 'decisao',
                    builder: (_, s) => PlaceholderScreen(
                        title: 'Decisão do gestor',
                        subtitle: 'Formulário para o alerta ${s.pathParameters['id']}'),
                  ),
                ],
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/decisoes',
            builder: (_, __) => const PlaceholderScreen(
                title: 'Histórico de decisões'),
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
      builder: (_, s) => PlaceholderScreen(
          title: 'Dashboard: ${s.pathParameters['tema']}',
          subtitle: 'clima | agua | residuos'),
    ),
    GoRoute(
      path: '/territorios',
      builder: (_, __) => const PlaceholderScreen(title: 'Territórios'),
    ),
    GoRoute(
      path: '/sobre',
      builder: (_, __) => const PlaceholderScreen(
          title: 'Fontes e limitações'),
    ),
  ],
);
