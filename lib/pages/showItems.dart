import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_food/pages/addcart.dart';
import 'package:my_food/pages/details.dart';
import 'package:my_food/service/database.dart';
import 'package:my_food/service/shared_pref.dart';
import 'package:my_food/widget/widget_support.dart';

class ShowItems extends StatefulWidget {
  final String uid;
  final String categoryName;

  ShowItems({
    required this.uid,
    required this.categoryName,
  });

  @override
  _ShowItemsState createState() => _ShowItemsState();
}

class _ShowItemsState extends State<ShowItems> {
  late Stream<QuerySnapshot> foodItemsStream;
  TextEditingController? searchController;
  List<int> descriptionStates = [];
  List<int> quantityValues = [];

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    _fetchFoodItems();
  }

  void _fetchFoodItems() {
    String categoryPath = 'items';
    Query collection = FirebaseFirestore.instance.collection(categoryPath);
    collection = collection.where('categoryId', isEqualTo: widget.uid);
    foodItemsStream = collection.snapshots();
    descriptionStates = List.filled(10, 0);
    quantityValues = List.filled(10, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(color: Colors.white),
        ),
        title: TextField(
          controller: searchController,
          style: const TextStyle(color: Color.fromARGB(255, 5, 5, 5)),
          cursorColor: const Color.fromARGB(255, 6, 6, 6),
          decoration: const InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Color.fromARGB(137, 8, 8, 8)),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
      ),
      body: Container(
        color: Colors.white,
        child: StreamBuilder<QuerySnapshot>(
            stream: foodItemsStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text(
                  'Something went wrong',
                  style: AppWidget.semiBoldTextFeildStyle(),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'Coming Soon........',
                    style: AppWidget.semiBoldTextFeildStyle(),
                  ),
                );
              }

              List<DocumentSnapshot> foodItems = snapshot.data!.docs;
              return ListView.builder(
                  itemCount: foodItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    final foodItem = foodItems[index];

                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailsPage(item: foodItem),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                                bottom: 2.0, right: 15, left: 10, top: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(children: [
                              Container(
                                  height: 80.0,
                                  width: 80.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: CachedNetworkImage(
                                      fit: BoxFit.contain,
                                      imageUrl: foodItem['image'],
                                      placeholder: (context, url) =>
                                          Container())),
                              SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      foodItem['name'],
                                      style: AppWidget.semiBoldTextFeildStyle(),
                                    ),
                                    SizedBox(height: 8),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        right: 40,
                                      ),
                                      child: Container(
                                        padding:
                                            EdgeInsets.only(left: 6, right: 6),
                                        height: 30,
                                        width: 85,
                                        decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                                255, 202, 201, 201),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                if (quantityValues[index] > 0) {
                                                  setState(() {
                                                    quantityValues[index]--;
                                                  });
                                                }
                                              },
                                              child: Container(
                                                height: 20.0,
                                                width: 20.0,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Icon(
                                                  Icons.remove,
                                                  color: Color(0xff6D3805),
                                                  size: 18.0,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10.0),
                                            Text(
                                              quantityValues[index].toString(),
                                              style: AppWidget
                                                  .semiBoldTextFeildStyle(),
                                            ),
                                            SizedBox(width: 10.0),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  quantityValues[index]++;
                                                });
                                              },
                                              child: Container(
                                                height: 20.0,
                                                width: 20.0,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Icon(
                                                  Icons.add,
                                                  color: Color(0xff6D3805),
                                                  size: 18.0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\₹${foodItem['price'].toDouble()}',
                                    style: AppWidget.semiBoldTextFeildStyle(),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (quantityValues[index] > 0) {
                                        addCartItem(foodItem, index, context);
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0, left: 20.0),
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Color(0xffFF5E00),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                            child: Icon(
                                          Icons.add_shopping_cart,
                                          color: Colors.white,
                                        )),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                          ),
                        ),
                        Divider(
                          height: 10,
                          color: Color.fromARGB(147, 109, 55, 5),
                        ),
                      ],
                    );
                  });
            }),
      ),
    );
  }

  Future<void> addCartItem(
      DocumentSnapshot foodItem, int index, BuildContext context) async {
    try {
      final cartRef = FirebaseFirestore.instance.collection('cart');

      await cartRef.add({
        'quantity': quantityValues[index],
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
