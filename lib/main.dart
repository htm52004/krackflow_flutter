import 'package:flutter/material.dart';
import 'task_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'KrakFlow',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = "wszystkie";

  @override
  Widget build(BuildContext context) {
    List<Task> filteredTasks = TaskRepository.tasks;

    if (selectedFilter == "wykonane") {
      filteredTasks = TaskRepository.tasks.where((t) => t.done).toList();
    } else if (selectedFilter == "do zrobienia") {
      filteredTasks = TaskRepository.tasks.where((t) => !t.done).toList();
    }

    final doneCount = TaskRepository.tasks.where((task) => task.done).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('KrakFlow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: TaskRepository.tasks.isEmpty ? null : () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Zadania: ${TaskRepository.tasks.length}, wykonano: $doneCount"),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _filterBtn("wszystkie"),
                    _filterBtn("do zrobienia"),
                    _filterBtn("wykonane"),
                  ],
                ),
                const Divider(),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                return Dismissible(
                  key: ObjectKey(task),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (dir) {
                    setState(() {
                      TaskRepository.tasks.remove(task);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Usunięto ${task.title}")),
                    );
                  },
                  child: TaskCard(
                    title: task.title,
                    subtitle: "Termin: ${task.deadline} | Priorytet: ${task.priority}",
                    done: task.done,
                    onChanged: (val) {
                      setState(() {
                        final originalIndex = TaskRepository.tasks.indexOf(task);
                        TaskRepository.tasks[originalIndex] = Task(
                          title: task.title,
                          deadline: task.deadline,
                          priority: task.priority,
                          done: val!,
                        );
                      });
                    },
                    onTap: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (c) => EditTaskScreen(task: task)),
                      );
                      if (updated != null) {
                        setState(() {
                          final idx = TaskRepository.tasks.indexOf(task);
                          TaskRepository.tasks[idx] = updated;
                        });
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
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const AddTaskScreen()),
          );
          if (newTask != null) {
            setState(() {
              TaskRepository.tasks.add(newTask);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _filterBtn(String filter) {
    final isSel = selectedFilter == filter;
    return TextButton(
      onPressed: () => setState(() => selectedFilter = filter),
      child: Text(
        filter,
        style: TextStyle(
          color: isSel ? Colors.blue : Colors.grey,
          fontWeight: isSel ? FontWeight.bold : null,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Usuwanie"),
        content: const Text("Usunąć wszystkie zadania?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Anuluj")),
          TextButton(
            onPressed: () {
              setState(() {
                TaskRepository.tasks.clear();
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Wyczyszczono listę")),
              );
            },
            child: const Text("Usuń"),
          ),
        ],
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool done;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.done,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(value: done, onChanged: onChanged),
        title: Text(
          title,
          style: TextStyle(
            decoration: done ? TextDecoration.lineThrough : null,
            color: done ? Colors.grey : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});
  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final tCont = TextEditingController();
  final dCont = TextEditingController();
  final pCont = TextEditingController();

  @override
  void dispose() {
    tCont.dispose();
    dCont.dispose();
    pCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nowe zadanie")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: tCont, decoration: const InputDecoration(labelText: "Tytuł")),
            TextField(controller: dCont, decoration: const InputDecoration(labelText: "Termin")),
            TextField(controller: pCont, decoration: const InputDecoration(labelText: "Priorytet")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(
                context,
                Task(
                  title: tCont.text,
                  deadline: dCont.text,
                  priority: pCont.text,
                  done: false,
                ),
              ),
              child: const Text("Zapisz"),
            ),
          ],
        ),
      ),
    );
  }
}

class EditTaskScreen extends StatefulWidget {
  final Task task;
  const EditTaskScreen({super.key, required this.task});
  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController tCont, dCont, pCont;

  @override
  void initState() {
    super.initState();
    tCont = TextEditingController(text: widget.task.title);
    dCont = TextEditingController(text: widget.task.deadline);
    pCont = TextEditingController(text: widget.task.priority);
  }

  @override
  void dispose() {
    tCont.dispose();
    dCont.dispose();
    pCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edycja")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: tCont, decoration: const InputDecoration(labelText: "Tytuł")),
            TextField(controller: dCont, decoration: const InputDecoration(labelText: "Termin")),
            TextField(controller: pCont, decoration: const InputDecoration(labelText: "Priorytet")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(
                context,
                Task(
                  title: tCont.text,
                  deadline: dCont.text,
                  priority: pCont.text,
                  done: widget.task.done,
                ),
              ),
              child: const Text("Zaktualizuj"),
            ),
          ],
        ),
      ),
    );
  }
}