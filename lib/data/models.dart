import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HouseItem {
  final String owner;
  final String name;
  final List meals;
  String? referenceId;
  HouseItem(
      {Key? key,
      this.referenceId,
      required this.owner,
      required this.name,
      required this.meals});

  factory HouseItem.fromJson(Map<String, dynamic> json) {
    return HouseItem(
        owner: json['owner'], name: json['name'], meals: json['meals']);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'meals': meals, 'owner': owner, 'name': name};
  }

  factory HouseItem.fromSnapshot(DocumentSnapshot snapshot) {
    final newHouseItem =
        HouseItem.fromJson(snapshot.data() as Map<String, dynamic>);
    newHouseItem.referenceId = snapshot.reference.id;
    return newHouseItem;
  }

  @override
  String toString() => 'House <$name>';
}

class Meal {
  Timestamp time;
  final String name;
  final String owner;
  final String food;

  Meal(
      {Key? key,
      required this.time,
      required this.name,
      required this.owner,
      required this.food});
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
        name: json['name'],
        time: json['time'],
        owner: json['owner'],
        food: json['food']);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'time': time,
      'owner': owner,
      'food': food
    };
  }

  @override
  String toString() => 'Meal <$name>';
}
