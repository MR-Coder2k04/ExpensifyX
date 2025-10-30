import 'package:expense_manager_app/dataModel/expensemodel.dart';
import 'package:expense_manager_app/dataModel/walletModel.dart';
import 'package:expense_manager_app/database/DbSql.dart';
import 'package:expense_manager_app/database/DbSupabase.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/intl.dart';

class Editexpense extends StatelessWidget {
  Editexpense({super.key, required this.editingexpense})
    : expensedate = editingexpense.addtime;
  //variable
  Expensemodel editingexpense;

  String expensename = " ";
  int expenseAmount = 0;
  String expensedate = ' ';
  String expensenote = '';
  final _formkey = GlobalKey<FormState>();

  void edit() async {
    final isvalid = _formkey.currentState!.validate();
    if (isvalid) {
      _formkey.currentState!.save();

      final netavail = await InternetConnection().hasInternetAccess;

      if (expensename != editingexpense.expensename) {
        await Dbsql().editExpenseName(
          newname: expensename,
          expenseId: editingexpense.expenseID,
        );
        await Dbsupabase().updateexpensename(
          expensename,
          editingexpense.expenseID,
        );
      }
      if (expenseAmount != editingexpense.Amount) {
        await Dbsql().editamount(
          neamount: expenseAmount,
          expenseId: editingexpense.expenseID,
        );
        await Dbsupabase().updateexpenseamount(
          expenseAmount,
          editingexpense.expenseID,
        );
      }
      if (expensenote != editingexpense.note1) {
        await Dbsql().editExpenseNote(
          newnote: expensenote,
          expenseId: editingexpense.expenseID,
        );
        await Dbsupabase().updateexpensenote(
          expensenote,
          editingexpense.expenseID,
        );
      }
      if (expensedate != editingexpense.addtime) {
        await Dbsql().editdate(
          newdate: expensedate,
          expenseId: editingexpense.addtime,
        );
        await Dbsupabase().updateexpensedate(
          expensedate,
          editingexpense.addtime,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user_wight = MediaQuery.of(context).size.width;
    final user_height = MediaQuery.of(context).size.height;

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
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Back"),
          ),
          ElevatedButton(
            onPressed: () {
              edit();
            },
            child: Text("Save"),
          ),
        ],
        scrollable: true,
        title: Text(
          "WALLET EDIT",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: user_wight * 0.14,
          ),
        ),
        content: Form(
          key: _formkey,
          child: Column(
            spacing: 20,
            children: [
              TextFormField(
                initialValue: editingexpense.expensename,
                decoration: InputDecoration(
                  labelText: "Name",
                  filled: true,
                  fillColor: const Color.fromARGB(255, 255, 255, 255),
                  border: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty || value.length < 4) {
                    return "Invalid Entry";
                  } else {
                    return null;
                  }
                },
                onSaved: (newValue) => expensename = newValue!,
              ),

              TextFormField(
                initialValue: editingexpense.Amount.toString(),
                decoration: InputDecoration(
                  labelText: "Amount",
                  filled: true,
                  fillColor: const Color.fromARGB(255, 255, 255, 255),
                  border: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty || int.tryParse(value) == null) {
                    return "Invalid Entry";
                  } else {
                    return null;
                  }
                },
                onSaved: (newValue) => expenseAmount = int.parse(newValue!),
              ),

              InkWell(
                onTap: () {
                  showDatePicker(
                    context: context,
                    firstDate: DateTime(DateTime.now().year - 10),
                    lastDate: DateTime(DateTime.now().year + 10),
                  ).then(
                    (value) => setState(() {
                      expensedate = DateFormat.yMd().format(value!);
                    }),
                  );
                },
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 60,
                    ),
                    child: Text(
                      expensedate,
                      softWrap: false,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),

              TextFormField(
                initialValue: editingexpense.note1.toString(),
                decoration: InputDecoration(
                  labelText: "NOTE",
                  filled: true,
                  fillColor: const Color.fromARGB(255, 255, 255, 255),
                  border: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                validator: (value) {},
                onSaved: (newValue) => expensenote = newValue!,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
