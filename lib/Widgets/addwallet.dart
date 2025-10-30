import 'package:expense_manager_app/Widgets/walletList.dart';
import 'package:expense_manager_app/dataModel/walletModel.dart';
import 'package:expense_manager_app/database/DbSql.dart';
import 'package:expense_manager_app/database/DbSupabase.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Addwdget extends StatefulWidget {
  const Addwdget({
    super.key,
    required this.addNotificationTohomescreen,
    required this.notitytoupdatedata,
  });

  // vairble
  final void Function() addNotificationTohomescreen;
  final void Function() notitytoupdatedata;

  @override
  State<Addwdget> createState() => _AddwdgetState();
}

class _AddwdgetState extends State<Addwdget> {
  //variable
  late String userid;
  bool _ispublic = false;
  late walletType type;
  final _formKey = GlobalKey<FormState>();
  String walletName = "";
  int Amount = 0;
  String? pass;
  //function

  //getuser
  Future<void> getuser() async {
    final user_id = Supabase.instance.client.auth.currentUser;
    if (user_id != null) {
      setState(() {
        userid = user_id.id;
      });
    } else {
      setState(() {
        userid = "Default";
      });
    }
  }

  //save
  void Save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await getuser();
      if (_ispublic == true) {
        type = walletType.public;
      }
      if (_ispublic == false) {
        type = walletType.private;
      }
      Walletmodel temp = Walletmodel(
        WalletName: walletName,
        Amount: Amount,
        type: type,
        givenuserID: userid,
        pass: pass,
      );

      final isadd = await Dbsql().addDataToWallet(temp);

      widget.addNotificationTohomescreen();
      widget.notitytoupdatedata();

      final res2 = await Dbsupabase().addWalletToCloud(temp: temp);

      if (!isadd) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Wrap(
              children: [Text("Somthing went wrong restart the app")],
            ),
          ),
        );
      }
    } else {
      return;
    }
  }

  //build
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shadowColor: const Color.fromARGB(255, 5, 46, 254),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.only(
          topRight: Radius.circular(60),
          bottomLeft: Radius.circular(60),
        ),
        side: BorderSide(color: const Color.fromARGB(255, 11, 43, 204)),
      ),
      surfaceTintColor: Theme.of(context).colorScheme.onPrimary,
      title: Text("ADD Wallet"),
      elevation: 50,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 28,
        color: Theme.of(context).colorScheme.primary,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          spacing: 10,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: "Wallet Name",
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
              onSaved: (newValue) => setState(() {
                walletName = newValue!;
              }),
            ),
            TextFormField(
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
              onSaved: (newValue) => setState(() {
                Amount = int.parse(newValue!);
              }),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Public",
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          "By default private",
                          style: TextStyle(fontSize: 12),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    Spacer(),
                    Switch(
                      value: _ispublic,
                      onChanged: (onchange) {
                        setState(() {
                          _ispublic = onchange;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (_ispublic)
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
                onSaved: (newValue) => setState(() {
                  pass = newValue;
                }),
              ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Back"),
        ),
        OutlinedButton(
          onPressed: () {
            Save();
            Navigator.of(context).pop();
          },
          child: Text("Save"),
        ),
      ],
      scrollable: true,
    );
  }
}
