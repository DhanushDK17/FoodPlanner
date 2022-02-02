import 'package:flutter/material.dart';

class MenuItem extends StatefulWidget {
  final dynamic mealitem;
  const MenuItem({Key? key, required this.mealitem}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MenuItemState();
}

class MenuItemState extends State<MenuItem> {
  String editing = '';
  String saveLoading = '';
  final myController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        DefaultTextStyle(
            child: Text(widget.mealitem['mealtime']),
            style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold)),
        saveLoading == widget.mealitem['mealtime']
            ? const CircularProgressIndicator()
            : Container(
                margin: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: const BorderRadius.all(Radius.circular(20))),
                child: Row(
                  children: [
                    editing == widget.mealitem['mealtime']
                        ? TextFormField(
                            controller: myController,
                            decoration:
                                const InputDecoration(hintText: 'dosa, idly'),
                            keyboardType: TextInputType.text,
                          )
                        : RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                                style: const TextStyle(color: Colors.black),
                                text: widget.mealitem['mealname'])),
                    IconButton(
                      iconSize: 20,
                      icon: editing == widget.mealitem['mealtime']
                          ? const Icon(Icons.save)
                          : const Icon(Icons.edit),
                      onPressed: () {
                        if (editing == widget.mealitem['mealtime']) {
                          widget.mealitem['mealname'] = myController.text;
                        } else {
                          myController.text = widget.mealitem['mealname'];
                          setState(() {
                            editing == ''
                                ? editing = widget.mealitem['mealtime']
                                : '';
                          });
                        }
                      },
                    )
                  ],
                ),
              ),
      ],
    );
  }
}
