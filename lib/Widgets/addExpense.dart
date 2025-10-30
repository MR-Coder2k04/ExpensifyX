import 'dart:ffi';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:expense_manager_app/dataModel/expensemodel.dart';
import 'package:expense_manager_app/dataModel/walletModel.dart';
import 'package:expense_manager_app/database/DbSql.dart';
import 'package:expense_manager_app/database/DbSupabase.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Addexpense extends StatefulWidget {
  Addexpense({
    super.key,
    required this.wallet,

    required this.updataTotal,

    required this.updateepxensedata,
    required this.updateexpenselist,
    required this.updatewalletlist,
  });

  final Walletmodel wallet;
  final void Function(int) updataTotal;

  final void Function() updateexpenselist;
  final void Function() updateepxensedata;
  final void Function() updatewalletlist;

  @override
  State<Addexpense> createState() => _AddexpenseState();
}

class _AddexpenseState extends State<Addexpense> {
  late final formatter;
  final _Formkey = GlobalKey<FormState>();

  //variable
  bool isimagetaken = false;
  String date = DateFormat.yMd().format(DateTime.now());
  late String userid;
  late XFile imagetaken;
  late String ExpenseName;
  late int ExpenseAmount;
  String ExpenseNote = " not available";

  //function
  Future<String> saveImage(XFile takenimage) async {
    try {
      final document_dir = await getApplicationDocumentsDirectory();

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final pathforImage = join(document_dir.path, "$timestamp.jpg");
      await File(takenimage.path).copy(pathforImage);
      return pathforImage;
    } catch (error) {
      print("whille saving error $error");
      return error.toString();
    }
  }

  //get image from camera

  Future<bool> takePhtotofromcamera(BuildContext context) async {
    XFile? imagefile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (imagefile == null) {
      return false;
    } else {
      setState(() {
        imagetaken = imagefile;
      });
      return true;
    }
  }

  //get image from gallery

  Future<bool> takePhtotofromgallery(BuildContext context) async {
    XFile? imagefile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (imagefile == null) {
      return false;
    } else {
      setState(() {
        imagetaken = imagefile;
      });
      return true;
    }
  }

  //save
  void _save() async {
    String imagepathlocal = "not uploaded";
    String imageclound = "not uploaded";

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      userid = "Default";
    } else {
      userid = user.id;
    }

    final issaved = _Formkey.currentState!.validate();
    if (issaved) {
      print(isimagetaken);
      if (isimagetaken) {
        imagepathlocal = await saveImage(imagetaken);
        print("image saved to location in phone is $imagepathlocal");
        imageclound = await Dbsupabase().uploadImagePrivate(image: imagetaken);
        print(imageclound);
      }
      _Formkey.currentState!.save();

      Expensemodel temp = Expensemodel(
        expensename: ExpenseName,
        Amount: ExpenseAmount,
        addtime: date,
        note1: ExpenseNote,
        ImageLocalAddress: imagepathlocal,
        ImageCloundAddress: imageclound,
        walletId: widget.wallet.walletId.toString(),
        userId: userid,
      );

      await Dbsql().addexpenseTowallet(temp);
      await Dbsupabase().addexpenseToCloud(temp);
      widget.updateepxensedata();
      widget.updataTotal;
      widget.updateexpenselist();
      widget.updatewalletlist();
    } else {
      return;
    }
  }

  //build

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

        title: Center(child: Text("ADD Expense")),
        alignment: Alignment.center,
        elevation: 50,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 28,
          color: Theme.of(context).colorScheme.primary,
        ),
        content: Form(
          key: _Formkey,
          child: Column(
            spacing: 10,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Expense Name",
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
                onSaved: (value) => ExpenseName = value!,
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
                onSaved: (value) => ExpenseAmount = int.parse(value!),
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Note",
                  filled: true,
                  fillColor: const Color.fromARGB(255, 255, 255, 255),
                  border: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                validator: (value) {},

                onSaved: (newValue) {
                  if (newValue!.isEmpty) {
                    return;
                  } else {
                    ExpenseNote = newValue;
                  }
                },
              ),
              InkWell(
                onTap: () {
                  showDatePicker(
                    context: context,
                    firstDate: DateTime(DateTime.now().year - 10),
                    lastDate: DateTime(DateTime.now().year + 10),
                  ).then(
                    (value) => setState(() {
                      date = DateFormat.yMd().format(value!);
                    }),
                  );
                },
                child: Card(
                  color: Theme.of(context).colorScheme.secondary,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 60,
                    ),
                    child: FittedBox(
                      child: Text(
                        date,
                        softWrap: false,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  takePhtotofromcamera(context);
                },
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: isimagetaken
                      ? Image.file(File(imagetaken.path))
                      : Text("Add Image"),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      // if (await _isSetOfPermissionGive()) {
                      final bool = await takePhtotofromcamera(context);
                      if (bool) {
                        setState(() {
                          isimagetaken = true;
                        });
                      }
                      //}
                    },
                    child: FittedBox(child: Text("Camera")),
                  ),

                  OutlinedButton(
                    onPressed: () async {
                      // if (await _isSetOfPermissionGive()) {
                      final bool = await takePhtotofromgallery(context);
                      if (bool) {
                        setState(() {
                          isimagetaken = true;
                        });
                      }
                      //   }
                    },
                    child: FittedBox(child: Text("photos")),
                  ),
                ],
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
              _save();
            },
            child: Text("Save"),
          ),
        ],
        scrollable: true,
      ),
    );
  }
}
