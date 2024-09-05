import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _firstPlayerNameController = TextEditingController();
  final TextEditingController _secondPlayerNameController = TextEditingController();
  late AnimationController _timerController;
  late Animation<double> _timerAnimation;
  Color timerColor = Colors.blue;

  List<List<String>> board = [
    ['', '', ''],
    ['', '', ''],
    ['', '', '']
  ];

  String currentPlayer = 'X';
  String result = '';
  bool gameWon = false;
  List<List<int>> winningLine = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // Set up the AnimationController
    _timerController = AnimationController(
      duration: const Duration(seconds: 10), // Duration of the animation
      vsync: this,
    );

    // Define the Tween for the width
    _timerAnimation = Tween<double>(begin: 250.w, end: 0.0).animate(_timerController)
      ..addListener(() {
        setState(() {});
        if (_timerController.status == AnimationStatus.completed) {
          _stopTimer();
          _buildDialog(context);
        }
      });
    _timerController.addListener(() {
      print(_timerController.value);
      if (_timerAnimation.value > 168.w) {
        print('blue');
        timerColor = Colors.blue;
      } else if (_timerAnimation.value > 84.w) {
        print('orange');
        timerColor = Colors.orange;
      } else {
        print('red');
        timerColor = Colors.red;
      }
      setState(() {

      });
    });

    // Start the animation
    _timerController.forward();
  }

  void _resetTimer() {
    _timerController.reset();
    _timerController.forward();
  }

  void _stopTimer() {
    _timerController.stop();
  }

  void _resetGame() {
    setState(() {
      board = [
        ['', '', ''],
        ['', '', ''],
        ['', '', '']
      ];
      currentPlayer = 'X';
      result = '';
      gameWon = false;
      winningLine = [];
    });
    _resetTimer();
  }

  bool _checkWin(String player) {
    // Check rows
    for (int i = 0; i < 3; i++) {
      if (board[i][0] == player && board[i][1] == player && board[i][2] == player) {
        winningLine = [
          [i, 0],
          [i, 1],
          [i, 2]
        ];
        return true;
      }
    }

    // Check columns
    for (int i = 0; i < 3; i++) {
      if (board[0][i] == player && board[1][i] == player && board[2][i] == player) {
        winningLine = [
          [0, i],
          [1, i],
          [2, i]
        ];
        return true;
      }
    }

    // Check diagonals
    if (board[0][0] == player && board[1][1] == player && board[2][2] == player) {
      winningLine = [
        [0, 0],
        [1, 1],
        [2, 2]
      ];
      return true;
    }
    if (board[0][2] == player && board[1][1] == player && board[2][0] == player) {
      winningLine = [
        [0, 2],
        [1, 1],
        [2, 0]
      ];
      return true;
    }
    return false;
  }

  bool _isBoardFull() {
    for (var row in board) {
      for (var cell in row) {
        if (cell == '') {
          return false;
        }
      }
    }
    return true;
  }

  void _buildDialog(BuildContext context) {
    showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          content: _resultContent(),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetGame();
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  Text _resultContent() => Text(
        result.isNotEmpty
            ? result
            : 'Player ${currentPlayer == 'X' ? _secondPlayerNameController.text.isNotEmpty ? _secondPlayerNameController.text.isNotEmpty : 'Player 2' : _firstPlayerNameController.text.isNotEmpty ? _firstPlayerNameController.text : 'Player 1'} ${currentPlayer == 'X' ? 'O' : 'X'} wins!',
        style: const TextStyle(
          fontSize: 30,
          color: Colors.blue,
          fontWeight: FontWeight.w600,
        ),
      );

  void _makeMove(int row, int col, BuildContext context) {
    if (board[row][col] == '' && !gameWon) {
      setState(() {
        board[row][col] = currentPlayer;
        if (_checkWin(currentPlayer)) {
          result = 'Player ${currentPlayer == 'X' ? _firstPlayerNameController.text : _secondPlayerNameController.text} $currentPlayer wins!';
          _buildDialog(context);
          gameWon = true;
          // _resetGame();
        } else if (_isBoardFull()) {
          result = "It's a draw!";
          _buildDialog(context);
        } else if (_timerController.isCompleted) {
          result = 'Player ${currentPlayer == 'X' ? _firstPlayerNameController.text : _secondPlayerNameController.text} $currentPlayer wins!';
          _buildDialog(context);
          gameWon = true;
        } else {
          currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
        }
      });
    }
  }

  void _buildPlayerNameField(BuildContext context, bool isFirstPlayer) {
    showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          content: Column(
            children: [
              Material(
                child: TextField(
                  decoration: InputDecoration(
                    label: Text(isFirstPlayer ? 'First Player Name' : 'Second Player Name'),
                  ),
                  controller: isFirstPlayer ? _firstPlayerNameController : _secondPlayerNameController,
                ),
              ),
              TextButton(
                child: const Text('Save'),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _firstPlayerNameController.dispose();
    _secondPlayerNameController.dispose();
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double cellSize = 120;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
      ),
      drawer: const Drawer(),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 30.h,
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  children: List.generate(
                    9,
                    (item) {
                      int row = item ~/ 3;
                      int col = item % 3;
                      bool isWinningCell = winningLine.any((position) => position[0] == row && position[1] == col);
                      return GestureDetector(
                        onTap: () {
                          _makeMove(row, col, context);
                          _resetTimer();
                        },
                        child: Card(
                          color: isWinningCell ? Colors.blue : Colors.white,
                          child: Container(
                            width: 90.r,
                            height: 90.r,
                            alignment: Alignment.center,
                            // decoration: BoxDecoration(color: isWinningCell ? Colors.blue : Colors.white),
                            child: Text(
                              board[row][col],
                              style: TextStyle(
                                fontSize: 50.sp,
                                color: isWinningCell
                                    ? Colors.white
                                    : board[row][col] == 'X'
                                        ? Colors.green
                                        : Colors.redAccent,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Winning line painter
                // if (winningLine.isNotEmpty)
                //   CustomPaint(
                //     size: Size(cellSize * 3, cellSize * 3),
                //     painter: WinningLinePainter(winningLine: winningLine, cellSize: cellSize),
                //   ),
                // Result message
                // Align(
                //   alignment: Alignment.bottomCenter,
                //   child: Padding(
                //     padding: const EdgeInsets.all(20.0),
                //     child: Column(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         Text(
                //           result,
                //           style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                //         ),
                //         SizedBox(height: 20.0),
                //         ElevatedButton(
                //           onPressed: _resetGame,
                //           child: Text('Reset Game'),
                //         ),
                //       ],
                //     ),
                //   ),
                // )
              ],
            ),
            SizedBox(height: 5.h,),
            Card(
              child: Container(
                padding: const EdgeInsets.all(10).r,
                child: Row(
                  children: [
                    const Icon(Icons.timer),
                    SizedBox(width: 10.w),
                    // AnimatedBuilder(animation: _timerAnimation, builder: (BuildContext context) {}),
                    Container(
                      width: _timerAnimation.value,
                      height: 10.h,
                      decoration: BoxDecoration(
                        color: timerColor,
                        borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(10.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    _buildPlayerNameField(context, true);
                    if (gameWon) {
                      _stopTimer();
                    }
                  },
                  child: Card(
                    color: currentPlayer == 'X' ? Colors.lightBlueAccent : Colors.white,
                    child: Container(
                      padding: const EdgeInsets.all(20.0).r,
                      width: MediaQuery.sizeOf(context).width / 2 - 40.w,
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.green,
                            radius: 40.r,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            _firstPlayerNameController.text == '' ? 'Player 1' : _firstPlayerNameController.text,
                            style: TextStyle(fontSize: 20.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _buildPlayerNameField(context, false),
                  child: Card(
                    color: currentPlayer == 'O' ? Colors.lightBlueAccent : Colors.white,
                    child: Container(
                      padding: const EdgeInsets.all(20.0).r,
                      width: MediaQuery.sizeOf(context).width / 2 - 40.w,
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.green,
                            radius: 40.r,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            _secondPlayerNameController.text == '' ? 'Player 2' : _secondPlayerNameController.text,
                            style: TextStyle(fontSize: 20.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            CupertinoButton(
              color: CupertinoColors.destructiveRed,
              onPressed: _resetGame,
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
