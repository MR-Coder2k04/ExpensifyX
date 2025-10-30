import 'package:expense_manager_app/Screen/walletScreen.dart';
import 'package:expense_manager_app/dataModel/walletModel.dart';
import 'package:flutter/widgets.dart';

class PageRouter {
  PageRouter({required this.updatedata, required this.updatewalletlist});
  final void Function() updatedata;
  final void Function() updatewalletlist;

  Route routeToInsideWallet(Walletmodel temp) {
    return PageRouteBuilder(
      pageBuilder: (context, animation1, animation2) => Walletscreen(
        Walletofthiscard: temp,
        updateepxensedata: updatedata,
        updatewalletlist: updatewalletlist,
      ),
      transitionDuration: Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final positon = Tween(
          begin: Offset(1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.decelerate)).animate(animation);

        return SlideTransition(position: positon, child: child);
      },
    );
  }
}
