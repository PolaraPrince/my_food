import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:my_food/pages/addcart.dart';
import 'package:my_food/widget/widget_support.dart';

class DetailsPage extends StatefulWidget {
  final DocumentSnapshot item;

  DetailsPage({required this.item});
  List<int> quantityValues = [];

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  int _quantityValue = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff9AD0C2),
        title: Text(widget.item['name']),
      ),
      body: Container(
        decoration: BoxDecoration(color: Color(0xff9AD0C2)),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'images/salad-3.png',
                height: MediaQuery.of(context).size.height / 2.3,
                width: MediaQuery.of(context).size.width / 1,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                  child: Text(
                    widget.item['name'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_quantityValue > 0) {
                          setState(() {
                            _quantityValue--;
                          });
                        }
                      },
                      child: Container(
                        height: 20.0,
                        width: 20.0,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 18.0,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.0),
                    Text(
                      _quantityValue.toString(),
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 10.0),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _quantityValue++;
                        });
                      },
                      child: Container(
                        height: 20.0,
                        width: 20.0,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
              SizedBox(height: 16),
              Expanded(
                child: Text(
                  widget.item['detail'],
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xff9AD0C2),
        height: 75.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '₹${widget.item['price'].toDouble()}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (_quantityValue > 0) {
                  addCartItem(widget.item, _quantityValue, context);
                }
              },
              child: Container(
                padding: EdgeInsets.only(top: 7, left: 15),
                height: 40.0,
                width: 140.0,
                decoration: BoxDecoration(
                    color: Color(0xffF1FADA),
                    borderRadius: BorderRadius.circular(20.0)),
                child: Text(
                  "Add To Cart",
                  style: AppWidget.semiBoldTextFeildStyle(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addCartItem(
      DocumentSnapshot foodItem, int index, BuildContext context) async {
    try {
      final cartRef = FirebaseFirestore.instance.collection('cart');

      await cartRef.add({
        'quantity': _quantityValue,
        'itemUid': foodItem.id,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'dateTime': DateTime.now(),
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CartPage(),
        ),
      );
    } catch (error) {
      print("Error adding item to cart: $error");
    }
  }
}
