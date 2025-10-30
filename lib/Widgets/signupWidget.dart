import 'package:expense_manager_app/Screen/homeScreen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class Signupwidget extends StatefulWidget {
  final void Function() back;

  const Signupwidget({super.key, required this.back});

  @override
  State<Signupwidget> createState() => _SignupwidgetState();
}

class _SignupwidgetState extends State<Signupwidget> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String _username = "";
  String _email = "";
  String _password = "";

  Future<void> save(BuildContext context) async {
    final internet = await InternetConnectionChecker.instance.hasConnection;

    if (internet) {
      final valid = _formKey.currentState!.validate();
      if (valid) {
        _formKey.currentState!.save();

        try {
          await Supabase.instance.client.auth.signUp(
            password: _password,
            email: _email,
            data: {"username": _username},
          );

          if (!mounted) return;

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const homeScreen()),
          );

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Signup successful")));
        } catch (error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Signup failed: $error")));
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 20,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: "User Name",
                  filled: true,
                  fillColor: Colors.white,
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
                onSaved: (newValue) => _username = newValue!,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Email",
                  filled: true,
                  fillColor: Colors.white,
                  border: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty ||
                      value.length < 4 ||
                      !value.contains("@")) {
                    return "Invalid Email";
                  } else {
                    return null;
                  }
                },
                onSaved: (newValue) => _email = newValue!,
              ),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  filled: true,
                  fillColor: Colors.white,
                  border: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty || value.length < 7) {
                    return "Password must be at least 7 characters";
                  } else {
                    return null;
                  }
                },
                onSaved: (newValue) => _password = newValue!,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Spacer(),
                  OutlinedButton(
                    onPressed: widget.back,
                    child: const Text("Back"),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () => {
                      save(context),
                      setState(() {
                        loading = true;
                      }),
                    },
                    child: loading == false
                        ? Text("Sign up")
                        : FittedBox(
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
