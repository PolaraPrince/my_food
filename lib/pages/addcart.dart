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

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = calculateTotalPrice();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff9AD0C2),
        title: Text(
          "My Cart",
          style: AppWidget.headlineTextFeildStyle(),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Color(0xff9AD0C2),
        child: cartItems.isEmpty
            ? Center(
                child: Text('Your cart is empty'),
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

                        return Dismissible(
                          movementDuration: Duration(seconds: 5),
                          key: Key(item['docId']),
                          onDismissed: (direction) {
                            removeItemFromCart(context, item['docId']);
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
                              color: Color(0xffF1FADA),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              title: Text(
                                '$name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '₹ $price',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              trailing: Text(
                                'Quantity: ${item['quantity']}',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        );
                      },
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
                                            color: Color(0xff9AD0C2),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1,
                                          height: 200,
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
                                                return CircularProgressIndicator();
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
                                                        width: 200,
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    8.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color: addressType ==
                                                                      'Home'
                                                                  ? Colors.green
                                                                  : (addressType ==
                                                                          'Office'
                                                                      ? Colors
                                                                          .blue
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
                                                                ? Colors.green
                                                                : (addressType ==
                                                                        'Office'
                                                                    ? Colors
                                                                        .blue
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
                                                                    : ''),
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
                                                return Color(0xffF1FADA);
                                              }
                                            }),
                                            foregroundColor:
                                                MaterialStateProperty
                                                    .resolveWith((states) {
                                              if (states.contains(
                                                  MaterialState.pressed)) {
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
                            color: Color(0xffF1FADA),
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
                          child: Container(
                            padding: EdgeInsets.only(top: 7, left: 11),
                            height: 40.0,
                            width: 160.0,
                            decoration: BoxDecoration(
                                color: Color(0xffF1FADA),
                                borderRadius: BorderRadius.circular(20.0)),
                            child: Text(
                              "Make Payment",
                              style: AppWidget.semiBoldTextFeildStyle(),
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
}
