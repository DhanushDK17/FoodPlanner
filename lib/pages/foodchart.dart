import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:myapp/data/factory.dart';
import 'package:myapp/data/models.dart';
import 'package:myapp/pages/menu_item.dart';
import 'package:myapp/types/meal_for_a_day.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'siginusingphone.dart';

class FoodChart extends StatefulWidget {
  const FoodChart({Key? key, required this.house}) : super(key: key);
  final HouseItem house;
  @override
  State<FoodChart> createState() => _FoodChartState();
}

class _FoodChartState extends State<FoodChart> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  int currentUser = 9003615571;
  final myController = TextEditingController();
  bool loading = false;
  String editing = '';
  String saveLoading = '';
  bool createLoading = false;
  final mealTimeController = TextEditingController();
  final mealNameController = TextEditingController();
  bool creatingMeal = false;
  DateTime newMealTime = DateTime.now();
  var meals2 = [];
  DataFactory factory = DataFactory();

  Future addMealPlanForADay(dynamic meal) {
    CollectionReference mealPlan =
        FirebaseFirestore.instance.collection('meals');
    return mealPlan.doc(currentUser.toString()).set({
      getDate(_focusedDay): [
        {'mealname': meal['mealname'], 'mealtime': meal['mealtime']},
      ]
    });
  }

  Future getMealsForTheDay() async {
    try {
      loading = true;
      final response = await FirebaseFirestore.instance
          .collection('meals')
          .doc(currentUser.toString())
          .get();
      if (response.data()!.isNotEmpty) {
        meals2 = response.get(getDate(_focusedDay));
      }
      return meals2;
    } catch (error) {
      rethrow;
    } finally {
      loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food plan'),
        actions: [
          IconButton(
              onPressed: () => {
                    FirebaseAuth.instance.signOut().then((value) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignInUsingPhone()));
                    })
                  },
              icon: const Icon(Icons.settings_power_outlined))
        ],
      ),
      body: Center(
          child: FutureBuilder(
            future: factory.getMeals(widget.house.referenceId!, getDate(_focusedDay)),
            builder: (context, snapshot) => 
              Column(
        children: <Widget>[
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            startingDayOfWeek: StartingDayOfWeek.monday,
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) {
              return [];
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  return events.isEmpty
                      ? const Text('')
                      : Positioned(
                          bottom: 7,
                          right: 7,
                          child: SizedBox(
                            child: Text(events.length.toString(),
                                style: const TextStyle(color: Colors.black)),
                          ),
                        );
                },
                selectedBuilder: (context, day, focusedDay) => Container(
                    margin: const EdgeInsets.all(5.0),
                    alignment: Alignment.center,
                    color: Theme.of(context).primaryColor,
                    child: Text(
                      day.day.toString(),
                      style: const TextStyle(color: Colors.white),
                    ))),
            onPageChanged: (focusedDay) {},
          ),
          Expanded(
              flex: 1,
              child: ListView.builder(
                  itemCount: meals2.length,
                  itemBuilder: (context, index) =>
                      MenuItem(mealitem: meals2[index]))),
          Visibility(
            child: const CircularProgressIndicator(),
            visible: createLoading,
          ),
          Visibility(
              visible: creatingMeal && !createLoading,
              child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(children: [
                    Flexible(
                        flex: 3,
                        child: TextFormField(
                          controller: mealTimeController,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(10)),
                        )),
                    Flexible(
                        flex: 3,
                        child: Container(
                            margin: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                            child: TextFormField(
                                controller: mealNameController,
                                decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.all(10))))),
                    Flexible(
                        flex: 1,
                        child: IconButton(
                            onPressed: () {}, icon: const Icon(Icons.save)))
                  ]))),
        ],
      ))),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: const Text('Create Meal'),
                      content: createLoading
                          ? const LinearProgressIndicator()
                          : SizedBox(
                              child: Column(children: [
                                TextField(
                                    controller: mealNameController,
                                    decoration: const InputDecoration(
                                        hintText: "E.g Max's Casa")),
                                Container(
                                  child: GestureDetector(
                                      onTap: () => showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay(
                                              hour: newMealTime.hour,
                                              minute: newMealTime.minute)),
                                      child: Text(DateFormat('dd-MM-yyy HH:MM')
                                          .format(newMealTime))),
                                  margin: const EdgeInsets.only(top: 20),
                                )
                              ]),
                              height: 200,
                            ),
                      actions: [
                        TextButton(onPressed: () {
                          factory.addMeal(widget.house.referenceId!, Meal(food: mealNameController.text, owner: FirebaseAuth.instance.currentUser!.phoneNumber.toString(), time: Timestamp.now(), name: 'Brunch'));
                        }, child: const Text('Add'))
                      ],
                    ));
          },
          child: const Icon(Icons.add_circle_outline)),
    );
  }

  String getDate(DateTime day) {
    return DateFormat('dd-MM-yyy').format(day);
  }
}
