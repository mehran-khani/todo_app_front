import 'package:flutter/material.dart';

enum TaskListColor {
  red,
  orange,
  yellow,
  green,
  defaultColor,
  lightBlue,
  purple,
  redAccent,
  purpleAccent,
  brown,
  grey,
  pink,
}

extension TaskListColorExtension on TaskListColor {
  Color get color {
    switch (this) {
      case TaskListColor.red:
        return Colors.red;
      case TaskListColor.orange:
        return Colors.orange;
      case TaskListColor.yellow:
        return const Color.fromARGB(255, 249, 228, 42);
      case TaskListColor.green:
        return Colors.green;
      case TaskListColor.defaultColor:
        return Colors.blue;
      case TaskListColor.lightBlue:
        return Colors.lightBlue;
      case TaskListColor.purple:
        return Colors.purple;
      case TaskListColor.redAccent:
        return Colors.redAccent;
      case TaskListColor.purpleAccent:
        return Colors.purpleAccent;
      case TaskListColor.brown:
        return Colors.brown;
      case TaskListColor.grey:
        return Colors.grey;
      case TaskListColor.pink:
        return Colors.pink;
      default:
        return Colors.blue; // Default color
    }
  }
}
