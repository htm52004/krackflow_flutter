import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final List<Task> tasks = [
    Task(title: "Zrobić projekt z baz danych", deadline: "jutro", done: false, priority: "wysoki"),
    Task(title: "Przygotować prezentację", deadline: "poniedziałek", done: true, priority: "średni"),
    Task(title: "Oddać raport z fizyki", deadline: "piątek", done: false, priority: "wysoki"),
    Task(title: "Nauczyć się Fluttera", deadline: "weekend", done: true, priority: "niski"),
  ];

  @override
  Widget build(BuildContext context) {
    final doneCount = tasks.where((task) => task.done).length;

    return MaterialApp(
      title: 'KrakFlow',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('KrakFlow'),
        ),
        body: ListView.builder(
          itemCount: tasks.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Masz dziś ${tasks.length} zadania, wykonano $doneCount",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Dzisiejsze zadania",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }

            final task = tasks[index - 1];
            return TaskCard(
              title: task.title,
              subtitle: "Termin: ${task.deadline}, Priorytet: ${task.priority}",
              done: task.done,
            );
          },
        ),
      ),
    );
  }
}

class Task {
  final String title;
  final String deadline;
  final bool done;
  final String priority;

  Task({
    required this.title,
    required this.deadline,
    required this.done,
    required this.priority,
  });
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool done;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(done ? Icons.check_circle : Icons.radio_button_unchecked),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}