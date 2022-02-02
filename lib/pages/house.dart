import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/data/models.dart';
import 'package:myapp/pages/foodchart.dart';
import '../data/factory.dart';

class House extends StatefulWidget {
  final houses = [];

  House({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => HouseState();
}

class HouseState extends State<House> {
  String currentUser = '9003615571';
  final DataFactory factory = DataFactory();
  final houseNameController = TextEditingController();
  bool creating = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Houses')),
        body: Center(
            child: StreamBuilder<QuerySnapshot>(
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const LinearProgressIndicator();
                  return buildHouseList(context, snapshot.data?.docs ?? []);
                },
                stream: factory.getStream(currentUser))),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: Text(creating ? 'Creating...' : 'House name'),
                      content: creating
                          ? const LinearProgressIndicator()
                          : TextField(
                              controller: houseNameController,
                              decoration: const InputDecoration(
                                  hintText: "E.g Max's Casa")),
                      actions: [
                        TextButton(
                            onPressed: () async {
                              setState(() {
                                creating = true;
                              });
                              final newHouse = HouseItem(
                                  owner: FirebaseAuth
                                      .instance.currentUser!.phoneNumber
                                      .toString(),
                                  name: houseNameController.text,
                                  meals: []);
                              await factory.addHouse(newHouse);
                              setState(() {
                                creating = false;
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Create'))
                      ],
                    ));
          },
          child: const Icon(Icons.add_circle_outlined),
        ));
  }

  Widget buildHouseList(
      BuildContext context, List<DocumentSnapshot>? snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      // 2
      children:
          snapshot!.map((data) => buildHouseListItem(context, data)).toList(),
    );
  }

  Widget buildHouseListItem(BuildContext context, DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      final house = HouseItem.fromSnapshot(snapshot);
      return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => FoodChart(house: house)));
        },
        child: Container(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(house.name), const Icon(Icons.house)]),
        margin: const EdgeInsets.only(left: 20, right: 20),
        padding: const EdgeInsets.all(20),
        color: Colors.green,
      )
      );
    } else {
      return const Text('empty');
    }
  }
}
