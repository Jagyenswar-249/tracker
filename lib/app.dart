import 'package:flutter/material.dart';
import 'core/theme/brim_theme.dart';
import 'core/widgets/app_shell.dart';
import 'data/repositories/progress_repository_impl.dart';
import 'data/repositories/work_repository_impl.dart';
import 'domain/usecases/create_work.dart';
import 'domain/usecases/set_progress.dart';
import 'domain/usecases/watch_period_snapshot.dart';
import 'domain/usecases/work_usecases.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/tasks/tasks_controller.dart';

class BrimApp extends StatefulWidget {
  final bool showOnboarding;

  const BrimApp({super.key, this.showOnboarding = false});

  @override
  State<BrimApp> createState() => _BrimAppState();
}

class _BrimAppState extends State<BrimApp> {
  late WorkRepositoryImpl _workRepository;
  late ProgressRepositoryImpl _progressRepository;
  late TasksController _tasksController;
  late bool _onboardingVisible;

  @override
  void initState() {
    super.initState();
    _onboardingVisible = widget.showOnboarding;

    // Start with a clean empty database (no demo tasks)
    _workRepository = WorkRepositoryImpl(initialWorks: const []);
    _progressRepository = ProgressRepositoryImpl(
      workRepository: _workRepository,
      initialEntries: const [],
    );

    final setProgress = SetProgress(_progressRepository);
    final createWork = CreateWork(_workRepository);
    final updateWork = UpdateWork(_workRepository);
    final watchPeriod = WatchPeriodSnapshot(_workRepository, _progressRepository);
    final archiveWork = ArchiveWork(_workRepository);
    final deleteWork = DeleteWork(_workRepository);

    _tasksController = TasksController(
      watchPeriodSnapshot: watchPeriod,
      setProgress: setProgress,
      createWork: createWork,
      updateWork: updateWork,
      archiveWork: archiveWork,
      deleteWork: deleteWork,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brim — Work Progress Tracker',
      debugShowCheckedModeBanner: false,
      theme: BrimTheme.lightTheme(),
      darkTheme: BrimTheme.darkTheme(),
      themeMode: ThemeMode.dark, // Default to dark liquid glass
      home: _onboardingVisible
          ? OnboardingPage(
              onFinish: () => setState(() => _onboardingVisible = false),
            )
          : AppShell(
              tasksController: _tasksController,
              workRepository: _workRepository,
            ),
    );
  }
}
