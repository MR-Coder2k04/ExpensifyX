import 'package:expense_manager_app/database/DbSql.dart';
import 'package:expense_manager_app/database/DbSupabase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Publicwallet extends StatelessWidget {
  Publicwallet({super.key, required this.notificationtohome});

  //variable
  String expenseid = " ";
  String password = " ";
  final _formkey = GlobalKey<FormState>();
  final void Function() notificationtohome;

  //save
  void _save() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      print(password);
      print(expenseid);
      await Dbsupabase().addPublicWallet(
        id: expenseid,
        password: password,
        notificationtohomescreen: notificationtohome,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        shadowColor: const Color.fromARGB(255, 5, 46, 254),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.only(
            topRight: Radius.circular(60),
            bottomLeft: Radius.circular(60),
          ),
          side: BorderSide(color: const Color.fromARGB(255, 11, 43, 204)),
        ),
        scrollable: true,
        actions: [
          OutlinedButton(
            onPressed: () {
              _save();
            },
            child: Text("Add Wallet"),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Close"),
          ),
        ],
        title: Text(
          "Add Public wallet",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        content: Form(
          key: _formkey,
          child: Column(
            spacing: 20,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Expense ID",
                  filled: true,
                  fillColor: const Color.fromARGB(255, 255, 255, 255),
                  border: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty || value.length < 10) {
                    return "Invalid Entry";
                  } else {
                    return null;
                  }
                },
                onSaved: (newValue) => setState(() => expenseid = newValue!),
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Password",
                  filled: true,
                  fillColor: const Color.fromARGB(255, 255, 255, 255),
                  border: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty || value.length < 7) {
                    return "Invalid Entry";
                  } else {
                    return null;
                  }
                },
                onSaved: (newValue) => setState(() => password = newValue!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
