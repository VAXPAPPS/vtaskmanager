import 'package:flutter/material.dart';
import 'package:vtaskmanager/core/colors/vaxp_colors.dart';
import 'package:window_manager/window_manager.dart';
import 'core/theme/vaxp_theme.dart';
import 'package:venom_config/venom_config.dart';
import 'infrastructure/hive_service.dart';
import 'presentation/app_shell.dart';

Future<void> main() async {
  // Initialize Flutter bindings first to ensure the binary messenger is ready
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive (local database)
  await HiveService.init();

  // Initialize Venom Config System
  await VenomConfig().init();

  // Initialize VaxpColors listeners
  VaxpColors.init();

  // Initialize window manager for desktop controls
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1100, 750),
    center: true,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: VaxpTheme.dark,
      home: const AppShell(),
    );
  }
}
