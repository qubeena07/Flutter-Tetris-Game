import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tetris_game/widgets/piece.dart';
import 'package:tetris_game/widgets/pixels.dart';

import '../constants/values.dart';

//create game board
List<List<Tetromino?>> gameBoard = List.generate(
    colLength, (index) => List.generate(rowLength, (index2) => null));

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  Piece currentPiece = Piece(type: Tetromino.J);
  int currentScore = 0;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    currentPiece.initializePiece();
    Duration frameRate = const Duration(milliseconds: 600);
    gameLoop(frameRate);
  }

  void gameLoop(Duration frameRate) {
    Timer.periodic(frameRate, (timer) {
      setState(() {
        //clear lines
        clearLine();
        //check landing
        checkLanding();
        if (gameOver == true) {
          timer.cancel();
        }

        //move current piece down
        currentPiece.movePiece(Direction.down);
      });
    });
  }

  void showGameOverDialof() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Game Over"),
              content: Text("Your score is $currentScore"),
              actions: [
                TextButton(onPressed: () {}, child: const Text("Play again"))
              ],
            ));
  }

  void resetGame() {
    gameBoard = List.generate(
        colLength, (index) => List.generate(rowLength, (j) => null));
    gameOver = false;
    currentScore = 0;

    createNewPiece();
    startGame();
  }

  //check for collision
  // true for collision and false for non collision
  bool checkCollision(Direction direction) {
    for (int i = 0; i < currentPiece.position.length; i++) {
      //calculate row and column of current position
      int row = (currentPiece.position[i] / rowLength).floor();
      int col = currentPiece.position[i] % rowLength;

      // adjust the row and col based on the direction

      if (direction == Direction.left) {
        col -= 1;
      } else if (direction == Direction.right) {
        col += 1;
      } else if (direction == Direction.down) {
        row += 1;
      }

      //check if the piece is out of bounds
      if (row >= colLength || col < 0 || col >= rowLength) {
        return true;
      } else if (col > 0 && row > 0 && gameBoard[row][col] != null) {
        return true;
      }
    }
    //if no collision are detected --false

    return false;
  }

  void checkLanding() {
    //if going down is occupied
    if (checkCollision(Direction.down)) {
      for (int i = 0; i < currentPiece.position.length; i++) {
        int row = (currentPiece.position[i] / rowLength).floor();
        int col = currentPiece.position[i] % rowLength;
        if (row >= 0 && col >= 0) {
          gameBoard[row][col] = currentPiece.type;
        }
      }
      //create a new piece once landed
      createNewPiece();
    }
  }

  void createNewPiece() {
    //create a random tetromino types

    Random rand = Random();

    //create a new piecr with random types

// Get all values of the Tetromino enum
    List<Tetromino> allTetrominos = Tetromino.values;

    // Generate a random index within the valid range
    int randomIndex = rand.nextInt(allTetrominos.length);

    // Get the tetromino type at the random index
    Tetromino randomType = allTetrominos[randomIndex];
    currentPiece = Piece(type: randomType);
    currentPiece.initializePiece();

    if (isGameOver()) {
      gameOver = true;
    }
  }

  void clearLine() {
    for (int row = colLength - 1; row >= 0; row--) {
      bool rowIsFull = true;

      for (int col = 0; col < rowLength; col++) {
        if (gameBoard[row][col] == null) {
          rowIsFull = false;
          break;
        }
      }
      if (rowIsFull) {
        for (int r = row; r > 0; r--) {
          gameBoard[r] = List.from(gameBoard[r - 1]);
        }
        gameBoard[0] = List.generate(row, (index) => null);

        currentScore++;
      }
    }
  }

  bool isGameOver() {
    for (int col = 0; col < rowLength; col++) {
      if (gameBoard[0][col] != null) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: rowLength),
                itemCount: rowLength * colLength,
                itemBuilder: (context, index) {
                  int row = (index / rowLength).floor();
                  int col = index % rowLength;
                  if (currentPiece.position.contains(index)) {
                    return Pixel(color: currentPiece.color, text: '');
                  } else if (gameBoard[row][col] != null) {
                    final Tetromino? tetrominoType = gameBoard[row][col];
                    return Pixel(
                        color: tetrominoColors[tetrominoType] ?? Colors.white,
                        text: '');
                  } else {
                    return const Pixel(
                        color: Color.fromARGB(255, 116, 116, 116), text: '');
                  }
                }),
          ),
          Text(
            'Score : ${currentScore.toString()}',
            style: const TextStyle(fontSize: 15, color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    onPressed: moveLeft,
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    )),
                IconButton(
                    onPressed: rotatePiece,
                    icon: const Icon(Icons.rotate_right, color: Colors.white)),
                IconButton(
                    onPressed: moveRight,
                    icon:
                        const Icon(Icons.arrow_back_ios, color: Colors.white)),
              ],
            ),
          )
        ],
      ),
    );
  }

  void moveLeft() {
    if (!checkCollision(Direction.left)) {
      setState(() {
        currentPiece.movePiece(Direction.left);
      });
    }
  }

  void moveRight() {
    if (!checkCollision(Direction.right)) {
      setState(() {
        currentPiece.movePiece(Direction.right);
      });
    }
  }

  void rotatePiece() {
    setState(() {
      currentPiece.rotatePiece();
    });
  }
}
