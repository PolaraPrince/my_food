import 'dart:math';

import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:my_food/pages/addaddress.dart';
import 'package:my_food/pages/addcart.dart';
import 'package:my_food/pages/categorycard.dart';
import 'package:my_food/pages/showItems.dart';
import 'package:my_food/pages/searchpage.dart';
import 'package:my_food/service/database.dart';
import 'package:my_food/widget/widget_support.dart';

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  Future<List<String>> getCategories() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    List<String> categories =
        querySnapshot.docs.map((doc) => doc['name'] as String).toList();
    return categories;
  }

  late Future<List<Map<String, dynamic>>> bannersFuture;
  @override
  void initState() {
    super.initState();
    categoriesFuture = DatabaseMethods().getCategories();
    bannersFuture = FirebaseFirestore.instance
        .collection('banners')
        .get()
        .then((QuerySnapshot querySnapshot) {
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  late Future<List<String>> categoriesFuture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          margin: EdgeInsets.only(top: 30.0, left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Hello Prince,",
                style: AppWidget.boldTextFeildStyle(),
              ),
              Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => CartPage()));
                    },
                    child:
                        Icon(Icons.shopping_bag_outlined, color: Colors.white)),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            showModalBottomSheet<void>(
              backgroundColor: Color(0xff9AD0C2),
              context: context,
              builder: (BuildContext context) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, top: 30.0, right: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Select Delivery Location',
                                  style: AppWidget.semiBoldTextFeildStyle()),
                              Text(
                                  'Select a delivery location to see product \navailable,offers and discount.',
                                  style: AppWidget.lightTextFeildStyle()),
                              SizedBox(height: 15.0),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xff9AD0C2),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                width: MediaQuery.of(context).size.width / 1,
                                height: 200,
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: user != null
                                      ? FirebaseFirestore.instance
                                          .collection("users")
                                          .doc(user!.uid)
                                          .collection("addresses")
                                          .snapshots()
                                      : Stream.value(<DocumentSnapshot>[]
                                          as QuerySnapshot<Object?>),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }

                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    }

                                    return ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: snapshot.data!.docs.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final data = snapshot.data!.docs[index]
                                            .data() as Map<String, dynamic>;
                                        String addressType = data['location'];
                                        return Stack(
                                          children: [
                                            Container(
                                              width: 200,
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: addressType == 'Home'
                                                        ? Colors.green
                                                        : (addressType ==
                                                                'Office'
                                                            ? Colors.blue
                                                            : Color(
                                                                0xffF1FADA))),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: ListTile(
                                                title: Text(
                                                  data['name'],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                subtitle: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(data['houseno']),
                                                    Text(data['apartment']),
                                                    Text(data['city']),
                                                    Text(data['zipCode']),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 8,
                                              child: Container(
                                                padding: EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: addressType == 'Home'
                                                      ? Colors.green
                                                      : (addressType == 'Office'
                                                          ? Colors.blue
                                                          : Colors.transparent),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                            10,
                                                          ),
                                                          topRight:
                                                              Radius.circular(
                                                                  10)),
                                                ),
                                                child: Text(
                                                  addressType == 'Home'
                                                      ? 'Home'
                                                      : (addressType == 'Office'
                                                          ? 'Office'
                                                          : ''),
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 15.0),
                              ElevatedButton(
                                child: Text('Add'),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateColor.resolveWith((states) {
                                    if (states
                                        .contains(MaterialState.pressed)) {
                                      return Color(0xff9AD0C2);
                                    } else {
                                      return Color(0xffF1FADA);
                                    }
                                  }),
                                  foregroundColor:
                                      MaterialStateProperty.resolveWith(
                                          (states) {
                                    if (states
                                        .contains(MaterialState.pressed)) {
                                      return Color(0xffF1FADA);
                                    } else {
                                      return Colors.black;
                                    }
                                  }),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddAddressPage()),
                                  );
                                },
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
          child: Container(
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              padding: EdgeInsets.all(11),
              width: 120.0,
              height: 40.0,
              decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20.0)),
              child: Text(
                "Add Address",
                style: TextStyle(color: Colors.white, fontFamily: "poppins"),
              )),
        ),
        SizedBox(height: 8),
        Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: CupertinoSearchTextField(
            controller: _searchController,
            placeholder: 'Search...',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20),
        Center(
          child: Container(
            height: MediaQuery.of(context).size.height / 4.5,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: bannersFuture,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return AnotherCarousel(
                        images: snapshot.data!
                            .map((banner) => Image(
                                  fit: BoxFit.fill,
                                  image: NetworkImage(
                                    banner['image'],
                                  ),
                                ))
                            .toList(),
                        autoplayDuration: Duration(seconds: 20),
                        dotSize: 4,
                        dotSpacing: 15.0,
                        indicatorBgPadding: 2,
                        dotBgColor: Colors.transparent,
                        dotColor: Colors.black,
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            child: FutureBuilder<List<String>>(
              future: getCategories(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, right: 10.0, bottom: 20.0),
                    child: Wrap(
                      spacing: 20.0,
                      runSpacing: 20.0,
                      children: snapshot.data!.map((category) {
                        return FutureBuilder<String?>(
                          future:
                              DatabaseMethods().getCategoryImageUrl(category),
                          builder: (BuildContext context,
                              AsyncSnapshot<String?> imageSnapshot) {
                            if (imageSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (imageSnapshot.hasError) {
                              return Text('Error: ${imageSnapshot.error}');
                            } else {
                              final imageUrl = imageSnapshot.data;
                              return CategoryCard(
                                categoryName: category,
                                imageUrl: imageUrl!,
                              );
                            }
                          },
                        );
                      }).toList(),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ]),
    );
  }

  void _handleCategoryTap(String categoryName) {
    FirebaseFirestore.instance
        .collection('categories')
        .where('name', isEqualTo: categoryName)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        String uid = querySnapshot.docs.first.id;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowItems(
              uid: uid,
              categoryName: categoryName,
            ),
          ),
        );
      }
    }).catchError((error) {
      print("Error: $error");
    });
  }
}
