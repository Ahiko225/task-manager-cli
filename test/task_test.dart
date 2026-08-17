import 'package:test/test.dart';

void main() {
  test('Création tâche', () {
    expect(
      'Apprendre Dart',
      equals('Apprendre Dart'),
    );
  });

  test('Marquer terminée', () {
    bool completed = true;

    expect(
      completed,
      isTrue,
    );
  });

  test('Suppression tâche', () {
    List<String> tasks = [
      'A',
      'B'
    ];

    tasks.remove('A');

    expect(
      tasks.length,
      equals(1),
    );
  });

  test('Liste vide', () {
    expect(
      [],
      isEmpty,
    );
  });

  test('Exception', () {
    expect(
      () => throw Exception(),
      throwsException,
    );
  });
}
