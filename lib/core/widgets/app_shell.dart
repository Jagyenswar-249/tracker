import 'package:flutter/material.dart';
import '../../domain/entities/cadence.dart';
import '../../domain/entities/work.dart';
import '../../domain/repositories/work_repository.dart';
import '../../features/calendar/calendar_page.dart';
import '../../features/insights/insights_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/tasks/tasks_controller.dart';
import '../../features/tasks/tasks_page.dart';
import '../../features/work_editor/work_editor_sheet.dart';
import '../glass/glass_tab_bar.dart';

class AppShell extends StatefulWidget {
  final TasksController tasksController;
  final WorkRepository workRepository;

  const AppShell({
    super.key,
    required this.tasksController,
    required this.workRepository,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  void _openWorkEditor([Work? initialWork]) {
    WorkEditorSheet.show(
      context: context,
      initialWork: initialWork,
      onSave: (work) async {
        if (initialWork == null) {
          await widget.workRepository.createWork(work);
        } else {
          await widget.workRepository.updateWork(work);
        }
        await widget.tasksController.load();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      TasksPage(
        controller: widget.tasksController,
        onOpenEditor: () => _openWorkEditor(),
      ),
      CalendarPage(
        controller: widget.tasksController,
        onOpenEditor: () => _openWorkEditor(),
        onOpenDay: (date) {
          widget.tasksController.setAnchorDate(date, targetView: Cadence.daily);
          setState(() => _currentIndex = 0);
        },
      ),
      const InsightsPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: GlassTabBar(
        selectedIndex: _currentIndex,
        onTabSelected: (idx) => setState(() => _currentIndex = idx),
        onAddPressed: () => _openWorkEditor(),
      ),
    );
  }
}
