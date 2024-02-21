import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_food/widget/widget_support.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];
  String? userId;
  final Map<String, String> itemDocIds = {};

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      _getCartItems(userId!);
    }
  }

  Future<void> _getCartItems(String uid) async {
    final cartItemsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart')
        .get();
    setState(() {
      cartItems = cartItemsSnapshot.docs.map((doc) {
        final data = doc.data();
        itemDocIds[data['itemName']] = doc.id;
        return data;
      }).toList();
    });
  }

  double _calculateTotalPrice() {
    double totalPrice = 0;
    for (final item in cartItems) {
      totalPrice += (item['itemPrice'] as double) * (item['quantity'] as int);
    }
    return totalPrice;
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = _calculateTotalPrice();
    if (cartItems.isEmpty) {
      return Scaffold(
        body: Container(
          color: Color(0xff9AD0C2),
          child: Center(
            child: Text('Your cart is empty'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff9AD0C2),
        title: Text('My Cart'),
      ),
      body: Container(
        color: Color(0xff9AD0C2),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final itemName = cartItems[index]['itemName'];
                  final itemPrice = cartItems[index]['itemPrice'];
                  final quantity = cartItems[index]['quantity'];
                  return Dismissible(
                    movementDuration: Duration(seconds: 5),
                    key: Key(itemName),
                    onDismissed: (direction) {
                      removeItemFromCart(context, itemName);
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
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xffF1FADA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          '$itemName',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Price: $itemPrice',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: Text(
                          'Quantity: $quantity',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  );
                },
              ),
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
                  ElevatedButton(
                    child: Text('Process Payment'),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> removeItemFromCart(BuildContext context, String itemName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      if (itemDocIds.containsKey(itemName)) {
        final docId = itemDocIds[itemName]!;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('cart')
            .doc(docId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item removed from cart'),
            duration: Duration(seconds: 1),
          ),
        );
        _getCartItems(userId);
      }
    }
  }
}
