import 'package:expense_manager_app/Screen/homeScreen.dart';
import 'package:expense_manager_app/Widgets/elevatedButtomCustom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Loginwidget extends StatefulWidget {
  //construtor--------------------

  Loginwidget({super.key, required this.back});

  //varaible-----------------------------

  final void Function() back;

  @override
  State<Loginwidget> createState() => _LoginwidgetState();
}

class _LoginwidgetState extends State<Loginwidget> {
  bool loading = false;
  String _email = "";

  String _password = "";

  final _form_Key = GlobalKey<FormState>();

  //  funtion-------------------------------
  void Save(BuildContext context) async {
    final internet = await InternetConnectionChecker.instance.hasConnection;

    if (internet) {
      final valid = _form_Key.currentState!.validate();
      if (valid) {
        _form_Key.currentState!.save();

        try {
          final res = await Supabase.instance.client.auth.signInWithPassword(
            password: _password,
            email: _email,
          );

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const homeScreen()),
          );
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Signup failed: Wrong credentials")),
          );
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("No Internet Connection"),
          content: const Text(
            "Please check your internet connection and try again.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  //build----------------------------
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          spacing: 20,
          children: [
            Form(
              key: _form_Key,
              child: Column(
                spacing: 20,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Email",
                      filled: true,
                      fillColor: const Color.fromARGB(255, 255, 255, 255),
                      border: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      enabled: true,
                    ),
                    validator: (value) {
                      if (value!.isEmpty ||
                          value.length < 4 ||
                          !value.contains("@")) {
                        return "Invalid Entry";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (newValue) => _email = newValue!,
                  ),

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
                    onSaved: (newValue) => _password = newValue!,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Spacer(),
                OutlinedButton(onPressed: widget.back, child: Text("Back")),
                SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    Save(context);
                    setState(() {
                      loading = true;
                    });
                  },
                  child: loading == false
                      ? Text("Sign in")
                      : Flexible(
                          child: Padding(
                            padding: EdgeInsets.all(3),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
