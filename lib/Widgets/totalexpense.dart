import 'dart:ui';

import 'package:expense_manager_app/Widgets/addExpense.dart';
import 'package:expense_manager_app/dataModel/expensemodel.dart';
import 'package:expense_manager_app/dataModel/walletModel.dart';
import 'package:expense_manager_app/database/DbSql.dart';
import 'package:flutter/material.dart';

class Totalexpense extends StatefulWidget {
  Totalexpense({
    super.key,
    required this.wallet,

    required this.updateepxensedata,
    required this.updateexpenselist,
    required this.updatewalletlist,
  });
  final Walletmodel wallet;

  final void Function() updateexpenselist;
  final void Function() updateepxensedata;
  final void Function() updatewalletlist;

  @override
  State<Totalexpense> createState() => _TotalexpenseState();
}

class _TotalexpenseState extends State<Totalexpense> {
  int totalexpense = 0;
  List<Expensemodel> expenselist = [];
  double perentageTofill = 0;
  double percentagenottofill = 1;
  Future<void> getlist() async {
    final temp = await Dbsql().getexpensefromlocal(widget.wallet);
    int sum = 0;
    for (final e in temp) {
      sum += e.Amount;
    }

    final temp2 = sum / widget.wallet.Amount;

    setState(() {
      expenselist = temp;
      totalexpense = sum;
      perentageTofill = temp2;
      percentagenottofill = 1 - temp2;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getlist(); // refresh when screen loads / reappears
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final textScaler = MediaQuery.of(context).textScaler;
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.all(Radius.circular(12)),

      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(136, 255, 255, 255),
                    const Color.fromARGB(44, 255, 255, 255),
                  ],
                ),
              ),
            ),
          ),
          Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                flex: 2,
                child: FittedBox(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 3,
                        color: perentageTofill < 1
                            ? const Color.fromARGB(255, 0, 100, 240)
                            : const Color.fromARGB(41, 252, 2, 2),
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        bottomLeft: Radius.circular(50),
                      ),
                      gradient: perentageTofill < 1
                          ? LinearGradient(
                              colors: [
                                const Color.fromARGB(255, 0, 100, 240),

                                const Color.fromARGB(0, 251, 251, 251),
                              ],
                              stops: [perentageTofill, percentagenottofill],
                            )
                          : LinearGradient(
                              colors: [
                                const Color.fromARGB(255, 255, 0, 0),
                                const Color.fromARGB(74, 255, 0, 0),
                              ],
                            ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * .09,
                        vertical: 4,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Text(
                              "Total  ",
                              style: TextStyle(
                                fontSize: width * 0.11,
                                fontWeight: FontWeight.w700,
                              ),
                              textScaler: textScaler,
                            ),

                            Text(
                              totalexpense.toString(),
                              textScaler: textScaler,
                              style: TextStyle(fontSize: width * 0.11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Flexible(
                flex: 2,

                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => Addexpense(
                        wallet: widget.wallet,
                        updateepxensedata: widget.updateepxensedata,
                        updateexpenselist: widget.updateepxensedata,
                        updatewalletlist: widget.updatewalletlist,
                        updataTotal: (p0) {
                          setState(() {});
                        },
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 7, 94, 255),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),

                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.06,
                      vertical: 3,
                    ),

                    child: Text(
                      " Add 💵",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.09,
                        fontWeight: FontWeight.bold,
                      ),
                      textScaler: textScaler,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
