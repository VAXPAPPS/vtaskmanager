import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../application/task_bloc/task_bloc.dart';
import '../application/task_bloc/task_event.dart';
import '../application/category_bloc/category_bloc.dart';
import '../application/category_bloc/category_event.dart';
import '../application/stats_bloc/stats_bloc.dart';
import '../data/datasources/local_data_source.dart';
import '../data/repositories/task_repository_impl.dart';
import '../data/repositories/category_repository_impl.dart';
import 'widgets/sidebar.dart';
import 'pages/home_page.dart';
import 'pages/task_list_page.dart';
import 'pages/kanban_page.dart';
import 'pages/categories_page.dart';
import 'pages/stats_page.dart';
import '../core/venom_layout.dart';

/// الهيكل الرئيسي للتطبيق
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final _pages = <Widget>[
    const HomePage(),
    const TaskListPage(),
    const KanbanPage(),
    const CategoriesPage(),
    const StatsPage(),
  ];

  static const _titles = [
    'الرئيسية',
    'المهام',
    'Kanban Board',
    'التصنيفات',
    'الإحصائيات',
  ];

  late final LocalDataSource _localDataSource;
  late final TaskRepositoryImpl _taskRepo;
  late final CategoryRepositoryImpl _catRepo;

  @override
  void initState() {
    super.initState();
    _localDataSource = LocalDataSource();
    _taskRepo = TaskRepositoryImpl(_localDataSource);
    _catRepo = CategoryRepositoryImpl(_localDataSource);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TaskBloc(_taskRepo)..add(LoadTasks())),
        BlocProvider(
          create: (_) => CategoryBloc(_catRepo)..add(LoadCategories()),
        ),
        BlocProvider(create: (_) => StatsBloc(_taskRepo)),
      ],
      child: VenomScaffold(
        title: _titles[_currentIndex],
        body: Row(
          children: [
            Sidebar(
              selectedIndex: _currentIndex,
              onItemSelected: (index) {
                setState(() => _currentIndex = index);
              },
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: IndexedStack(
                  key: ValueKey(_currentIndex),
                  index: _currentIndex,
                  children: _pages,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
