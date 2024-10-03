import 'package:flutter/material.dart';
import 'dart:math';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<String> board = List.filled(9, '');
  String currentPlayer = 'X';
  String winner = '';
  bool isSinglePlayer = true;
  int scoreX = 0;
  int scoreO = 0;
  String playerNameX = 'Player X';
  String playerNameO = 'Player O';
  final Random _random = Random();

  void _resetGame() {
    setState(() {
      board = List.filled(9, '');
      currentPlayer = 'X';
      winner = '';
    });
  }

  void _resetAll() {
    setState(() {
      board = List.filled(9, '');
      currentPlayer = 'X';
      winner = '';
      scoreX = 0;
      scoreO = 0;
      playerNameX = 'Player X';
      playerNameO = 'Player O';
    });
  }

  void _makeMove(int index) {
    if (board[index].isEmpty && winner.isEmpty) {
      setState(() {
        board[index] = currentPlayer;
        _checkWinner();
        currentPlayer = currentPlayer == 'X' ? 'O' : 'X';

        if (isSinglePlayer && currentPlayer == 'O' && winner.isEmpty) {
          _makeAIMove();
        }
      });
    }
  }

  void _makeAIMove() {
    Future.delayed(const Duration(milliseconds: 500), () {
      List<int> availableMoves = [];
      for (int i = 0; i < board.length; i++) {
        if (board[i].isEmpty) {
          availableMoves.add(i);
        }
      }

      if (availableMoves.isNotEmpty) {
        int move = availableMoves[_random.nextInt(availableMoves.length)];
        _makeMove(move);
      }
    });
  }

  void _checkWinner() {
    List<List<int>> winningCombinations = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var combination in winningCombinations) {
      if (board[combination[0]] != '' &&
          board[combination[0]] == board[combination[1]] &&
          board[combination[1]] == board[combination[2]]) {
        setState(() {
          winner = board[combination[0]];
          if (winner == 'X') {
            scoreX++;
          } else if (winner == 'O') {
            scoreO++;
          }
        });
        _showEndDialog('Congratulations ${winner == 'X' ? playerNameX : playerNameO}, you win!');
        return;
      }
    }

    if (!board.contains('') && winner.isEmpty) {
      _showEndDialog('It\'s a Draw!');
    }
  }

  void _showEndDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  Future<void> _setPlayerNames() async {
    String? nameX = await _showInputDialog('Enter name for Player X', playerNameX);
    if (nameX != null && nameX.isNotEmpty) {
      setState(() {
        playerNameX = nameX;
      });
    }
    String? nameO = await _showInputDialog('Enter name for Player O', playerNameO);
    if (nameO != null && nameO.isNotEmpty) {
      setState(() {
        playerNameO = nameO;
      });
    }
  }

  Future<String?> _showInputDialog(String title, String currentValue) {
    TextEditingController controller = TextEditingController(text: currentValue);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        backgroundColor: const Color(0xFF121212),
        actions: [
          Switch(
            value: isSinglePlayer,
            onChanged: (value) {
              setState(() {
                isSinglePlayer = value;
                _resetAll();
              });
            },
            activeColor: Colors.tealAccent,
            inactiveThumbColor: Colors.purpleAccent,
            inactiveTrackColor: Colors.grey,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _setPlayerNames,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0D0D0D),
              const Color(0xFF1C1C1C),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      playerNameX,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$scoreX',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      playerNameO,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$scoreO',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              winner.isNotEmpty ? 'Winner: ${winner == 'X' ? playerNameX : playerNameO}' : 'Current Player: $currentPlayer',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.0,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _makeMove(index),
                    child: Container(
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBB86FC),
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          board[index],
                          style: const TextStyle(
                            fontSize: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetAll,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15), backgroundColor: const Color(0xFF03DAC5),
                elevation: 10,
                shadowColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Reset Game',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
