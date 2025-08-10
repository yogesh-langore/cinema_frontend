import 'package:flutter/material.dart';
import 'package:flutter_cinema/presentation/screens/splash_screen.dart';
import 'package:flutter_cinema/repo/hive_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  HiveRepo().registerAdapter();
  runApp(const ProviderScope(child: CinemaApp()));
}

class CinemaApp extends ConsumerWidget {
  const CinemaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const MaterialApp(
      title: 'Cinema App',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
