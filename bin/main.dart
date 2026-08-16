import 'dart:convert';
import 'dart:io';

// =======================
// INTERFACE
// =======================

abstract interface class JsonSerializable {
  Map<String, dynamic> toJson();
}

// =======================
// EXCEPTIONS PERSONNALISÉES
// =======================

class TaskNotFoundException implements Exception {
  final String message;

  TaskNotFoundException(
      [this.message = "Tâche introuvable"]);

  @override
  String toString() => message;
}

class InvalidTaskException implements Exception {
  final String message;

  InvalidTaskException(
      [this.message = "Titre invalide"]);

  @override
  String toString() => message;
}

// =======================
// CLASSE ABSTRAITE
// =======================

abstract class Task
    implements JsonSerializable {
  int id;
  String title;
  String priority;
  bool completed;
  DateTime? dueDate;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    this.completed = false,
    this.dueDate,
  });

  void markCompleted() {
    completed = true;
  }
}

// =======================
// HÉRITAGE
// =======================

class UrgentTask extends Task {
  UrgentTask({
    required super.id,
    required super.title,
    DateTime? dueDate,
  }) : super(
          priority: "high",
          dueDate: dueDate,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "priority": priority,
      "completed": completed,
      "dueDate": dueDate?.toIso8601String(),
    };
  }

  factory UrgentTask.fromJson(
      Map<String, dynamic> json) {
    return UrgentTask(
      id: json["id"],
      title: json["title"],
      dueDate: json["dueDate"] != null
          ? DateTime.parse(json["dueDate"])
          : null,
    )..completed =
        json["completed"] ?? false;
  }
}

// =======================
// GÉNÉRIQUES
// =======================

abstract class Repository<T> {
  Future<List<T>> getAll();

  Future<void> saveAll(
      List<T> items);
}

// =======================
// REPOSITORY JSON
// =======================

class TaskRepository
    implements Repository<UrgentTask> {
  final String filePath;

  TaskRepository(this.filePath);

  @override
  Future<List<UrgentTask>> getAll() async {
    final file = File(filePath);

    if (!await file.exists()) {
      return [];
    }

    final content =
        await file.readAsString();

    if (content.isEmpty) {
      return [];
    }

    final List<dynamic> data =
        jsonDecode(content);

    return data
        .map((e) =>
            UrgentTask.fromJson(e))
        .toList();
  }

  @override
  Future<void> saveAll(
      List<UrgentTask> tasks) async {
    final file = File(filePath);

    await file.writeAsString(
      jsonEncode(
        tasks
            .map((e) => e.toJson())
            .toList(),
      ),
    );
  }
}

// =======================
// SERVICE
// =======================

class TaskService {
  final TaskRepository repository;

  TaskService(this.repository);

  Future<void> addTask(
      String title) async {
    if (title.trim().isEmpty) {
      throw InvalidTaskException();
    }

    final tasks =
        await repository.getAll();

    tasks.add(
      UrgentTask(
        id: tasks.length + 1,
        title: title,
      ),
    );

    await repository.saveAll(tasks);
  }

  Future<List<UrgentTask>>
      getTasks() async {
    return repository.getAll();
  }

  Future<void> completeTask(
      int id) async {
    final tasks =
        await repository.getAll();

    final task = tasks.where(
      (t) => t.id == id,
    );

    if (task.isEmpty) {
      throw TaskNotFoundException();
    }

    task.first.markCompleted();

    await repository.saveAll(tasks);
  }

  Future<void> deleteTask(
      int id) async {
    final tasks =
        await repository.getAll();

    tasks.removeWhere(
      (t) => t.id == id,
    );

    await repository.saveAll(tasks);
  }
}

// =======================
// CLI
// =======================

Future<void> main() async {
  final service = TaskService(
    TaskRepository("tasks.json"),
  );

  while (true) {
    print("\n=== TASK MANAGER ===");
    print("1. Ajouter");
    print("2. Lister");
    print("3. Terminer");
    print("4. Supprimer");
    print("5. Quitter");

    stdout.write("Choix : ");

    final choice =
        stdin.readLineSync();

    switch (choice) {
      case "1":
        stdout.write("Titre : ");

        final title =
            stdin.readLineSync() ?? "";

        await service.addTask(title);

        print("Tâche ajoutée");
        break;

      case "2":
        final tasks =
            await service.getTasks();

        if (tasks.isEmpty) {
          print("Aucune tâche");
        } else {
          for (var task in tasks) {
            print(
              "[${task.completed ? "X" : " "}] "
              "${task.id} - ${task.title}",
            );
          }
        }
        break;

      case "3":
        stdout.write("ID : ");

        final id = int.parse(
          stdin.readLineSync()!,
        );

        await service.completeTask(id);

        print("Terminée");
        break;

      case "4":
        stdout.write("ID : ");

        final id = int.parse(
          stdin.readLineSync()!,
        );

        await service.deleteTask(id);

        print("Supprimée");
        break;

      case "5":
        exit(0);

      default:
        print("Choix invalide");
    }
  }
}
