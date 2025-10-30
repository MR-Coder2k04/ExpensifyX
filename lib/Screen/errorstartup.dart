import 'package:flutter/material.dart';

class ErrorStartup extends StatelessWidget {
  // constrcutor
  const ErrorStartup({super.key});

  //function
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage("/lib/assests/peakpx.jpg"),
          ),
        ),
        child: Center(child: Text("Start Up failed")),
      ),
    );
  }
}
