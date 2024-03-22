import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:my_food/pages/addaddress.dart';
import 'package:my_food/pages/wallet.dart';
import 'package:my_food/widget/widget_support.dart';
import 'package:my_food/pages/showItems.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];
  String? userId;
  User? user = FirebaseAuth.instance.currentUser;
  final Map<String, String> itemDocIds = {};

  Future<void> getCurrentUser() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      await getCartItems(userId);
    } else {
      print('User is not logged in');

      setState(() {
        cartItems = [];
      });
    }
  }

  Future<void> getCartItems(String uid) async {
    try {
      final cartItemsSnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('userId', isEqualTo: uid)
          .get();

      final updatedCartItems =
          await Future.wait(cartItemsSnapshot.docs.map((doc) async {
        final data = doc.data();
        final itemUid = data['itemUid'];

        try {
          final itemDoc = await FirebaseFirestore.instance
              .collection('items')
              .doc(itemUid)
              .get();

          if (itemDoc.exists) {
            final Map<String, dynamic> itemData =
                Map.from(itemDoc.data() as Map);

            final String name = itemData['name'] ?? 'Unknown';
            final double price = itemData['price'].toDouble() ?? 0.0;
            final int quantity = data['quantity'] ?? 0;

            return {
              'name': name,
              'price': price,
              'quantity': quantity,
              'docId': doc.id,
            };
          } else {
            print('Item not found for uid: $itemUid');
            return null;
          }
        } catch (e) {
          print('Error fetching item: $e');
          return null;
        }
      }));

      final List<Map<String, dynamic>> filteredCartItems =
          updatedCartItems.whereType<Map<String, dynamic>>().toList();

      setState(() {
        cartItems = filteredCartItems;
      });
    } catch (error) {
      print('Error fetching cart items: $error');
    }
  }

  double calculateTotalPrice() {
    double totalPrice = 0;
    for (final item in cartItems) {
      if (item['price'] != null && item['quantity'] != null) {
        totalPrice += (item['price'] as double) * (item['quantity'] as int);
      }
    }
    return totalPrice;
  }

  Future<void> updateQuantity(String docId, int newQuantity) async {
    try {
      await FirebaseFirestore.instance.collection('cart').doc(docId).update({
        'quantity': newQuantity,
      });
      if (user != null) {
        await getCartItems(user!.uid);
      }
    } catch (error) {
      print('Error updating quantity: $error');
    }
  }

  Future<void> removeItemFromCart(BuildContext context, String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('cart').doc(docId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item removed from cart'),
          duration: Duration(seconds: 1),
        ),
      );
      if (user != null) {
        getCartItems(user.uid);
      }
    }
  }

  void decrementQuantity(String docId,
      {required int currentQuantity, required BuildContext context}) {
    if (currentQuantity > 1) {
      updateQuantity(docId, currentQuantity - 1);
    } else {
      removeItemFromCart(context, docId);
    }
    setState(() {});
  }

  void incrementQuantity(String docId,
      {required int currentQuantity, required BuildContext context}) {
    if (currentQuantity < 10) {
      updateQuantity(docId, currentQuantity + 1);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user!.uid;
      getCartItems(userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = calculateTotalPrice();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Cart",
          style: AppWidget.headlineTextFeildStyle(),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.of(context).maybePop(context);
          },
        ),
      ),
      body: Container(
        child: cartItems.isEmpty
            ? Center(
                child: FutureBuilder(
                  future: userId != null ? getCartItems(userId!) : null,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(
                        color: Color(0xff6D3805),
                        strokeWidth: 2,
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Text('Your cart is empty');
                    }
                  },
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        final name = item['name'];
                        final price = item['price'];
                        final docId = item['docId'];

                        int currentQuantity = item['quantity'] ?? 0;

                        return Dismissible(
                          movementDuration: Duration(seconds: 3),
                          key: Key(docId),
                          onDismissed: (direction) {
                            removeItemFromCart(context, docId);
                          },
                          background: Container(
                            color: Colors.red,
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.delete, color: Colors.white),
                              ],
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(218, 104, 54, 6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$name',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        '₹ $price',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 6, right: 6),
                                  height: 30,
                                  width: 81,
                                  decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 202, 201, 201),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          decrementQuantity(docId,
                                              currentQuantity: currentQuantity,
                                              context: context);
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
                                        '${currentQuantity}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff6D3805)),
                                      ),
                                      SizedBox(width: 10.0),
                                      GestureDetector(
                                        onTap: () {
                                          incrementQuantity(docId,
                                              currentQuantity: currentQuantity,
                                              context: context);
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
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height / 1,
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0, top: 30.0, right: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text('Select Delivery Location',
                                            style: AppWidget
                                                .semiBoldTextFeildStyle()),
                                        Text(
                                            'Select a delivery location to see product \navailable,offers and discount.',
                                            style: AppWidget
                                                .lightTextFeildStyle()),
                                        SizedBox(height: 15.0),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1,
                                          height: 150,
                                          child: StreamBuilder<QuerySnapshot>(
                                            stream: user != null
                                                ? FirebaseFirestore.instance
                                                    .collection("users")
                                                    .doc(user!.uid)
                                                    .collection("addresses")
                                                    .snapshots()
                                                : Stream.value(
                                                    <DocumentSnapshot>[]
                                                        as QuerySnapshot<
                                                            Object?>),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<QuerySnapshot>
                                                    snapshot) {
                                              if (snapshot.hasError) {
                                                return Text(
                                                    'Error: ${snapshot.error}');
                                              }

                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Center();
                                              }

                                              return ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    snapshot.data!.docs.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  final data = snapshot
                                                          .data!.docs[index]
                                                          .data()
                                                      as Map<String, dynamic>;
                                                  String addressType =
                                                      data['location'];
                                                  return Stack(
                                                    children: [
                                                      Container(
                                                        width: 180,
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    8.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color: addressType ==
                                                                      'Home'
                                                                  ? Color
                                                                      .fromARGB(
                                                                          255,
                                                                          240,
                                                                          134,
                                                                          47)
                                                                  : (addressType ==
                                                                          'Office'
                                                                      ? Color.fromARGB(
                                                                          255,
                                                                          102,
                                                                          177,
                                                                          239)
                                                                      : Color(
                                                                          0xffF1FADA))),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                        ),
                                                        child: ListTile(
                                                          title: Text(
                                                            data['name'],
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          subtitle: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(data[
                                                                  'houseno']),
                                                              Text(data[
                                                                  'apartment']),
                                                              Text(
                                                                  data['city']),
                                                              Text(data[
                                                                  'zipCode']),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        right: 8,
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.all(4),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: addressType ==
                                                                    'Home'
                                                                ? Color
                                                                    .fromARGB(
                                                                        255,
                                                                        240,
                                                                        134,
                                                                        47)
                                                                : (addressType ==
                                                                        'Office'
                                                                    ? Color
                                                                        .fromARGB(
                                                                            255,
                                                                            102,
                                                                            177,
                                                                            239)
                                                                    : Colors
                                                                        .transparent),
                                                            borderRadius: BorderRadius
                                                                .only(
                                                                    bottomLeft:
                                                                        Radius
                                                                            .circular(
                                                                      10,
                                                                    ),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            10)),
                                                          ),
                                                          child: Text(
                                                            addressType ==
                                                                    'Home'
                                                                ? 'Home'
                                                                : (addressType ==
                                                                        'Office'
                                                                    ? 'Office'
                                                                    : 'Other'),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
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
                                                MaterialStateColor.resolveWith(
                                                    (states) {
                                              if (states.contains(
                                                  MaterialState.pressed)) {
                                                return Color(0xff9AD0C2);
                                              } else {
                                                return Colors.black;
                                              }
                                            }),
                                            foregroundColor:
                                                MaterialStateProperty
                                                    .resolveWith((states) {
                                              if (states.contains(
                                                  MaterialState.pressed)) {
                                                return Color(0xffF1FADA);
                                              } else {
                                                return Colors.white;
                                              }
                                            }),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddAddressPage()),
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
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(8),
                        width: MediaQuery.of(context).size.width,
                        height: 40.0,
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 240, 194, 111),
                            borderRadius: BorderRadius.circular(8.0)),
                        child: Text(
                          "Address",
                          style: AppWidget.semiBoldTextFeildStyle(),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: ₹${totalPrice.toStringAsFixed(2)}',
                          style: AppWidget.semiBoldTextFeildStyle(),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Wallet()),
                            );
                          },
                          child: Expanded(
                            flex: 1,
                            child: Container(
                              padding:
                                  EdgeInsets.only(top: 9, left: 10, right: 10),
                              height: 40.0,
                              width: 140.0,
                              decoration: BoxDecoration(
                                  color: Color(0xffFF5E00),
                                  borderRadius: BorderRadius.circular(20.0)),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 5, left: 2, right: 2),
                                child: Text(
                                  "Make Payment",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
