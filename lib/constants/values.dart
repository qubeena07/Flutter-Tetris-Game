import 'package:flutter/material.dart';

enum Direction { left, right, down }

enum Tetromino { L, J, I, O, S, Z, T }

int rowLength = 10;
int colLength = 15;

const Map<Tetromino, Color> tetrominoColors = {
  Tetromino.L: Colors.blueAccent,
  Tetromino.J: Colors.amberAccent,
  Tetromino.I: Colors.cyanAccent,
  Tetromino.O: Colors.deepOrangeAccent,
  Tetromino.S: Colors.pinkAccent,
  Tetromino.Z: Colors.greenAccent,
  Tetromino.T: Colors.indigoAccent,
};
