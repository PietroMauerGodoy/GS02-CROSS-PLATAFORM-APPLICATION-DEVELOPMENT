import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class PainelApp extends ConsumerWidget {
  const PainelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cfg = ref.watch(configProvider);

    return MaterialApp.router(
      title: 'Painel Territorial',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(Brightness.light, altoContraste: cfg.altoContraste),
      darkTheme:
          AppTheme.build(Brightness.dark, altoContraste: cfg.altoContraste),
      themeMode: cfg.tema,
      routerConfig: appRouter,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(cfg.escalaFonte)),
        child: child!,
      ),
    );
  }
}