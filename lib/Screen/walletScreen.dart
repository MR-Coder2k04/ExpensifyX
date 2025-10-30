import 'package:expense_manager_app/Widgets/expenselist.dart';
import 'package:expense_manager_app/Widgets/totalexpense.dart';
import 'package:expense_manager_app/dataModel/walletModel.dart';
import 'package:expense_manager_app/database/DbSql.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class Walletscreen extends StatefulWidget {
  Walletscreen({
    super.key,

    required this.Walletofthiscard,

    required this.updateepxensedata,

    required this.updatewalletlist,
  }) : futureexenselist = Dbsql().getexpensefromlocal(Walletofthiscard);

  final void Function() updateepxensedata;
  final void Function() updatewalletlist;
  final Walletmodel Walletofthiscard;
  var futureexenselist;

  @override
  State<Walletscreen> createState() => _WalletscreenState();
}

class _WalletscreenState extends State<Walletscreen> {
  int totalExpenese = 0;

  void updateexpenselist() {
    setState(() {
      widget.futureexenselist = Dbsql().getexpensefromlocal(
        widget.Walletofthiscard,
      );
    });
  }

  void updateamount(int amount) {
    totalExpenese = amount + totalExpenese;
  }

  @override
  Widget build(BuildContext context) {
    final deviceScale = MediaQuery.of(context).textScaler;
    final user_width = MediaQuery.of(context).size.width;
    final user_hieght = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: Totalexpense(
          updateexpenselist: updateexpenselist,
          wallet: widget.Walletofthiscard,
          updateepxensedata: widget.updateepxensedata,
          updatewalletlist: widget.updatewalletlist,
        ),
      ),

      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            clipBehavior: Clip.antiAlias,
            pinned: true,
            foregroundColor: const Color.fromARGB(255, 254, 255, 255),

            backgroundColor: const Color.fromARGB(255, 3, 52, 251),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            actions: [
              PopupMenuButton(
                shadowColor: Colors.transparent,
                color: Colors.transparent,
                icon: Icon(Icons.menu_rounded),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      child: ElevatedButton(
                        onPressed: () async {
                          await Dbsql().deleteExpenses(
                            widget.Walletofthiscard.walletId,
                          );
                        },
                        child: Text("Delete all "),
                      ),
                    ),
                    PopupMenuItem(
                      child: ElevatedButton(
                        onPressed: () async {
                          updateexpenselist();
                        },
                        child: Text("Refresh"),
                      ),
                    ),
                  ];
                },
              ),
            ],

            floating: true,
            expandedHeight: user_hieght * 0.3,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) => FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Container(
                  padding: EdgeInsets.only(bottom: 40, right: 10, left: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 6, 41, 244),
                        const Color.fromARGB(208, 1, 63, 248),
                        const Color.fromARGB(224, 3, 47, 180),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FittedBox(
                          child: Text(
                            widget.Walletofthiscard.WalletName.toUpperCase(),
                            style: TextStyle(
                              fontSize: user_width * 0.13,
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color.fromARGB(
                                  255,
                                  255,
                                  255,
                                  255,
                                ).withOpacity(0.8),
                                const Color.fromARGB(
                                  255,
                                  255,
                                  255,
                                  255,
                                ).withOpacity(0.3),
                              ],
                            ),

                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(40),
                              right: Radius.circular(40),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Amount : ${widget.Walletofthiscard.Amount.toString()}",
                                style: TextStyle(fontSize: user_width * 0.04),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // title:
            ),
          ),
          Expenselist(
            futureList: widget.futureexenselist,
            updatewalletlist: widget.updatewalletlist,
            updateexpenselist: updateexpenselist,
            updateepxensedata: widget.updateepxensedata,
            wallet: widget.Walletofthiscard,
            updataTotal: updateamount,
          ),
          SliverFillRemaining(),
        ],
      ),
    );
  }
}
