import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:expense_manager_app/Screen/startUpScreen.dart';
import 'package:expense_manager_app/Widgets/addwallet.dart';
import 'package:expense_manager_app/Widgets/publicwallet.dart';
import 'package:expense_manager_app/Widgets/walletList.dart';
import 'package:expense_manager_app/database/DbSql.dart';
import 'package:expense_manager_app/database/DbSupabase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class homeScreen extends StatefulWidget {
  //construtor
  const homeScreen({super.key});
  //vairble

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {
  //variable

  User? currentUser = Supabase.instance.client.auth.currentUser;

  var walletList = Dbsql().getWalletFromSql();
  bool add = false;
  bool Scrooledup = false;
  int headingFlex = 2;
  int walletlistflex = 1;
  int Saved = 0;
  var futureWalletList = Dbsql().walletamountallocated();

  //fuction addnotification

  //permission handler
  void _isSetOfPermissionGive() async {
    bool isstroge = false;
    final cameraPermission = await Permission.camera.request();
    if (Platform.isAndroid) {
      final Adinfo = await DeviceInfoPlugin().androidInfo;
      final androidverion = Adinfo.version.release;
      if (int.parse(androidverion) >= 13) {
        final storagepermission = await Permission.storage.request();
        if (storagepermission.isGranted) {
          isstroge = true;
        }
      } else {
        final storagepermission = await Permission.manageExternalStorage
            .request();
      }
    }
  }

  @override
  void initState() {
    _isSetOfPermissionGive();

    super.initState();
  }

  void getupdateddata() {
    setState(() {
      futureWalletList = Dbsql().walletamountallocated();
    });
  }

  void getupdatelist() {
    print("updated list");
    setState(() {
      walletList = Dbsql().getWalletFromSql();
    });
  }

  Widget textmessage(int? saving) {
    List<String> zero = [
      "You saved… absolutely nothing. A true minimalist!",

      "0 savings — you’re living life on expert mode.",

      "Your wallet’s tighter than my jeans after lockdown.",
    ];

    List<String> overzero = [
      "Look at you, money magician — making savings appear!",
      "Savings above zero — you’re officially richer than yesterday.",
      "Careful, your wallet might get a six-pack from all this saving.",
    ];
    List<String> belowZero = [
      "“Congratulations! You’ve unlocked the premium ‘Debt’ DLC.”",
      "“Savings below zero — even gravity can’t pull your money back.”",
      "“You didn’t break the bank… you robbed yourself.”",
    ];

    final int rand = Random().nextInt(2);
    if (saving! > 0) {
      return Text(
        overzero[rand],
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      );
    }
    if (saving < 0) {
      return Text(
        belowZero[rand],
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      );
    }
    if (saving == 0) {
      return Text(
        zero[rand],
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      );
    } else {
      return Text(
        "TRACK. SAVE. SUCEED.",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      );
    }
  }

  //build
  @override
  Widget build(BuildContext context) {
    double user_width = MediaQuery.of(context).size.width;
    double user_height = MediaQuery.of(context).size.height;
    TextScaler deviceScale = MediaQuery.of(context).textScaler;
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: add == false
            ? Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 37, 118, 239),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(12),
                      side: BorderSide(width: 2, color: Colors.white),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      add = !add;
                    });
                  },
                  label: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    child: Text(
                      " ADD WALLET",
                      textScaler: deviceScale,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  icon: Icon(Icons.add_box_outlined, color: Colors.white),
                  iconAlignment: IconAlignment.start,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FittedBox(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          37,
                          118,
                          239,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.only(
                            bottomLeft: Radius.circular(120),
                            topLeft: Radius.circular(120),
                          ),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          add = !add;
                        });
                        if (currentUser != null) {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                Publicwallet(notificationtohome: getupdatelist),
                          );
                        }
                        if (currentUser == null) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shadowColor: const Color.fromARGB(
                                255,
                                5,
                                46,
                                254,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.only(
                                  topRight: Radius.circular(60),
                                  bottomLeft: Radius.circular(60),
                                ),
                                side: BorderSide(
                                  color: const Color.fromARGB(255, 11, 43, 204),
                                ),
                              ),

                              title: Center(child: Text("STOP")),
                              alignment: Alignment.center,
                              elevation: 50,
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Close"),
                                ),
                              ],
                              content: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(77, 0, 0, 0),
                                  borderRadius: BorderRadius.circular(20),
                                ),

                                child: Text(
                                  "Login to use this feature.",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      label: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 1,
                          vertical: 6,
                        ),
                        child: Text(
                          "Existing ",
                          textScaler: deviceScale,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      icon: Icon(Icons.add_box_outlined, color: Colors.white),
                      iconAlignment: IconAlignment.start,
                    ),
                  ),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 37, 118, 239),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.only(
                          bottomRight: Radius.circular(120),
                          topRight: Radius.circular(120),
                        ),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        add = !add;
                      });

                      showDialog(
                        context: context,
                        builder: (context) => Addwdget(
                          addNotificationTohomescreen: getupdatelist,
                          notitytoupdatedata: getupdateddata,
                        ),
                      );
                    },
                    label: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: FittedBox(
                        child: Text(
                          "New",
                          textScaler: deviceScale,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    icon: Icon(Icons.add_box_outlined, color: Colors.white),
                    iconAlignment: IconAlignment.start,
                  ),
                ],
              ),
      ),

      body: CustomScrollView(
        physics: BouncingScrollPhysics(
          decelerationRate: ScrollDecelerationRate.fast,
        ),
        clipBehavior: Clip.hardEdge,
        slivers: [
          SliverAppBar(
            foregroundColor: Colors.white,
            actions: [
              PopupMenuButton(
                shadowColor: Colors.transparent,
                color: Colors.transparent,
                enableFeedback: true,

                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      child: ElevatedButton(
                        onPressed: () {
                          try {
                            Supabase.instance.client.auth.signOut(
                              scope: SignOutScope.global,
                            );

                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => StartUpScreen(),
                              ),
                            );
                          } catch (error) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text("$error")));
                            return;
                          }
                        },
                        child: Text("Log out"),
                      ),
                    ),
                    // PopupMenuItem(
                    //   child: ElevatedButton(
                    //     onPressed: () async {
                    //       await Dbsql().wipedata();
                    //     },
                    //     child: Text("Wipe all"),
                    //   ),
                    // ),
                  ];
                },
              ),
            ],
            expandedHeight: user_height * 0.5,
            surfaceTintColor: Colors.white,
            automaticallyImplyLeading: false,

            //backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(100),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 12, 47, 245),
                      const Color.fromARGB(208, 12, 47, 245),
                      const Color.fromARGB(164, 2, 61, 238),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 40,
                        left: 20,
                        right: 20,
                      ),
                      child: FittedBox(
                        child: currentUser != null
                            ? Text(
                                "HI!  \n${currentUser!.userMetadata?["username"]}"
                                    .toUpperCase(),
                                softWrap: false,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontSize: user_width * 0.2,
                                  height: 0.95,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text(
                                "HI! \nFriend".toUpperCase(),
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontSize: user_width * 0.2,
                                  height: 0.95,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    Spacer(),
                    FutureBuilder(
                      future: futureWalletList,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final data = snapshot.data;
                        print(" data is ${data![0]} , ${data[1]} , ${data[2]}");
                        Saved = data![2];
                        return Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Column(
                            children: [
                              Row(
                                spacing: 10,
                                children: [
                                  Container(
                                    width: user_width * 0.3,
                                    padding: EdgeInsets.all(2),

                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        bottomLeft: Radius.circular(30),
                                      ),
                                      color: const Color.fromARGB(
                                        89,
                                        255,
                                        255,
                                        255,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        FittedBox(
                                          child: Text(
                                            " 💵 Total",
                                            style: TextStyle(
                                              fontSize: user_width * 0.06,
                                            ),
                                          ),
                                        ),
                                        Divider(
                                          thickness: 2,
                                          color: const Color.fromARGB(
                                            255,
                                            255,
                                            254,
                                            254,
                                          ),
                                        ),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(
                                            data![0].toString(),
                                            style: TextStyle(
                                              fontSize: user_width * 0.08,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: user_width * 0.3,
                                    padding: EdgeInsets.all(2),

                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        89,
                                        255,
                                        255,
                                        255,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        FittedBox(
                                          child: Text(
                                            " 💸 Spend",
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: user_width * 0.06,
                                            ),
                                          ),
                                        ),
                                        Divider(
                                          thickness: 2,
                                          color: const Color.fromARGB(
                                            255,
                                            255,
                                            255,
                                            255,
                                          ),
                                        ),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(
                                            data[1].toString(),
                                            style: TextStyle(
                                              fontSize: user_width * 0.08,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: user_width * 0.3,
                                    padding: EdgeInsets.all(2),

                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(30),
                                        bottomRight: Radius.circular(30),
                                      ),
                                      color: const Color.fromARGB(
                                        89,
                                        255,
                                        255,
                                        255,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        FittedBox(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            child: Text(
                                              "💰Saved",
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: user_width * 0.06,
                                              ),
                                            ),
                                          ),
                                        ),

                                        Divider(
                                          thickness: 2,
                                          color: const Color.fromARGB(
                                            255,
                                            255,
                                            255,
                                            255,
                                          ),
                                        ),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(
                                            data[2].toString(),
                                            style: TextStyle(
                                              fontSize: user_width * 0.08,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: user_height * 0.01),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 10,
                                  ),
                                  child: textmessage(data[2]),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverAppBar(
            actions: [
              PopupMenuButton<String>(
                style: ButtonStyle(alignment: Alignment.center),
                surfaceTintColor: Colors.blueAccent,
                elevation: 20,
                enableFeedback: true,
                shadowColor: const Color.fromARGB(255, 9, 122, 214),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(40),
                ),
                onSelected: (value) async {
                  if (value == "delete") {
                    if (currentUser == null) {
                      await Dbsql().deleteAllwallet("Default");
                      await Dbsql().deleteAllwalletexpense("Default");
                      getupdatelist();
                      getupdateddata();
                    } else {
                      print(currentUser!.id);
                      await Dbsql().deleteAllwallet(currentUser!.id);
                      await Dbsql().deleteAllwalletexpense(currentUser!.id);
                      await Dbsupabase().deletellWalletsClound(currentUser!.id);
                      await Dbsupabase().deleteallexpensesClound(
                        currentUser!.id,
                      );
                      getupdatelist();
                      getupdateddata();
                    }
                  } else if (value == "refresh") {
                    getupdatelist();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: "delete",
                    child: Text("Delete All Wallets"),
                  ),
                  const PopupMenuItem(value: "refresh", child: Text("Refresh")),
                ],
              ),
            ],
            automaticallyImplyLeading: false,
            expandedHeight: user_height * .04,
            pinned: true,
            surfaceTintColor: const Color.fromARGB(255, 255, 255, 255),
            elevation: 10,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              title: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  "Wallet",
                  style: TextStyle(
                    fontSize: user_width * 0.1,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          Walletlist(
            walletListFuture: walletList,
            getupdatedlist: getupdatelist,
            getupdateddata: getupdateddata,
          ),
          SliverFillRemaining(
            child: Center(
              child: Container(
                padding: EdgeInsets.all(40),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(50),
                    bottomLeft: Radius.circular(50),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 12, 81, 241),
                      const Color.fromARGB(255, 32, 83, 238),
                    ],
                  ),
                ),
                child: Text(
                  "Created by MR.Sociopath",
                  style: TextStyle(
                    fontSize: user_width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
