import 'package:flutter/material.dart';
import 'package:myapp/types/meal.dart';

class MealMenu {
  String name = '';
  List<Meal> meals = [];

  MealMenu({Key? key, required this.name, required this.meals});

  getMeals() {
    return meals;
  }

  getName() {
    return name;
  }
}
