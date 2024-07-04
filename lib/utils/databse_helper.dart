import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class DatabaseHelper {
  static Database? _database;

  static Future<void> initializeDatabase() async {
    if (_database != null) return;
    _database = await openDatabase(
      join(await getDatabasesPath(), 'quiz.db'),
      version: 1,
      onCreate: (db, version) {
        db.execute(
          "CREATE TABLE Quiz(quizId TEXT PRIMARY KEY, quizText TEXT, options TEXT, explanation TEXT, difficulty INTEGER, category TEXT, createdBy TEXT, updatedAt INTEGER)",
        );
        db.execute(
          "CREATE TABLE QuizHistory(historyId TEXT PRIMARY KEY, startTimestamp INTEGER, updateTimestamp INTEGER, completeTimestamp INTEGER, isCompleted INTEGER, score INTEGER, totalQuestions INTEGER, correctAnswers INTEGER)",
        );
        db.execute(
          "CREATE TABLE User(globalUserId TEXT PRIMARY KEY, userId TEXT, nickname TEXT, email TEXT, profilePicture TEXT)",
        );
        db.execute(
          "CREATE TABLE QuizHistoryDetail(historyId TEXT, quizId TEXT, selectedOptionId TEXT, isCorrect INTEGER, timeTaken INTEGER)",
        );
        db.execute(
          "CREATE TABLE currentQuiz(historyId TEXT, quizId TEXT, selectedOptionId TEXT, isCorrect INTEGER)",
        );
        db.execute(
          "CREATE TABLE Fav(quizId TEXT PRIMARY KEY, timestamp INTEGER)",
        );
        db.execute(
          "CREATE TABLE Update(updateId TEXT PRIMARY KEY, timestamp INTEGER)",
        );

        _insertDummyData(db);
      },
    );
  }

  static Future<void> _insertDummyData(Database db) async {
    await db.insert('Quiz', {
      'quizId': '1',
      'quizText': 'これはサンプルクイズ1です。',
      'options': json.encode([
        {'optionId': '1', 'optionText': '選択肢1', 'isCorrect': false},
        {'optionId': '2', 'optionText': '選択肢2', 'isCorrect': true},
        {'optionId': '3', 'optionText': '選択肢3', 'isCorrect': false}
      ]),
      'explanation': 'これは解説1です。',
      'difficulty': 1,
      'category': 'Sample',
      'createdBy': 'admin',
      'updatedAt': DateTime.now().millisecondsSinceEpoch
    });

    await db.insert('Quiz', {
      'quizId': '2',
      'quizText': 'これはサンプルクイズ2です。',
      'options': json.encode([
        {'optionId': '1', 'optionText': '選択肢1', 'isCorrect': false},
        {'optionId': '2', 'optionText': '選択肢2', 'isCorrect': true},
        {'optionId': '3', 'optionText': '選択肢3', 'isCorrect': false}
      ]),
      'explanation': 'これは解説2です。',
      'difficulty': 2,
      'category': 'Sample',
      'createdBy': 'admin',
      'updatedAt': DateTime.now().millisecondsSinceEpoch
    });

    await db.insert('Quiz', {
      'quizId': '3',
      'quizText': 'これはサンプルクイズ3です。',
      'options': json.encode([
        {'optionId': '1', 'optionText': '選択肢1', 'isCorrect': false},
        {'optionId': '2', 'optionText': '選択肢2', 'isCorrect': true},
        {'optionId': '3', 'optionText': '選択肢3', 'isCorrect': false}
      ]),
      'explanation': 'これは解説3です。',
      'difficulty': 3,
      'category': 'Sample',
      'createdBy': 'admin',
      'updatedAt': DateTime.now().millisecondsSinceEpoch
    });
  }
  // 全県を正直に引っ張る
  static Future<List<Map<String, dynamic>>> getAllQuizzes() async {
    if (_database == null) await initializeDatabase();
    return await _database!.query('Quiz');
  }

  // ランダムに、かつ件数を指定してセレクト文を出す
  static Future<List<Map<String, dynamic>>> getQuizzesAsRandom({int? limit}) async {
    if (_database == null) await initializeDatabase();
    return await _database!.query(
      'Quiz',
      orderBy: 'RANDOM()',
      limit: limit,
    );
  }
// クイズ履歴の挿入
  static Future<void> insertQuizHistory(Map<String, dynamic> history) async {
    if (_database == null) await initializeDatabase();
    await _database!.insert('QuizHistory', history);
  }
//詳細クイズ履歴の挿入
  static Future<void> insertQuizHistoryDetail(Map<String, dynamic> detail) async {
    if (_database == null) await initializeDatabase();
    await _database!.insert('QuizHistoryDetail', detail);
  }
}