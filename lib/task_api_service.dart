import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'task_repository.dart';

class TaskApiService {
  static const String baseUrl = "https://dummyjson.com";

  static Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse("$baseUrl/todos"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List todos = data["todos"];
      final random = Random();
      final priorities = ["niski", "średni", "wysoki"];

      return todos.map((todo) {
        return Task(
          id: todo["id"],
          title: todo["todo"],
          deadline: "brak",
          priority: priorities[random.nextInt(priorities.length)],
          done: todo["completed"],
        );
      }).toList().cast<Task>();
    } else {
      throw Exception("Błąd API");
    }
  }
}