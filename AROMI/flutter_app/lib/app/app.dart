import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme.dart';

class AromiApp extends ConsumerWidget {
  const AromiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'AROMI',
      debugShowCheckedModeBanner: false,
      theme: AromiTheme.lightTheme,
      routerConfig: router,
    );
  }
}
