import 'package:expense_manager_app/dataModel/walletModel.dart';
import 'package:expense_manager_app/database/DbSql.dart';
import 'package:expense_manager_app/database/DbSupabase.dart';
import 'package:flutter/material.dart';

class Editwallet extends StatelessWidget {
  Editwallet({
    super.key,
    required this.editingWallet,

    required this.getupdatedlist,
    required this.getupdateddata,
  });

  final void Function() getupdatedlist;
  final void Function() getupdateddata;
  //variable
  final Walletmodel editingWallet;

  String walletname = " ";
  int walletAmount = 0;
  final _formkey = GlobalKey<FormState>();

  void edit() async {
    final isvalid = _formkey.currentState!.validate();
    if (isvalid) {
      _formkey.currentState!.save();

      if (walletAmount != editingWallet.Amount) {
        final res = await Dbsql().editwalletamount(
          Amount: walletAmount,
          walletId: editingWallet.walletId,
        );
        final res2 = await Dbsupabase().updatewalletamount(
          walletAmount,
          editingWallet.walletId,
        );
        getupdateddata();
        getupdatedlist();
      }
      if (walletname != editingWallet.WalletName) {
        final res = await Dbsql().editwalletName(
          newname: walletname,
          walletId: editingWallet.walletId,
        );
        final res2 = await Dbsupabase().updatewalletname(
          walletname,
          editingWallet.walletId,
        );
        getupdatedlist();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user_wight = MediaQuery.of(context).size.width;
    final user_height = MediaQuery.of(context).size.height;

    return AlertDialog(
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
              initialValue: editingWallet.WalletName,
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
              onSaved: (newValue) => walletname = newValue!,
            ),

            TextFormField(
              initialValue: editingWallet.Amount.toString(),
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
              onSaved: (newValue) => walletAmount = int.parse(newValue!),
            ),
          ],
        ),
      ),
    );
  }
}
