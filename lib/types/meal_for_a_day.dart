import 'package:flutter/material.dart';
import 'package:myapp/types/meal_menu.dart';

class MealForADay {
  MealMenu mealmenu = MealMenu(name: 'name', meals: []);
  String date = '';

  MealForADay({Key? key, required this.date, required this.mealmenu});

  getMealMenu() {
    return mealmenu;
  }

  getDate() {
    return date;
  }
}
