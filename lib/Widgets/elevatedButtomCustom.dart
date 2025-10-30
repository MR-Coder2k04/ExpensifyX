import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ElevatedbuttomCustom extends StatelessWidget {
  const ElevatedbuttomCustom({
    super.key,
    required this.text,
    required this.ontap,
    required this.icon,
  });

  final String text;
  final void Function() ontap;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    // Gets the current scale factor

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        iconSize: 24,
        elevation: 50,
        fixedSize: Size(width * 0.8, height * 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.all(Radius.circular(20)),
        ),
        textStyle: GoogleFonts.signikaNegative(
          fontSize: width * 0.05,
          fontWeight: FontWeight.w700,
        ),
      ),
      onPressed: ontap,
      label: Text(text),
      icon: icon,
    );
  }
}
