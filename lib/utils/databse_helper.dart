import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

/// Firebase対応
///
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<void> initializeDatabase() async {
    if (_database != null) return;
    _database = await openDatabase(
      join(await getDatabasesPath(), 'quiz.db'),
      version: 1,
      onCreate: (db, version) {
        db.execute(
          "CREATE TABLE Quiz(quizId TEXT PRIMARY KEY, "
              "quizText TEXT, options TEXT, explanation TEXT, difficulty INTEGER, category TEXT, "
              "createdBy TEXT, updatedAt INTEGER)",
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
        // プライマリーいるわ
        db.execute(
          "CREATE TABLE QuizMgmt(updateId TEXT, lastUpdated INTEGER)"
        );
        // db.execute(
        //   "CREATE TABLE Update(updateId TEXT PRIMARY KEY, timestamp INTEGER)",
        // );

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

    await db.insert('QuizMgmt', {'updateId':'0', 'lastUpdated':'946652400'});
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

// FB格納じゃ
  static Future<bool> insertQuizToFirestore(Map<String, dynamic> quiz) async {
    return FirebaseFirestore.instance.collection('quizOnFb').add(quiz)
        .then((value) {
      return true;
    })
        .catchError((error) {
      print("Error adding document to Firestore: $error");
      return false;
    });
  }

  // Local 格納じゃ
  static Future<void> insertQuizToLocalDB(Map<String, dynamic> quiz) async {
    if (_database == null) await initializeDatabase();
    await _database!.insert('Quiz', quiz);
  }

  // Firestoreからクイズ取得
  static Future<List<Map<String, dynamic>>> getQuizzesFromFirestore() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('quizOnFb').get();
      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error getting documents from Firestore: $e");
      return [];
    }
  }

  // Firebase にQuizを突っ込んでみる
  static Future<void> addQuizzesToFirestore(List<Map<String, dynamic>> quizzes) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String collectionName = 'quizOnFb';

    for (var quiz in quizzes) {
      await firestore.runTransaction((transaction) async {
        // quizIdの重複チェック
        QuerySnapshot snapshot = await firestore
            .collection(collectionName)
            .where('quizId', isEqualTo: quiz['quizId'])
            .get();

        if (snapshot.docs.isEmpty) {
          // 重複がなければ新しいドキュメントを追加
          await firestore.collection(collectionName).add(quiz);
          print("ここまでOK");
        } else {
          print('重複エラー: 同じquizIdを持つドキュメントが既に存在します');
        }
      });
    }
  }

  //アプデ対応
  static Future<Map<String, dynamic>> getRecentVersionFromLocal() async {
    if (_database == null) await initializeDatabase();
    List<Map<String, dynamic>> result = await _database!.query(
      'QuizMgmt',
      orderBy: 'lastUpdated DESC',
      limit: 1,
    );
    return result.isNotEmpty ? result.first :  {'updateId': '0', 'lastUpdated': 0};
  }

  //アプデ対応
  static Future<void> performUpdate(Map<String, dynamic> updateId) async {

    // FBから取ってきたクイズをローカルに保存

    // 成功したら→ローカルのQuizMgmtテーブルにインサートする処理
    final latestUpdate = {
      'updateId': updateId['updateId'],
      'lastUpdated': updateId['lastUpdated'],
    };
    if (_database == null) await initializeDatabase();
    await _database!.insert('QuizMgmt', latestUpdate );
    // 最後に UI に成功とエラーを記載


    print('アップデート処理を実行しました: $latestUpdate');
  }


}