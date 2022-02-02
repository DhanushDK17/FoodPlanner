import 'package:flutter/material.dart';

class Meal {
  String mealname = '';
  String mealtime = '';
  bool edit = false;
  Meal({Key? key, required this.mealname, required this.mealtime, required this.edit});
}
