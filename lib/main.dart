import 'package:flutter/material.dart';
import 'dart:math';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'task_repository.dart';
import 'task_local_database.dart';
import 'task_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("tasks");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = "wszystkie";
  List<Task> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    await TaskSyncService.loadInitialDataIfNeeded();
    setState(() {
      tasks = TaskLocalDatabase.getTasks();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    List<Task> filteredTasks = tasks;
    if (selectedFilter == "wykonane") filteredTasks = tasks.where((t) => t.done).toList();
    if (selectedFilter == "do zrobienia") filteredTasks = tasks.where((t) => !t.done).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('KrakFlow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              await TaskLocalDatabase.deleteAllTasks();
              setState(() => tasks = []);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(onPressed: () => setState(() => selectedFilter = "wszystkie"), child: const Text("wszystkie")),
              TextButton(onPressed: () => setState(() => selectedFilter = "do zrobienia"), child: const Text("do zrobienia")),
              TextButton(onPressed: () => setState(() => selectedFilter = "wykonane"), child: const Text("wykonane")),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                return Dismissible(
                  key: ValueKey(task.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (dir) async {
                    await TaskLocalDatabase.deleteTask(task.id);
                    setState(() => tasks.removeWhere((t) => t.id == task.id));
                  },
                  child: ListTile(
                    leading: Checkbox(
                      value: task.done,
                      onChanged: (val) async {
                        task.done = val ?? false;
                        await TaskLocalDatabase.updateTask(task);
                        setState(() {});
                      },
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.done ? TextDecoration.lineThrough : null,
                        color: task.done ? Colors.grey : null,
                      ),
                    ),
                    subtitle: Text("${task.deadline} | ${task.priority}"),
                    onTap: () async {
                      final updated = await Navigator.push(context, MaterialPageRoute(builder: (c) => EditTaskScreen(task: task)));
                      if (updated != null) {
                        await TaskLocalDatabase.updateTask(updated);
                        loadTasks();
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.push(context, MaterialPageRoute(builder: (c) => const AddTaskScreen()));
          if (newTask != null) {
            final taskWithId = Task(
              id: Random().nextInt(1000000),
              title: newTask.title,
              deadline: newTask.deadline,
              priority: newTask.priority,
              done: false,
            );
            await TaskLocalDatabase.addTask(taskWithId);
            loadTasks();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final t = TextEditingController();
    final d = TextEditingController();
    final p = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text("Nowe zadanie")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: t, decoration: const InputDecoration(labelText: "Tytuł")),
            TextField(controller: d, decoration: const InputDecoration(labelText: "Termin")),
            TextField(controller: p, decoration: const InputDecoration(labelText: "Priorytet")),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, Task(id: 0, title: t.text, deadline: d.text, priority: p.text, done: false)),
              child: const Text("Zapisz"),
            ),
          ],
        ),
      ),
    );
  }
}

class EditTaskScreen extends StatelessWidget {
  final Task task;
  const EditTaskScreen({super.key, required this.task});
  @override
  Widget build(BuildContext context) {
    final t = TextEditingController(text: task.title);
    final d = TextEditingController(text: task.deadline);
    final p = TextEditingController(text: task.priority);
    return Scaffold(
      appBar: AppBar(title: const Text("Edycja")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: t),
            TextField(controller: d),
            TextField(controller: p),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, Task(id: task.id, title: t.text, deadline: d.text, priority: p.text, done: task.done)),
              child: const Text("Zaktualizuj"),
            ),
          ],
        ),
      ),
    );
  }
}