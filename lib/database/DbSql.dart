import 'package:expense_manager_app/dataModel/expensemodel.dart';
import 'package:expense_manager_app/dataModel/walletModel.dart';
import 'package:expense_manager_app/database/DbSupabase.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class Dbsql {
  Future<Database> opendb() async {
    final dir = await getDatabasesPath();
    final dbPath = join(dir, "expenseMangerDb.db");

    final db = openDatabase(
      dbPath,
      version: 1,
      onCreate: (Database db, int verion) async {
        await db.execute(""" Create Table wallet (
        walletName text ,
        Amount int ,
        walletId text primary key,
        userid text ,
        type text,
        password text null

        )""");

        await db.execute("""create Table expenseTable  
        (expensename text , 
        expenseamount INTEGER , 
        expensenote String , 
        expenseID String , 
        walletid string , 
        userId string , 
        date string , 
        localAdd string , 
        CloudAdd String)""");
      },
    );
    print("wallet db created");

    return db;
  }

  //add data to wallet table
  Future<bool> addDataToWallet(Walletmodel temp) async {
    final db = await opendb();

    if (!db.isOpen) {
      return false;
    }

    try {
      final res = await db.insert("wallet", {
        "walletName": temp.WalletName,
        "Amount": temp.Amount,
        "walletId": temp.walletId,
        "userid": temp.userID,
        "type": temp.type.toString(),
        "password": temp.password,
      });

      print("added wallet ${temp.WalletName}");
      return true;
    } catch (error) {
      print("wallet no added $error");
      return false;
    }
  }

  List<Walletmodel> covertDbDatatoWallet(List<Map<String, Object?>> temp) {
    List<Walletmodel> walletList = [];
    try {
      walletList = temp
          .map((current) {
            walletType type = walletType.private;
            if (current["type"] == walletType.public.toString()) {
              type = walletType.public;
            }
            return Walletmodel(
              WalletName: current["walletName"].toString(),
              Amount: current["Amount"] as int,
              type: type,

              Wallet: current["walletId"] as String,
              givenuserID: current["userid"] as String,
              pass: current["password"]?.toString(),
            );
          })
          .cast<Walletmodel>()
          .toList();
      return walletList;
    } catch (error) {
      print(error);
      return walletList;
    }
  }

  Future<List<Walletmodel>> getWalletFromSql() async {
    final db = await opendb();
    List<Walletmodel> cloudWallet = [];

    // Step 1: Fetch cloud data (if internet available)
    bool result = await InternetConnection().hasInternetAccess;
    if (result == true) {
      cloudWallet = await Dbsupabase().getWalletFromClound();
    }

    print("Wallet data from cloud $cloudWallet raw");

    // Step 2: Fetch local DB data
    final dbData = await db.query("wallet");
    final walletDbList = covertDbDatatoWallet(dbData);

    try {
      // Step 3: Add/Update missing cloud wallets into local DB
      for (var cloudW in cloudWallet) {
        final exists = walletDbList.any(
          (local) => local.walletId == cloudW.walletId,
        );

        if (!exists) {
          await addDataToWallet(cloudW);
        } else {
          // Optional: if you want cloud to override local details
          // await updateWallet(cloudW);
        }
      }

      // Step 4: Delete local wallets that are NOT in cloud
      final cloudIds = cloudWallet.map((w) => w.walletId).toSet();
      for (var localW in walletDbList) {
        if (!cloudIds.contains(localW.walletId)) {
          await db.delete(
            "wallet",
            where: "walletid = ?",
            whereArgs: [localW.walletId],
          );
        }
      }

      // Step 5: Fetch updated local DB after sync
      final updatedDbData = await db.query("wallet");
      final updatedWalletList = covertDbDatatoWallet(updatedDbData);

      print("wallets from sql after sync $updatedWalletList");
      return updatedWalletList;
    } catch (error) {
      print("Error while syncing wallets: $error");
      return [];
    }
  }

  Future<void> deletewallet(String walletid) async {
    final db = await opendb();
    try {
      final res = await db.delete(
        "wallet",
        where: "walletId =?",
        whereArgs: [walletid],
      );
    } catch (error) {
      print("error from sql");
      print(error);
      return;
    }
  }

  Future<void> deleteAllwallet(String userid) async {
    final db = await opendb();
    try {
      final res = await db.delete(
        "wallet",
        where: "userid = ? OR userid = ?",
        whereArgs: [userid, "default"],
      );
      print("$res rows deleted");
    } catch (error) {
      print("Error from SQL:");
      print(error);
    }
  }

  Future<void> addexpenseTowallet(Expensemodel temp) async {
    final db = await opendb();
    if (db.isOpen) {
      try {
        final res = await db.insert('expenseTable', {
          "expensename": temp.expensename,
          "expenseamount": temp.Amount,
          "expensenote": temp.note1,
          "expenseID": temp.expenseID,
          "walletid": temp.walletId,
          "userId": temp.userId,
          "date": temp.addtime,
          "localAdd": temp.ImageLocalAddress,
          "CloudAdd": temp.ImageCloundAddress,
        });
        print("${temp.expensename} added to sql db");
      } catch (error) {
        print(error);
      }
    }
  }

  Future<List<Expensemodel>> getexpensefromlocal(Walletmodel temp) async {
    final db = await opendb();
    try {
      // 1. Get local expenses
      final res = await db.rawQuery(
        'SELECT * FROM expenseTable WHERE walletid = ?',
        [temp.walletId],
      );

      List<Expensemodel> localExpenses = res
          .map(
            (e) => Expensemodel(
              expensename: e["expensename"].toString(),
              Amount: int.tryParse(e["expenseamount"].toString()) ?? 0,
              addtime: e["date"].toString(),
              walletId: e["walletid"].toString(),
              userId: e["userID"].toString(),
              expenseIDgiven: e["expenseID"].toString(),
              ImageCloundAddress: e["CloudAdd"].toString(),
              ImageLocalAddress: e["localAdd"].toString(),
              note1: e["expensenote"].toString(),
            ),
          )
          .toList();

      // 2. Always fetch cloud expenses
      final resCloud = await Dbsupabase().getExpenseFromcloud(temp);

      // Convert cloud list into a Map/Set for faster lookup
      final cloudIds = resCloud.map((e) => e.expenseID).toSet();

      // 3. Insert missing cloud expenses into local
      for (var cloudExpense in resCloud) {
        bool existsLocally = localExpenses.any(
          (local) => local.expenseID == cloudExpense.expenseID,
        );

        if (!existsLocally) {
          await addexpenseTowallet(cloudExpense);
          localExpenses.add(cloudExpense); // keep in sync in-memory
        }
      }

      // 4. Delete local expenses that are not in cloud
      for (var local in List<Expensemodel>.from(localExpenses)) {
        if (!cloudIds.contains(local.expenseID)) {
          await db.delete(
            'expenseTable',
            where: 'expenseID = ?',
            whereArgs: [local.expenseID],
          );
          localExpenses.remove(local);
        }
      }

      // 5. Return updated local list
      return localExpenses;
    } catch (error) {
      print("from sql while getting code $error");
      return [];
    }
  }

  Future<void> deleteExpenses(String walletid) async {
    final db = await opendb();
    try {
      final res = await db.delete(
        "expenseTable",
        where: "walletid =?",
        whereArgs: [walletid],
      );
    } catch (error) {
      print("error from sql");
      print(error);
      return;
    }
  }

  Future<void> deleteAllwalletexpense(String userid) async {
    final db = await opendb();
    try {
      final res = await db.delete(
        "expenseTable",
        where: "userId = ? OR userId = ?",
        whereArgs: [userid, "default"],
      );

      print("$res rows deleted");
    } catch (error) {
      print("Error from SQL:");
      print(error);
    }
  }

  //update image
  Future<bool> updateimage(Expensemodel temp, String newadd) async {
    final db = await opendb();
    if (db.isOpen) {
      try {
        db.update(
          "expenseTable",
          {"localAdd": newadd},
          where: "expenseID =?",
          whereArgs: [temp.expenseID],
        );
        return true;
      } catch (error) {
        print("$error will upadating imgae");
        return false;
      }
    } else {
      return false;
    }
  }

  void deleteexpense(String expeseid) async {
    final db = await opendb();
    if (db.isOpen) {
      try {
        db.delete(
          "expenseTable",
          where: "expenseID = ?",
          whereArgs: [expeseid],
        );
      } catch (e) {
        print(e);
      }
    }
  }

  Future<int> getTotalExpenseDb(String walletID) async {
    final db = await opendb();
    if (db.isOpen) {
      final res = await db.rawQuery(
        '''
      SELECT SUM(expenseamount) as total
      FROM expenseTable
      WHERE walletID = ?
      ''',
        [walletID],
      );

      // Extract result safely
      final total = res.first['total'] as int?;
      return total ?? 0; // return 0 if null
    }
    return 0; // if DB is not open
  }

  Future<void> wipedata() async {
    final db = await opendb();

    if (db.isOpen) {
      // Close the database before deleting

      // Get the path
      final dir = await getDatabasesPath();
      final dbPath = join(dir, "expenseMangerDb.db");

      // Delete the database file
      await deleteDatabase(dbPath);
      print("Database deleted successfully!");
    }
  }

  //total amount;
  Future<List<int>> walletamountallocated() async {
    int totalallocated = 0;
    int totalspend = 0;
    final db = await opendb();
    try {
      final res = await db.rawQuery(
        """Select sum(Amount) as total from wallet""",
      );
      totalallocated = res.first["total"] as int? ?? 0;
      print("total amount allocated $totalallocated");
    } catch (error) {}
    try {
      final res2 = await db.rawQuery(
        """Select sum(expenseamount) as total2 from expenseTable""",
      );
      totalspend = res2.first["total2"] as int? ?? 0;
      print("total amount allocated $totalspend");
    } catch (error) {}

    int saved = totalallocated - totalspend;
    print("data form main function $totalallocated , $totalspend , $saved");

    return [totalallocated, totalspend, saved];
  }

  Future<void> editExpenseName({
    required String newname,
    required String expenseId,
  }) async {
    final db = await opendb();
    try {
      await db.rawUpdate(
        "UPDATE expenseTable SET expensename = ? WHERE ExpenseID = ?",
        [newname, expenseId],
      );
      print("Expense name updated successfully");
    } catch (e) {
      print("Error updating expense name: $e");
    }
  }

  Future<void> editExpenseNote({
    required String newnote,
    required String expenseId,
  }) async {
    final db = await opendb();
    try {
      await db.rawUpdate(
        "UPDATE expenseTable SET expensenote = ? WHERE ExpenseID = ?",
        [newnote, expenseId],
      );
      print("Expense name updated successfully");
    } catch (e) {
      print("Error updating expense name: $e");
    }
  }

  Future<void> editamount({
    required int neamount,
    required String expenseId,
  }) async {
    final db = await opendb();
    try {
      await db.rawUpdate(
        "UPDATE expenseTable SET expenseamount = ? WHERE ExpenseID = ?",
        [neamount, expenseId],
      );
      print("Expense name updated successfully");
    } catch (e) {
      print("Error updating expense name: $e");
    }
  }

  Future<void> editdate({
    required String newdate,
    required String expenseId,
  }) async {
    final db = await opendb();
    try {
      await db.rawUpdate(
        "UPDATE expenseTable SET date = ? WHERE ExpenseID = ?",
        [newdate, expenseId],
      );
      print("Expense name updated successfully");
    } catch (e) {
      print("Error updating expense name: $e");
    }
  }

  Future<void> editwalletName({
    required String newname,
    required String walletId,
  }) async {
    final db = await opendb();
    try {
      await db.rawUpdate(
        "UPDATE Wallet SET walletName = ? WHERE walletID = ?",
        [newname, walletId],
      );
      print("Expense name updated successfully");
    } catch (e) {
      print("Error updating walletname  name: $e");
    }
  }

  Future<void> editwalletamount({
    required int Amount,
    required String walletId,
  }) async {
    final db = await opendb();
    try {
      await db.rawUpdate("UPDATE Wallet SET Amount = ? WHERE walletID = ?", [
        Amount,
        walletId,
      ]);
      print("Expense name updated successfully");
    } catch (e) {
      print("Error updating walletname  name: $e");
    }
  }
}
