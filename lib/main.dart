import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'dart:convert';

// リファクタリング対応
import 'package:honegumi_dake/utils/databse_helper.dart';

// https://pub.dev/packages/uuid/install
import 'package:uuid/uuid.dart';

//Firebase 対応
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  print("main");
  WidgetsFlutterBinding.ensureInitialized();
//  await Firebase.initializeApp(); // Firebaseの初期化
  await DatabaseHelper.initializeDatabase();

  // firebase init をする
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  runApp(QuizApp());
}

class QuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StartScreen(),
      routes: {
        '/quizConfig': (context) => QuizConfigScreen(),
        // クイズ問題を渡す変更をするときに変数が必要なのでここは個別に宣言した。
//        '/quiz': (context) => QuizScreen(numQuestions: null,),
        '/result': (context) => ResultScreen(),
        '/mypage': (context) => MyPageScreen(),
        '/favorites': (context) => FavoritesScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}
// ソースコードを分割済みなので無視する
// class DatabaseHelper {
//   static Database? _database;
//
//   static Future<void> initializeDatabase() async {
//     if (_database != null) return; // DB の初期化がまだのときだけ。次以降実行されない。
//     _database = await openDatabase(
//       join(await getDatabasesPath(), 'quiz.db'),
//       onCreate: (db, version) {
//         db.execute(
//           "CREATE TABLE Quiz(quizId TEXT PRIMARY KEY, quizText TEXT, options TEXT, explanation TEXT, difficulty INTEGER, category TEXT, createdBy TEXT, updatedAt INTEGER)",
//         );
//         db.execute(
//           "CREATE TABLE QuizHistory(historyId TEXT PRIMARY KEY, startTimestamp INTEGER, updateTimestamp INTEGER, completeTimestamp INTEGER, isCompleted INTEGER, score INTEGER, totalQuestions INTEGER, correctAnswers INTEGER)",
//         );
//         db.execute(
//           "CREATE TABLE User(globalUserId TEXT PRIMARY KEY, userId TEXT, nickname TEXT, email TEXT, profilePicture TEXT)",
//         );
//         db.execute(
//           "CREATE TABLE QuizHistoryDetail(historyId TEXT, quizId TEXT, selectedOptionId TEXT, isCorrect INTEGER, timeTaken INTEGER)",
//         );
//         db.execute(
//           "CREATE TABLE currentQuiz(historyId TEXT, quizId TEXT, selectedOptionId TEXT, isCorrect INTEGER)",
//         );
//         db.execute(
//           "CREATE TABLE Fav(quizId TEXT PRIMARY KEY, timestamp INTEGER)",
//         );
//         db.execute(
//           "CREATE TABLE Update(updateId TEXT PRIMARY KEY, timestamp INTEGER)",
//         );
//
//         _insertDummyData(db);
//       },
//       version: 1,
//     );
//   }
//
//   static Future<void> _insertDummyData(Database db) async {
//     await db.insert('Quiz', {
//       'quizId': '1',
//       'quizText': 'これはサンプルクイズ1です。',
//       'options': json.encode([
//         {'optionId': '1', 'optionText': '選択肢1', 'isCorrect': false},
//         {'optionId': '2', 'optionText': '選択肢2', 'isCorrect': true},
//         {'optionId': '3', 'optionText': '選択肢3', 'isCorrect': false}
//       ]),
//       'explanation': 'これは解説1です。',
//       'difficulty': 1,
//       'category': 'Sample',
//       'createdBy': 'admin',
//       'updatedAt': DateTime.now().millisecondsSinceEpoch
//     });
//
//     await db.insert('Quiz', {
//       'quizId': '2',
//       'quizText': 'これはサンプルクイズ2です。',
//       'options': json.encode([
//         {'optionId': '1', 'optionText': '選択肢1', 'isCorrect': false},
//         {'optionId': '2', 'optionText': '選択肢2', 'isCorrect': true},
//         {'optionId': '3', 'optionText': '選択肢3', 'isCorrect': false}
//       ]),
//       'explanation': 'これは解説2です。',
//       'difficulty': 2,
//       'category': 'Sample',
//       'createdBy': 'admin',
//       'updatedAt': DateTime.now().millisecondsSinceEpoch
//     });
//
//     await db.insert('Quiz', {
//       'quizId': '3',
//       'quizText': 'これはサンプルクイズ3です。',
//       'options': json.encode([
//         {'optionId': '1', 'optionText': '選択肢1', 'isCorrect': false},
//         {'optionId': '2', 'optionText': '選択肢2', 'isCorrect': true},
//         {'optionId': '3', 'optionText': '選択肢3', 'isCorrect': false}
//       ]),
//       'explanation': 'これは解説3です。',
//       'difficulty': 3,
//       'category': 'Sample',
//       'createdBy': 'admin',
//       'updatedAt': DateTime.now().millisecondsSinceEpoch
//     });
//   }
//
//   static Future<List<Map<String, dynamic>>> getQuizzes() async {
//     if (_database == null) await initializeDatabase();
//     // select * from Quiz と恩時意味らしい
//     return await _database!.query('Quiz');
//   }
//
//   static Future<List<Map<String, dynamic>>> getQuizzesAsRandom({int? limit}) async {
//     if (_database == null) await initializeDatabase();
//     return await _database!.query(
//       'Quiz',
//       orderBy: 'RANDOM()',
//       limit: limit,
//     );
//   }
//
//   static Future<void> insertQuizHistory(Map<String, dynamic> history) async {
//     if (_database == null) await initializeDatabase();
//     await _database!.insert('QuizHistory', history);
//   }
//
//   static Future<void> insertQuizHistoryDetail(Map<String, dynamic> detail) async {
//     if (_database == null) await initializeDatabase();
//     await _database!.insert('QuizHistoryDetail', detail);
//   }
//
// }
// ソースコードを分割済みなので無視する。最後に消す


class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('クイズアプリ')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/hero_image.png'), // ヒーローイメージを表示
          Card(
            child: ListTile(
              title: Text('はじめる'),
              onTap: () {
                Navigator.pushNamed(context, '/quizConfig');
              },
            ),
          ),
          Card(
            child: ListTile(
              title: Text('マイページ'),
              onTap: () {
                Navigator.pushNamed(context, '/mypage');
              },
            ),
          ),
          Card(
            child: ListTile(
              title: Text('FB保存だよ'),
              onTap: () async {
                final quiz = {
                  'quizId': '4',
                  'quizText': 'これはFirestoreに挿入するクイズです。',
                  'options': json.encode([
                    {'optionId': '1', 'optionText': '選択肢1', 'isCorrect': false},
                    {'optionId': '2', 'optionText': '選択肢2', 'isCorrect': true},
                    {'optionId': '3', 'optionText': '選択肢3', 'isCorrect': false}
                  ]),
                  'explanation': 'これは解説です。',
                  'difficulty': 2,
                  'category': 'Sample',
                  'createdBy': 'admin',
                  'updatedAt': DateTime.now().millisecondsSinceEpoch
                };

                bool success = await DatabaseHelper.insertQuizToFirestore(quiz);
                if (success) {
                  _showSaveToLocalDialog(context, quiz);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('更新エラー')),);
                }
              },
            ),
          ),
          Card(
            child: ListTile(
              title: Text('FBからクイズ取得だよ'),
              onTap: () async {
                List<Map<String, dynamic>> quizzes = await DatabaseHelper.getQuizzesFromFirestore();
                if (quizzes.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('クイズ取得成功: ${quizzes.length}件')),
                  );
                  print(quizzes);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('クイズ取得エラー')),
                  );
                }
              },
            ),
          ),

        ],
      ),
    );
  }

  void _showSaveToLocalDialog(BuildContext context, Map<String, dynamic> quiz) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('確認'),
          content: Text('ローカルDBにも保存しますか？'),
          actions: <Widget>[
            TextButton(
              child: Text('いいえ'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('はい'),
              onPressed: () async {
                try {
                  await DatabaseHelper.insertQuizToLocalDB(quiz);
                  Navigator.of(context).pop();
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('ローカルDBへの保存エラー: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

}

class QuizConfigScreen extends StatefulWidget {
  @override
  _QuizConfigScreenState createState() => _QuizConfigScreenState();
}


class _QuizConfigScreenState extends State<QuizConfigScreen> {
  // 初期選択値
  int _selectedValue = 3;
  String _selectedCategory = '1'; // ジャンルの初期選択値

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('クイズ設定')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: _selectedCategory, // 初期値はクラスの配下にある。
              items: [
                DropdownMenuItem(child: Text('Data Cloud コンサル'), value: '1'),
                DropdownMenuItem(child: Text('MC コンサル'), value: '2'),
                DropdownMenuItem(child: Text('CRM'), value: '3'),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
                print(value.toString() + " これがプルダウン選択→Category");
              },
            ),
            DropdownButton<int>(
              value: _selectedValue, // 初期値はクラスの配下にある。
              items: [
                DropdownMenuItem(child: Text('1問'), value: 1),
                DropdownMenuItem(child: Text('2問'), value: 2),
                DropdownMenuItem(child: Text('3問'), value: 3),
                DropdownMenuItem(child: Text('4問'), value: 4),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedValue = value!;
                });
                print(value.toString() + " これがプルダウン選択→Value");
              },
            ),

            ElevatedButton(
              child: Text('スタート'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // ★あとでジャンルや失敗のみのオプションをつける
                    builder: (context) => QuizScreen(numQuestions: _selectedValue, category: _selectedCategory),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


class QuizScreen extends StatefulWidget {
  final int numQuestions;
  final String category;

  QuizScreen({required this.numQuestions, required this.category});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> _quizzes = [];
  int _currentQuestionIndex = 0;
  bool _isFavorite = false;
  bool _isAnswered = false;
  bool _isCorrect = false;
  int _correctAnswers = 0;
  List<Map<String, dynamic>> _quizHistoryDetail = [];
  late String _historyId;

  final _uuid = Uuid();


  @override
  void initState() {
    super.initState();
    _historyId = _uuid.v4(); // Generate a unique ID for this quiz session
    print(_historyId + "このクイズの通しID");
    _loadQuizzes();
    _loadFavoriteStatus();
    print(widget.category+"これは渡されたカテゴリーだよ");
    print(widget.numQuestions.toString() +"これは渡されたsuuji ");

  }

  Future<void> _loadQuizzes() async {
//    final quizzes = await DatabaseHelper.getQuizzesAsRandom(limit: widget.numQuestions);
  final quizzes = await DatabaseHelper.getAllQuizzes();
  print(quizzes.toString()+"ここがクイズです🙇🙇");
  // ★あとでランダムありなしフラグ立ててユーザーに選ばせる
//  quizzes.shuffle(Random()); // クイズをランダムにシャッフル
    setState(() {
      _quizzes =  quizzes.take(widget.numQuestions).toList(); // 選択した問題数だけを取得
    });
  }

  Future<void> _loadFavoriteStatus() async {
    print("お気に入りの読み込み _loadFavoriteStatus");
    if (_quizzes.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    setState(() {
      _isFavorite = favorites.contains(_quizzes[_currentQuestionIndex]['quizId']);
    });
  }

  Future<void> _toggleFavorite(String quizId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    print(favorites.toString() + "初期値: おきにです");

    // quiz id check
    if (favorites.contains(quizId)) {
      favorites.remove(quizId);
      setState(() {
        _isFavorite = false;
      });
    } else {
      favorites.add(quizId);
      setState(() {
        _isFavorite = true;
      });
    }

    await prefs.setStringList('favorites', favorites);
    print(favorites.toString() + "after お気に入り");
  }

  void _answerQuestion(bool isCorrect) {
    setState(() {
      _isAnswered = true;
      _isCorrect = isCorrect;
      // 正解、★ピンポンもさせたい
      if (isCorrect) {
        _correctAnswers++;
      }

      _quizHistoryDetail.add({
        'quizId': _quizzes[_currentQuestionIndex]['quizId'],
        'isCorrect': isCorrect ,
        'selectedOptionId': _currentQuestionIndex, // 適切な選択肢IDを設定する必要があります
        'timeTaken': 0, // 時間を追跡する場合に設定します
      });
      print(_quizHistoryDetail.toString() + "くいずひすとり");
    });
  }

  Future<void> _saveQuizHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('quizHistoryDetail') ?? [];
    history.addAll(_quizHistoryDetail.map((detail) => json.encode(detail)).toList());
    await prefs.setStringList('quizHistoryDetail', history);

    final historyData = {
      'historyId': _historyId,
      'startTimestamp': DateTime.now().millisecondsSinceEpoch,
      'updateTimestamp': DateTime.now().millisecondsSinceEpoch,
      'completeTimestamp': DateTime.now().millisecondsSinceEpoch,
      'isCompleted': 1,
      'score': _correctAnswers,
      'totalQuestions': _quizzes.length,
      'correctAnswers': _correctAnswers,
    };
    print("💩" + historyData.toString());
    await DatabaseHelper.insertQuizHistory(historyData);
    print(historyData.toString() + "ひすとり");

    for (var detail in _quizHistoryDetail) {
      final detailData = {
        'historyId': _historyId,
        'quizId': detail['quizId'],
        'selectedOptionId': detail['selectedOptionId'],
        'isCorrect': detail['isCorrect'] ,
        'timeTaken': detail['timeTaken'],
      };
      await DatabaseHelper.insertQuizHistoryDetail(detailData);
    }
  }

  Future<void> _clearQuizHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('quizHistoryDetail');
  }

  Future<bool> _onWillPop(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('確認'),
        content: Text('戻るとクイズを終了しますが、よろしいですか？'),
        actions: <Widget>[
          TextButton(
            child: Text('いいえ'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('はい'),
            onPressed: () async {
              await _saveQuizHistory();
              await _clearQuizHistory();
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (_quizzes.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('クイズ')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final quiz = _quizzes[_currentQuestionIndex];

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text('クイズ'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _onWillPop(context)) {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }
            },
          ),
          actions: [
            IconButton(
              icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () => _toggleFavorite(quiz['quizId']),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(quiz['quizText'], style: TextStyle(fontSize: 24)),
              ..._buildOptions(quiz),
              if (_isAnswered)
                Column(
                  children: [
                    Text(
                      _isCorrect ? '正解！' : '不正解',
                      style: TextStyle(fontSize: 24, color: _isCorrect ? Colors.green : Colors.red),
                    ),
                    SizedBox(height: 10),
                    Text('解説: ${quiz['explanation']}'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      child: Text(_currentQuestionIndex < _quizzes.length - 1 ? '次へ' : '結果を見る'),
                      onPressed: () async {
                        if (_currentQuestionIndex < _quizzes.length - 1) {
                          setState(() {
                            _currentQuestionIndex++;
                            _isAnswered = false;
                            _loadFavoriteStatus(); // 次のクイズのためにお気に入り状態をリセット
                          });
                        } else {
                          await _saveQuizHistory();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResultScreen(),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOptions(Map<String, dynamic> quiz) {
    final options = json.decode(quiz['options']) as List<dynamic>;

    return options.map((option) {
      return ElevatedButton(
        onPressed: _isAnswered
            ? null
            : () {
          _answerQuestion(option['isCorrect']);
        },
        child: Text(option['optionText']),
      );
    }).toList();
  }
}


class ResultScreen extends StatelessWidget {
  Future<List<Map<String, dynamic>>> _loadQuizHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('quizHistoryDetail') ?? [];
    return history.map((item) => json.decode(item) as Map<String, dynamic>).toList();
  }

  Future<void> _clearQuizHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('quizHistoryDetail');
  }

  Future<void> _toggleFavorite(String quizId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];

    if (favorites.contains(quizId)) {
      favorites.remove(quizId);
    } else {
      favorites.add(quizId);
    }

    await prefs.setStringList('favorites', favorites);
  }

  Future<bool> _isFavorite(String quizId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    return favorites.contains(quizId);
  }

  Future<bool> _onWillPop(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('確認'),
        content: Text('戻るとクイズを終了しますが、よろしいですか？'),
        actions: <Widget>[
          TextButton(
            child: Text('いいえ'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('はい'),
            onPressed: () async {
              await _clearQuizHistory();
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text('結果'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _onWillPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _loadQuizHistory(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final history = snapshot.data!;
            final correctAnswers = history.where((detail) => detail['isCorrect']).length;
            final totalQuestions = history.length;
            final int percentage = totalQuestions > 0 ? ((correctAnswers / totalQuestions) * 100).round() : 0;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('正解数: $correctAnswers / $totalQuestions', style: TextStyle(fontSize: 24)),
                  Text('正解率: $percentage%', style: TextStyle(fontSize: 24)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final detail = history[index];
                        return FutureBuilder<bool>(
                          future: _isFavorite(detail['quizId']),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return ListTile();
                            }
                            final isFavorite = snapshot.data!;
                            return Card(
                              child: ListTile(
                                title: Text('クイズ ${detail['quizId']}'),
                                subtitle: Text(detail['isCorrect'] ? '〇' : '✖'),
                                trailing: IconButton(
                                  icon: Icon(
                                    isFavorite ? Icons.favorite : Icons.favorite_border,
                                    color: isFavorite ? Colors.red : null,
                                  ),
                                  onPressed: () async {
                                    await _toggleFavorite(detail['quizId']);
                                    (context as Element).reassemble();
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _clearQuizHistory();
                      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                    },
                    child: Text('スタートに戻る'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class MyPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('マイページ')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('お気に入り確認'),
              onPressed: () {
                Navigator.pushNamed(context, '/favorites');
              },
            ),
            ElevatedButton(
              child: Text('ログイン/ログアウト'),
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ログイン')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'ユーザーID'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'パスワード'),
              obscureText: true,
            ),
            ElevatedButton(
              child: Text('ログイン'),
              onPressed: () {},
            ),
            TextButton(
              child: Text('ユーザーを作成していない人はこちら'),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('お気に入り')),
      body: FutureBuilder<List<String>>(
        future: _loadFavorites(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final favorites = snapshot.data!;
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(favorites[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<String>> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('favorites') ?? [];
  }
}
