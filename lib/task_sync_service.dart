import 'package:shared_preferences/shared_preferences.dart';
import 'task_api_service.dart';
import 'task_local_database.dart';

class TaskSyncService {
  static Future<void> loadInitialDataIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstRun = prefs.getBool('sync_done') ?? true;

    if (isFirstRun && TaskLocalDatabase.isEmpty()) {
      final tasks = await TaskApiService.fetchTasks();
      await TaskLocalDatabase.saveTasks(tasks);
      await prefs.setBool('sync_done', false);
    }
  }
}