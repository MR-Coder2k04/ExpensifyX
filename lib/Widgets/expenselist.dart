import 'dart:io';
import 'dart:ui';

import 'package:expense_manager_app/Widgets/editexpense.dart';
import 'package:expense_manager_app/dataModel/expensemodel.dart';
import 'package:expense_manager_app/dataModel/walletModel.dart';
import 'package:expense_manager_app/database/DbSql.dart';
import 'package:expense_manager_app/database/DbSupabase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Expenselist extends StatefulWidget {
  Expenselist({
    super.key,
    required this.wallet,
    required this.updataTotal,
    required this.futureList,
    required this.updateepxensedata,
    required this.updateexpenselist,
    required this.updatewalletlist,
  });
  final Walletmodel wallet;
  final void Function(int) updataTotal;
  Future<List<Expensemodel>> futureList;
  final void Function() updateexpenselist;
  final void Function() updateepxensedata;
  final void Function() updatewalletlist;

  @override
  State<Expenselist> createState() => _ExpenselistState();
}

class _ExpenselistState extends State<Expenselist> {
  // image
  late Widget image;
  bool closed = true;
  void closepopup() {
    setState(() {
      closed = true;
    });
  }

  // get current image
  Future<Widget> getCurrentImage(Expensemodel temp) async {
    if (temp.ImageLocalAddress != "not uploaded") {
      try {
        return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Image.file(File(temp.ImageLocalAddress)),
        );
      } catch (error) {
        return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: await Dbsupabase().getImage(temp),
        );
      }
    } else {
      return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: const Center(child: Text("Not Available")),
      );
    }
  }

  void imagecrroect(Expensemodel temp) async {
    image = await getCurrentImage(temp);
  }

  Widget infocard(String heading, String toshow) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color.fromARGB(180, 255, 255, 255),
      ),
      child: Column(
        children: [
          Text(
            heading,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 12, 1, 64),
            ),
          ),
          const Divider(thickness: 1, color: Colors.black),
          Text(
            toshow,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // on tap
  void ontapcard(Expensemodel temp) async {
    imagecrroect(temp);
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shadowColor: const Color.fromARGB(255, 5, 46, 254),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.only(
              topRight: Radius.circular(60),
              bottomLeft: Radius.circular(60),
            ),
            side: BorderSide(color: const Color.fromARGB(255, 11, 43, 204)),
          ),

          scrollable: true,

          actionsAlignment: MainAxisAlignment.center,

          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("close"),
            ),
          ],
          title: const Text(
            "more about Expense",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 11, 3, 161),
            ),
          ),
          content: Column(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              infocard("Expense ID", temp.expenseID),
              infocard("Expense Name", temp.expensename),
              infocard("Amount", temp.Amount.toString()),
              infocard("Note", temp.note1),
              infocard("Created", temp.addtime),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Image",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Divider(color: Colors.black, thickness: 1),
                    image,
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textscaler = MediaQuery.of(context).textScaler;
    final userwidth = MediaQuery.of(context).size.width;

    return FutureBuilder(
      future: widget.futureList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Column(
                children: [SizedBox(height: 50), CircularProgressIndicator()],
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return const SliverToBoxAdapter(
            child: Center(child: Text("Error has occured")),
          );
        }
        if (snapshot.data!.isEmpty || !snapshot.hasData) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Column(
                children: [SizedBox(height: 40), Text("No Expense Available")],
              ),
            ),
          );
        }
        final expenselist = snapshot.data!;

        return SliverList.builder(
          itemCount: expenselist.length,
          itemBuilder: (context, index) {
            final currentexpense = expenselist[index];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: InkWell(
                splashColor: Theme.of(context).colorScheme.onPrimary,
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        Editexpense(editingexpense: currentexpense),
                  );
                },
                onTap: () {
                  ontapcard(currentexpense);
                },
                child: Dismissible(
                  onDismissed: (direction) {
                    Dbsql().deleteexpense(currentexpense.expenseID);
                    Dbsupabase().DeleteExpenseFromCloud(currentexpense);
                    widget.updateepxensedata();
                    widget.updataTotal;
                    widget.updateexpenselist();
                    widget.updatewalletlist();
                  },
                  key: Key(currentexpense.expenseID),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Colors.blue, width: 3),
                    ),
                    clipBehavior: Clip.antiAlias, // ensures blur stays inside
                    child:
                        // 🔹 Card content
                        Column(
                          children: [
                            Container(
                              height: 20,
                              width: double.maxFinite,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 0, 92, 252),
                                    Color.fromARGB(115, 9, 76, 191),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(
                              thickness: 2,
                              height: 0,
                              color: Colors.black,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        spacing: 0,
                                        children: [
                                          Text(
                                            currentexpense.expensename,
                                            textScaler: textscaler,
                                            style: TextStyle(
                                              fontSize: userwidth * 0.045,
                                              fontWeight: FontWeight.bold,
                                              color: const Color.fromARGB(
                                                255,
                                                17,
                                                17,
                                                17,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                            95,
                                            0,
                                            0,
                                            0,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          currentexpense.addtime,
                                          textScaler: textscaler,
                                          style: TextStyle(
                                            fontSize: userwidth * 0.03,
                                            fontWeight: FontWeight.w700,
                                            color: const Color.fromARGB(
                                              255,
                                              0,
                                              0,
                                              0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      Text(
                                        "₹",
                                        textScaler: textscaler,
                                        style: TextStyle(
                                          fontSize: userwidth * 0.09,
                                          fontWeight: FontWeight.bold,
                                          color: const Color.fromARGB(
                                            255,
                                            2,
                                            126,
                                            43,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        currentexpense.Amount.toString(),
                                        textScaler: textscaler,
                                        style: TextStyle(
                                          fontSize: userwidth * 0.09,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
