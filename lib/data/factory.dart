import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './models.dart';

class DataFactory {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('houses');

  Stream<QuerySnapshot> getStream(String user) {
    return collection
        .where('owner', isEqualTo: auth.currentUser!.phoneNumber.toString())
        .snapshots();
  }

  Future getHousesCreatedByUser(String user) async {
    return await collection
        .where('owner', isEqualTo: user)
        .get()
        .then((value) => value.docs);
  }

  Future<DocumentReference> addHouse(HouseItem house) {
    return collection.add(house.toJson());
  }

  void updateHouse(HouseItem house) async {
    await collection.doc(house.referenceId).update(house.toJson());
  }

  void deleteHouse(HouseItem house) async {
    await collection.doc(house.referenceId).delete();
  }

  Future<List<Meal>> getMeals(String documentReferenceId, String date) async {
    try {
      final document = await collection.doc(documentReferenceId).get();
      final meals = document.get('meals');
      final mealObjects = meals.where((Meal meal) => meal.time.toDate().toString() == date);
      print(mealObjects);
      // print(mealObjects);
      return document.get('meals');
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future addMeal(String documentReferece, Meal meal) async {
    final document = await collection.doc(documentReferece).get();
    List<dynamic> oldMeals = document.get('meals');
    oldMeals.add(meal.toJson());
    HouseItem newHouseDoc = HouseItem(
        owner: document.get('owner'),
        name: document.get('name'),
        meals: oldMeals);
    return await collection.doc(documentReferece).set(newHouseDoc.toJson());
  }
}
