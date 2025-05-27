import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نشرة البلوت',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        fontFamily: 'Arial',
      ),
      home: const BalootScoreScreen(),
    );
  }
}

class BalootScoreScreen extends StatefulWidget {
  const BalootScoreScreen({super.key});

  @override
  State<BalootScoreScreen> createState() => _BalootScoreScreenState();
}

class _BalootScoreScreenState extends State<BalootScoreScreen> {
  int teamUs = 0;
  int teamThem = 0;
  final _usController = TextEditingController();
  final _themController = TextEditingController();
  final _teamUsNameController = TextEditingController(text: 'لنا');
  final _teamThemNameController = TextEditingController(text: 'لهم');

  List<int> historyUs = [];
  List<int> historyThem = [];

  final List<String> dealers = ['أمام', 'يسار', 'خلف', 'يمين'];
  int currentDealerIndex = 0;

  @override
  void dispose() {
    _usController.dispose();
    _themController.dispose();
    _teamUsNameController.dispose();
    _teamThemNameController.dispose();
    super.dispose();
  }

  void _addPoints() {
    final usPoints = int.tryParse(_usController.text) ?? 0;
    final themPoints = int.tryParse(_themController.text) ?? 0;

    setState(() {
      teamUs += usPoints;
      teamThem += themPoints;
      historyUs.add(usPoints);
      historyThem.add(themPoints);
      _usController.clear();
      _themController.clear();
      currentDealerIndex = (currentDealerIndex + 1) % dealers.length;
      _checkWinner();
    });
  }

  void _undoLast() {
    if (historyUs.isNotEmpty && historyThem.isNotEmpty) {
      setState(() {
        teamUs -= historyUs.removeLast();
        teamThem -= historyThem.removeLast();
        currentDealerIndex = (currentDealerIndex - 1 + dealers.length) % dealers.length;
      });
    }
  }

  void _checkWinner() {
    bool usReached = teamUs >= 152;
    bool themReached = teamThem >= 152;

    if (usReached && themReached) {
      if (teamUs == teamThem) {
        return; // لا فائز إذا كان تعادل
      } else if (teamUs > teamThem) {
        _showWinnerDialog(_teamUsNameController.text);
      } else {
        _showWinnerDialog(_teamThemNameController.text);
      }
    } else if (usReached) {
      _showWinnerDialog(_teamUsNameController.text);
    } else if (themReached) {
      _showWinnerDialog(_teamThemNameController.text);
    }
  }

  void _showWinnerDialog(String winner) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الفائز'),
        content: Text('فاز فريق $winner'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                teamUs = 0;
                teamThem = 0;
                historyUs.clear();
                historyThem.clear();
                currentDealerIndex = 0;
              });
              Navigator.of(context).pop();
            },
            child: const Text('ابدأ جولة جديدة'),
          ),
        ],
      ),
    );
  }

  void _resetManually() {
    setState(() {
      teamUs = 0;
      teamThem = 0;
      historyUs.clear();
      historyThem.clear();
      currentDealerIndex = 0;
    });
  }

  String _getDealerSymbol(String direction) {
    switch (direction) {
      case 'أمام':
        return '⬆️';
      case 'يسار':
        return '⬅️';
      case 'خلف':
        return '⬇️';
      case 'يمين':
        return '➡️';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentDealerSymbol = _getDealerSymbol(dealers[currentDealerIndex]);

    return Scaffold(
      appBar: AppBar(title: const Text('نشرة البلوت')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  currentDealerIndex = (currentDealerIndex + 1) % dealers.length;
                });
              },
              child: Text(
                'الموزع: $currentDealerSymbol',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _teamUsNameController,
                    decoration: const InputDecoration(labelText: 'اسم الفريق الأول'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _teamThemNameController,
                    decoration: const InputDecoration(labelText: 'اسم الفريق الثاني'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: Text('${_teamUsNameController.text}: $teamUs', style: const TextStyle(fontSize: 24))),
                Expanded(child: Text('${_teamThemNameController.text}: $teamThem', style: const TextStyle(fontSize: 24))),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _usController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'نقاط الفريق الأول'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _themController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'نقاط الفريق الثاني'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addPoints,
              child: const Text('إضافة النقاط'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _undoLast,
              child: const Text('تراجع عن آخر تسجيلة'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: _resetManually,
              child: const Text('كرها', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('سجل ${_teamUsNameController.text}:', style: const TextStyle(fontSize: 20)),
                        const SizedBox(height: 10),
                        ...historyUs.map((points) => Text('+$points')).toList(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('سجل ${_teamThemNameController.text}:', style: const TextStyle(fontSize: 20)),
                        const SizedBox(height: 10),
                        ...historyThem.map((points) => Text('+$points')).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
