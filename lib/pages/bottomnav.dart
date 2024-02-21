import "package:curved_navigation_bar/curved_navigation_bar.dart";
import "package:flutter/material.dart";
import "package:my_food/pages/home.dart";
import 'package:my_food/pages/addcart.dart';
import "package:my_food/pages/profile.dart";
import "package:my_food/pages/wallet.dart";

class BottomNev extends StatefulWidget {
  const BottomNev({super.key});

  @override
  State<BottomNev> createState() => _BottomNevState();
}

class _BottomNevState extends State<BottomNev> {
  int CurrentTabIndex = 0;

  late List<Widget> pages;
  late Widget CurrentPage;
  late Home homepage;
  late CartPage cartpage;
  late Wallet wallet;
  late Profile profile;

  @override
  void initState() {
    homepage = Home();
    cartpage = CartPage();
    wallet = Wallet();
    profile = Profile();
    pages = [homepage, cartpage, wallet, profile];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
        backgroundColor: Color(0xffF1FADA),
        color: Colors.black,
        animationDuration: Duration(milliseconds: 400),
        onTap: (int index) {
          setState(() {
            CurrentTabIndex = index;
          });
        },
        items: [
          Icon(
            Icons.home_outlined,
            color: Colors.white,
          ),
          Icon(
            Icons.shopping_bag_outlined,
            color: Colors.white,
          ),
          Icon(
            Icons.wallet_outlined,
            color: Colors.white,
          ),
          Icon(
            Icons.person_outlined,
            color: Colors.white,
          ),
        ],
      ),
      body: pages[CurrentTabIndex],
    );
  }
}
