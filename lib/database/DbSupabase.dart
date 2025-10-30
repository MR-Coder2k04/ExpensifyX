import 'dart:io';

import 'package:expense_manager_app/dataModel/expensemodel.dart';
import 'package:expense_manager_app/dataModel/walletModel.dart';
import 'package:expense_manager_app/database/DbSql.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class Dbsupabase {
  final user = Supabase.instance.client.auth.currentUser;

  Future<bool> addWalletToCloud({required Walletmodel temp}) async {
    if (user == null) {
      return false;
    } else {
      try {
        final res = await Supabase.instance.client.from("wallet_table").insert({
          "user_id": temp.userID,
          "wallet_id": temp.walletId,
          "wallet_name": temp.WalletName,
          "Amount": temp.Amount,
          "type": temp.type.toString(),
          "password": temp.password,
        });
        print("add to cloud");
        return true;
      } catch (error) {
        print(error);
        return false;
      }
    }
  }

  Future<List<Walletmodel>> getWalletFromClound() async {
    List<Walletmodel> temptemp = [];
    if (user != null) {
      try {
        final List<dynamic> res = await Supabase.instance.client
            .from("wallet_table")
            .select()
            .eq("user_id", user!.id);
        print(res);
        List<Walletmodel> temp = res
            .map(
              (current) => Walletmodel(
                WalletName: current["wallet_name"],
                Amount: current["Amount"],

                type: current["type"] == walletType.private
                    ? walletType.private
                    : walletType.public,
                Wallet: current["wallet_id"],
                givenuserID: current["user_id"],
                pass: current["password"],
              ),
            )
            .toList();
        print("from supabase file wallet list is $temp");
        return temp;
      } catch (error) {
        print("error can't get form cloud");
        return temptemp;
      }
    } else {
      print("user null");
      return temptemp;
    }
  }

  Future<void> deleteWalletClound(String walletid) async {
    if (user == null) {
      return;
    } else {
      try {
        final res = await Supabase.instance.client
            .from("wallet_table")
            .delete()
            .eq("wallet_id", walletid)
            .select();

        print("dataDeleted $res");
      } catch (error) {
        print("error form cloud");
        print(error);
        return;
      }
    }
  }

  Future<void> deletellWalletsClound(String userID) async {
    if (user == null) {
      return;
    } else {
      try {
        final res = await Supabase.instance.client
            .from("wallet_table")
            .delete()
            .eq("user_id", userID)
            .select();

        print("dataDeleted $res");
      } catch (error) {
        print("error form cloud");
        print(error);
        return;
      }
    }
  }

  Future<void> deleteallexpensesClound(String userID) async {
    if (user == null) {
      return;
    } else {
      try {
        final res = await Supabase.instance.client
            .from("expenseTablePrivate")
            .delete()
            .eq("userID", userID)
            .select();

        print("dataDeleted $res");
      } catch (error) {
        print("error form cloud");
        print(error);
        return;
      }
    }
  }

  Future<void> deleteallexpensesformwalletClound(String walletId) async {
    if (user == null) {
      return;
    } else {
      try {
        final res = await Supabase.instance.client
            .from("expenseTablePrivate")
            .delete()
            .eq("walletID", walletId)
            .select();

        print("dataDeleted $res");
      } catch (error) {
        print("error form cloud");
        print(error);
        return;
      }
    }
  }

  //upload image of expenses
  Future<String> uploadImagePrivate({required XFile image}) async {
    if (user == null) return "not uploaded";

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      final storagePath = '${user!.id}/$fileName';

      await Supabase.instance.client.storage
          .from("images")
          .upload(storagePath, File(image.path));

      print("upload completed");
      return storagePath;
    } catch (error) {
      print("Upload failed: $error");
      return "error";
    }
  }

  Future<void> addexpenseToCloud(Expensemodel temp) async {
    if (user == null) return;
    try {
      final res = await Supabase.instance.client
          .from("expenseTablePrivate")
          .insert({
            "userID": temp.userId,
            "walletID": temp.walletId,

            "expenseID": temp.expenseID,
            "expensename": temp.expensename,

            "expenseAmount": temp.Amount,

            "expensenote": temp.note1,
            "localimageadd": temp.ImageLocalAddress,
            "cloudimageadd": temp.ImageCloundAddress,
            "time": temp.addtime,
          });
      print("${temp.expensename} added to cloud  $res");
    } catch (error) {
      print(error);
    }
  }

  Future<List<Expensemodel>> getExpenseFromcloud(Walletmodel wallet) async {
    List<Expensemodel> temp = [];
    if (user == null) {
      return temp;
    } else {
      try {
        final List<dynamic> res = await Supabase.instance.client
            .from("expenseTablePrivate")
            .select()
            .eq("walletID", wallet.walletId)
            .eq("userID", wallet.userID);
        if (res.isEmpty) {
          return temp;
        }
        List<Expensemodel> temptemp = res
            .map(
              (e) => Expensemodel(
                expensename: e["expensename"],
                Amount: e["expenseAmount"],
                addtime: e["time"],
                walletId: e["walletID"],
                userId: e["userID"],
                expenseIDgiven: e["expenseID"],
                ImageCloundAddress: e["cloudimageadd"],
                ImageLocalAddress: e["localimageadd"],
                note1: e["expensenote"],
              ),
            )
            .toList();
        return temptemp;
      } catch (error) {
        print(error);
        return temp;
      }
    }
  }

  Future<Widget> getImage(Expensemodel temp) async {
    if (user == null) {
      return Text("login to access cloud");
    } else {
      try {
        final res = await Supabase.instance.client.storage
            .from("images")
            .download(
              temp.ImageCloundAddress,
              transform: TransformOptions(format: RequestImageFormat.origin),
            );
        final getdocdir = await getApplicationDocumentsDirectory();
        final Imagename = DateFormat.yMd().format(DateTime.now());
        final path = join(getdocdir.path, "${Imagename}.jpg");
        final imagefile = File(path);
        await imagefile.writeAsBytes(res);
        Dbsql().updateimage(temp, imagefile.path);
        return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Image.file(imagefile),
        );
      } catch (error) {
        return Text(error.toString());
      }
    }
  }

  void DeleteExpenseFromCloud(Expensemodel expense) async {
    if (user == null) {
      return;
    } else {
      try {
        final res = await Supabase.instance.client
            .from("expenseTablePrivate")
            .delete()
            .eq("expenseID", expense.expenseID);

        if (expense.ImageCloundAddress != "not uploaded") {
          final resimage = await Supabase.instance.client.storage
              .from("images")
              .remove([expense.ImageCloundAddress]);
        }
      } catch (e) {
        print("$e from cloud");
      }
    }
  }

  //add public wallet;
  Future<bool> addPublicWallet({
    required String id,
    required String password,
    required Function notificationtohomescreen,
  }) async {
    if (user == null) {
      return false;
    }
    print("running supabase public");

    final res = await Supabase.instance.client
        .from("wallet_table")
        .select("password, type")
        .eq("wallet_id", id)
        .maybeSingle();

    if (res == null) {
      return false;
    }

    final _cloudPassword = res["password"] as String?;
    final _cloudtype = res["type"] as String?;

    if (_cloudPassword == password &&
        _cloudtype == walletType.public.toString()) {
      try {
        final res2 = await Supabase.instance.client
            .from("wallet_table")
            .select()
            .eq("wallet_id", id);

        List<Walletmodel> temp = res2
            .map<Walletmodel>(
              (current) => Walletmodel(
                WalletName: current["wallet_name"].toString(),
                Amount: current["Amount"] as int,
                type: current["type"] == walletType.private.toString()
                    ? walletType.private
                    : walletType.public,
                Wallet: current["wallet_id"].toString(),
                givenuserID: current["user_id"].toString(),
                pass: current["password"]?.toString(),
              ),
            )
            .toList();

        final isadded = await Dbsql().addDataToWallet(temp[0]);
        await addWalletToCloud(temp: temp[0]);

        if (isadded) notificationtohomescreen();

        return true;
      } catch (error) {
        print("Error adding wallet: $error");
        return false;
      }
    } else {
      return false;
    }
  }

  Future<void> updateexpensename(String newname, String expId) async {
    if (user != null) {
      try {
        final res = await Supabase.instance.client
            .from("expenseTablePrivate")
            .update({"expensename": newname})
            .eq("expenseID", expId);
      } catch (e) {
        print("update expensename from supabase : $e");
      }
    }
  }

  Future<void> updateexpenseamount(int amount, String expId) async {
    if (user != null) {
      try {
        final res = await Supabase.instance.client
            .from("expenseTablePrivate")
            .update({"expenseAmount": amount})
            .eq("expenseID", expId);
      } catch (e) {
        print("update expensename from supabase : $e");
      }
    }
  }

  Future<void> updateexpensenote(String newnote, String expId) async {
    if (user != null) {
      try {
        final res = await Supabase.instance.client
            .from("expenseTablePrivate")
            .update({"expensenote": newnote})
            .eq("expenseID", expId);
      } catch (e) {
        print("update expensename from supabase : $e");
      }
    }
  }

  Future<void> updateexpensedate(String newdate, String expId) async {
    if (user != null) {
      try {
        final res = await Supabase.instance.client
            .from("expenseTablePrivate")
            .update({"time": newdate})
            .eq("expenseID", expId);
      } catch (e) {
        print("update expensename from supabase : $e");
      }
    }
  }

  Future<void> updatewalletname(String newname, String walletId) async {
    if (user != null) {
      try {
        final res = await Supabase.instance.client
            .from("wallet_table")
            .update({"wallet_name": newname})
            .eq("wallet_id", walletId)
            .select();
        print("edited name in clound");
      } catch (e) {
        print("update wallet from supabase : $e");
      }
    }
  }

  Future<void> updatewalletamount(int newamount, String walletId) async {
    if (user != null) {
      try {
        final res = await Supabase.instance.client
            .from("wallet_table")
            .update({"Amount": newamount})
            .eq("wallet_id", walletId);
      } catch (e) {
        print("update wallet from supabase : $e");
      }
    }
  }

  void getsharedmembername() {
    if (user == null) {
      return;
    }
  }

  Future<List<String>> getSharedWalletUsers(String walletId) async {
    try {
      final response = await Supabase.instance.client.rpc(
        'get_shared_wallet_users',
        params: {'p_wallet_id': walletId},
      );

      if (response is List) {
        // Convert response into List<String>
        return response.map((e) => e['username'] as String).toList();
      } else {
        return [];
      }
    } catch (error) {
      print("Error fetching shared wallet users: $error");
      return [];
    }
  }
}
