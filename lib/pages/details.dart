import 'package:cached_network_image/cached_network_image.dart';
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
  String? _imageUrl;
  @override
  void initState() {
    super.initState();
    _quantityValue = 0;
    _fetchImageUrl();
  }

  Future<void> _fetchImageUrl() async {
    final DocumentSnapshot itemSnapshot = await FirebaseFirestore.instance
        .collection('items')
        .doc(widget.item.id)
        .get();

    if (itemSnapshot.exists) {
      final Map<String, dynamic> itemData =
          itemSnapshot.data() as Map<String, dynamic>;
      final String imageUrl = itemData['image'];

      setState(() {
        _imageUrl = imageUrl;
      });
    } else {
      print('Item not found in Firestore');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.item['name']),
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_imageUrl != null)
                CachedNetworkImage(
                  imageUrl: _imageUrl!,
                  height: MediaQuery.of(context).size.height / 2.3,
                  width: MediaQuery.of(context).size.width / 1,
                  fit: BoxFit.fill,
                )
              else
                Center(
                  child: CircularProgressIndicator(
                    color: Color(0xff6D3805),
                    strokeWidth: 2,
                  ),
                ),
              SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                  child: Text(
                    widget.item['name'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ]),
              SizedBox(height: 16),
              Expanded(
                child: Text(
                  widget.item['detail'],
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: Container(
                  padding: EdgeInsets.only(left: 6, right: 6),
                  height: 50,
                  width: 286,
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 224, 222, 222),
                      borderRadius: BorderRadius.circular(40)),
                  child: Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              if (_quantityValue > 0) {
                                setState(() {
                                  _quantityValue--;
                                });
                              }
                            },
                            child: Container(
                              height: 38.0,
                              width: 38.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.remove,
                                color: Color(0xff6D3805),
                                size: 28.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 85.0),
                        Expanded(
                          flex: 1,
                          child: Text(
                            _quantityValue.toString(),
                            style: TextStyle(
                                fontSize: 21, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 85.0),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _quantityValue++;
                              });
                            },
                            child: Container(
                              height: 38.0,
                              width: 38.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.add,
                                color: Color(0xff6D3805),
                                size: 28.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.0)
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
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
                    color: Color(0xffFF5E00),
                    borderRadius: BorderRadius.circular(20.0)),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text(
                    "Add To Cart",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins'),
                  ),
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
