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
          decoration: BoxDecoration(color: Color(0xff9AD0C2)),
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
        color: Color(0xff9AD0C2),
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
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsPage(item: foodItem),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xffF1FADA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                foodItem['name'],
                                style: AppWidget.semiBoldTextFeildStyle(),
                              ),
                              SizedBox(height: 5),
                              Text(
                                foodItem['detail'],
                                maxLines:
                                    descriptionStates[index] == 1 ? 5 : null,
                                overflow: TextOverflow.ellipsis,
                                style: AppWidget.lightTextFeildStyle(),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    descriptionStates[index] == 1
                                        ? descriptionStates[index] = 0
                                        : descriptionStates[index] = 1;
                                  });
                                },
                                child: Text(
                                  descriptionStates[index] == 1
                                      ? 'Less'
                                      : 'More',
                                  style: TextStyle(
                                    color: Color(0xff9AD0C2),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\₹${foodItem['price'].toDouble()}',
                              style: AppWidget.semiBoldTextFeildStyle(),
                            ),
                            SizedBox(height: 10),
                            Row(
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
                                  quantityValues[index].toString(),
                                  style: AppWidget.semiBoldTextFeildStyle(),
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
                                SizedBox(width: 25.0),
                                Container(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (quantityValues[index] > 0) {
                                        addCartItem(foodItem, index, context);
                                      }
                                    },
                                    child: Container(
                                      width: 30,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 57, 57, 57),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.shopping_cart_outlined,
                                        color: Colors.white,
                                        size: 24.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
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
