import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BuyerScreen extends StatefulWidget {
  const BuyerScreen({super.key});

  @override
  _BuyerScreenState createState() => _BuyerScreenState();
}

class _BuyerScreenState extends State<BuyerScreen> {
  String buyerId = '';

  @override
  void initState() {
    super.initState();
    getBuyerId();
  }

  // Function to get the authenticated buyer ID
  void getBuyerId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print("Authenticated user ID: ${user.uid}"); // Debugging line to verify the user ID
      setState(() {
        buyerId = user.uid; // Get the authenticated buyer's ID
      });
    } else {
      Get.snackbar('Error', 'User not authenticated. Please sign in.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  // Accept the request (changing the status to 'accepted')
  Future<void> acceptRequest(DocumentSnapshot notification) async {
    try {
      await FirebaseFirestore.instance
          .collection('buyer_notifications')
          .doc(notification.id)
          .update({'status': 'accepted'});

      Get.snackbar('Request Accepted', 'You have accepted the seller’s request.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buyer Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Temporarily removing query filters for debugging
        stream: FirebaseFirestore.instance
            .collection('buyer_notifications')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Debugging: Print the snapshot data to check if it has data
          print("Buyer ID: $buyerId");
          print("Snapshot data length: ${snapshot.data?.docs.length}");

          if (snapshot.hasError) {
            print("Error fetching data: ${snapshot.error}");
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No requests available.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              // Debugging: Check the content of each document
              print("Document Data: $data");

              return ListTile(
                title: Text(data['product'] ?? 'No product name'),
                subtitle: Text('Status: ${data['status']}'),
                trailing: ElevatedButton(
                  onPressed: () => acceptRequest(doc),
                  child: const Text('Accept'),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
