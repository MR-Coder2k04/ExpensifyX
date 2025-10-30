import 'package:expense_manager_app/Screen/homeScreen.dart';
import 'package:expense_manager_app/Widgets/elevatedButtomCustom.dart';
import 'package:expense_manager_app/Widgets/loginWidget.dart';
import 'package:expense_manager_app/Widgets/signupWidget.dart';
import 'package:expense_manager_app/database/DbSql.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lottie/lottie.dart';

class StartUpScreen extends StatefulWidget {
  //constructor
  const StartUpScreen({super.key});

  @override
  State<StartUpScreen> createState() => _StartUpScreenState();
}

class _StartUpScreenState extends State<StartUpScreen> {
  //varible----------------------------------------

  //toggle varible
  bool _startapp = false;
  bool _isSigning = false;
  bool _isLogin = false;
  int heading_flex = 3;
  int button_Flex = 1;
  Color container = Colors.transparent;

  //variable heading

  Widget heading = Text("TRACK.\nSAVE.\nSUCEED.", textAlign: TextAlign.left);
  double headingSize = 1;

  // fuction --------------------------------------------------
  //back fuction ------------
  void back() {
    setState(() {
      _isSigning = false;
      _isLogin = false;
    });
  }

  //function keyboard open-

  void keyboardOpenFixHeading() {
    final _isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom;

    if (_isKeyboardOpen > 0.0) {
      setState(() {
        headingSize = 0.1;
        heading = Text("TRACK. SAVE. SUCEED.", textAlign: TextAlign.left);
      });
    } else {
      setState(() {
        heading = Text("TRACK.\nSAVE.\nSUCEED.", textAlign: TextAlign.left);
        headingSize = 0.24;
      });
    }
  }

  //function build
  @override
  Widget build(BuildContext context) {
    keyboardOpenFixHeading();
    Widget InsideContiner = Column(
      key: ValueKey("MENU"),
      spacing: 12,
      children: [
        ElevatedbuttomCustom(
          text: "Sign In",
          ontap: () {
            setState(() {
              _isSigning = true;
              _isLogin = false;
              _startapp = true;
            });
          },
          icon: Icon(Icons.handshake_outlined),
        ),
        ElevatedbuttomCustom(
          text: "Login",
          ontap: () {
            setState(() {
              _startapp = true;
              _isSigning = false;
              _isLogin = true;
            });
          },
          icon: Icon(Icons.login_rounded),
        ),
        ElevatedbuttomCustom(
          text: "Anonymous",
          ontap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shadowColor: const Color.fromARGB(255, 5, 46, 254),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.only(
                    topRight: Radius.circular(60),
                    bottomLeft: Radius.circular(60),
                  ),
                  side: BorderSide(
                    color: const Color.fromARGB(255, 11, 43, 204),
                  ),
                ),

                title: Center(child: Text("ALERT")),
                alignment: Alignment.center,
                elevation: 50,
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Close"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await Dbsql().wipedata();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => homeScreen()),
                      );
                    },
                    child: Text("Continue"),
                  ),
                ],
                content: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(77, 0, 0, 0),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    "When using anonymous login, your data will not be stored locally and will be permanently deleted upon logout.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          },
          icon: Icon(Icons.handshake_outlined),
        ),
        Divider(thickness: 2),
        OutlinedButton.icon(
          onPressed: () {},
          label: Text("Contiue with"),
          icon: Icon(Iconsax.google_1_bold),
        ),
      ],
    );

    if (_isLogin == true) {
      setState(() {
        InsideContiner = Loginwidget(key: ValueKey("login"), back: back);
      });
    }
    if (_isSigning == true) {
      setState(() {
        InsideContiner = Signupwidget(key: ValueKey("sign"), back: back);
      });
    }

    // SecondHalf widget ---------------------------------------------------------------
    Widget second_half = InkWell(
      onTap: () => setState(() {
        _startapp = true;
        heading_flex = 1;
        button_Flex = 2;
      }),
      child: Center(child: Lottie.asset("lib/assests/arrow.json", height: 500)),
    );

    if (_startapp == true) {
      Widget temp = Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color.fromARGB(143, 0, 0, 0),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(100),
            bottomLeft: Radius.circular(100),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: SingleChildScrollView(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                final animatedOffest = Tween<Offset>(
                  begin: Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation);
                return SlideTransition(position: animatedOffest, child: child);
              },
              child: InsideContiner,
            ),
          ),
        ),
      );

      setState(() {
        container = const Color.fromARGB(145, 0, 0, 0);
        second_half = temp;
      });
    }

    // scafold--------------------------------------
    return SafeArea(
      child: Scaffold(
        // body
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("lib/assests/peakpx.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              //heading
              Flexible(
                flex: heading_flex,
                child: FittedBox(
                  child: AnimatedDefaultTextStyle(
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width * headingSize,
                      height: 1,
                    ),
                    duration: Duration(milliseconds: 200),
                    child: heading,
                  ),
                ),
              ),
              Flexible(
                flex: button_Flex,

                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    final animationOffset = Tween<Offset>(
                      begin: Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation);
                    return SlideTransition(
                      position: animationOffset,
                      child: child,
                    );
                  },
                  child: second_half,
                ),
              ),

              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
