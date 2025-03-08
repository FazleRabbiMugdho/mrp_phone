import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class BuyerScreen extends StatefulWidget {
  const BuyerScreen({super.key});

  @override
  _BuyerScreenState createState() => _BuyerScreenState();
}

class _BuyerScreenState extends State<BuyerScreen> {
  String buyerId = '';
  String sellerId = '';

  @override
  //void initState() {
    //super.initState();
    //getBuyerId();
  //}
  void initState() {
    super.initState();
    _fetchBuyerInfo();
    _fetchSellerId();
  }

  Future<void> _fetchBuyerInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() => buyerId = user.uid);
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          //merchantFullName = userDoc['full_name'] ?? 'Merchant';
          buyerId = userDoc['unique_id'] ?? 'N/A';
        });
      }
    }
  }

  Future<void> _fetchSellerId() async {
    try {
      // Fetch the sellerId from the first document in the 'buyer_notifications' collection
      sellerId = (await FirebaseFirestore.instance
          .collection('buyer_notifications')
          .get())
          .docs.isNotEmpty
          ? (await FirebaseFirestore.instance
          .collection('buyer_notifications')
          .get())
          .docs.first['sellerId']
          : 'Not found'; // Fallback to 'Not found' if no documents
    } catch (e) {
      print('Error fetching seller ID: $e');
      sellerId = 'Not Found'; // Optional: Set sellerId to 'Error' in case of an exception
    }
  }
  // Function to get the authenticated buyer ID
  /*void getBuyerId() {
    final user = FirebaseAuth.instance.currentUser ;
    if (user != null) {
      print("Authenticated user ID: ${user.uid}"); // Debugging line to verify the user ID
      setState(() {
        buyerId = user.uid; // Get the authenticated buyer's ID
      });
    } else {
      Get.snackbar('Error', 'User  not authenticated. Please sign in.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }*/

  // Accept the request (changing the status to 'accepted')
  Future<void> acceptRequest(DocumentSnapshot notification) async {
    try {
      // Prepare the data to be stored in the transactions collection
      final data = notification.data() as Map<String, dynamic>;
      final transactionData = {
        'product': data['product'],
        'buyerId': buyerId,
        'sellerId': sellerId, // Assuming sellerId is part of the notification data
        'quantity': data['quantity'],
        'price': data['price'],
        'status': 'accepted',
        'location': data['location'], // Assuming location is part of the notification data
        'createdAt': FieldValue.serverTimestamp(), // Add a timestamp
      };

      // Add the transaction to the transactions collection
      await FirebaseFirestore.instance.collection('transactions').add(transactionData);

      // Remove the notification from the buyer_notifications collection
      await FirebaseFirestore.instance
          .collection('buyer_notifications')
          .doc(notification.id)
          .delete();

      Get.snackbar('Request Accepted', 'You have accepted the seller’s request. 🎉🎉',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to accept request: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  // Reject the request (canceling the transaction)
  Future<void> rejectRequest(DocumentSnapshot notification) async {
    try {
      // Remove the notification from the buyer_notifications collection
      await FirebaseFirestore.instance
          .collection('buyer_notifications')
          .doc(notification.id)
          .delete();

      Get.snackbar('Request Rejected', 'You have rejected the seller’s request. ❌❌',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject request: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buyer Requests'),
        backgroundColor: Colors.blueAccent, // Set a primary color for the app bar
      ),
      body: Container(
        color: Colors.grey[200], // Set a light background color
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('buyer_notifications')
              .orderBy('timestamp', descending: true) // Sort by timestamp in descending order
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error fetching data: ${snapshot.error}"));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No requests available.'));
            }

            return ListView(
              padding: const EdgeInsets.all(16.0), // Add padding to the list view
              children: snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;

                // Format the timestamp to AM/PM format
                final timestamp = (data['timestamp'] as Timestamp).toDate();
                final formattedTime = DateFormat('yyyy-MM-dd – hh:mm a').format(timestamp);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0), // Add margin between cards
                  elevation: 8, // Increase elevation for a more pronounced shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  child: ListTile(
                    title: Text(
                      data['product'] ?? 'No product name',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${data['status']}'),
                        Text('Seller ID: ${data['sellerId'] ?? 'N/A'}'), // Display seller ID
                        Text('Seller Name: ${data['sellerName'] ?? 'N/A'}'), // Display seller name
                        Text('Location: ${data['location'] ?? 'N/A'}'), // Display location
                        Text('Request Sent: $formattedTime'), // Display formatted timestamp
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => acceptRequest(doc),
                          tooltip: 'Accept Request',
                        ),
                        IconButton(
                          icon: const Icon (Icons.close, color: Colors.red),
                          onPressed: () => rejectRequest(doc),
                          tooltip: 'Reject Request',
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}