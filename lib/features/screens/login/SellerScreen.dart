import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

class SellerScreen extends StatefulWidget {
  const SellerScreen({super.key});
  @override
  _SellerScreenState createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController buyerIdController = TextEditingController();
  final TextEditingController productController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  File? _imageFile;
  String? _imageUrl;
  String? sellerUniqueId;
  String? currentUserId;
  String? sellerName;

  List<String> locations = ['Dhaka', 'Chittagong', 'Khulna', 'Rajshahi', 'Sylhet'];
  String selectedLocation = 'Dhaka';

  @override
  void initState() {
    super.initState();
    _fetchMerchantInfo();
  }

  Future<void> _fetchMerchantInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() => currentUserId = user.uid);

      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          sellerUniqueId = userDoc['unique_id'] ?? 'N/A'; // Ensure 'unique_id' exists in Firestore
          sellerName = userDoc['full_name'] ?? 'N/A';
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        final blob = html.Blob([bytes]);
      }
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(dynamic imageFile) async {
    try {
      if (kIsWeb && imageFile is XFile) {
        final bytes = await imageFile.readAsBytes();
        final uploadTask = FirebaseStorage.instance.ref().child('product_images/${imageFile.name}').putData(bytes);
        await uploadTask;
        return await FirebaseStorage.instance.ref('product_images/${imageFile.name}').getDownloadURL();
      } else if (!kIsWeb && imageFile is File) {
        String fileName = 'product_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = FirebaseStorage.instance.ref().child(fileName);
        await ref.putFile(imageFile);
        return await ref.getDownloadURL();
      }
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image: $e', backgroundColor: Colors.red, colorText: Colors.white);
      return null;
    }
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      if (sellerUniqueId == null) {
        Get.snackbar('Error', 'Seller ID not found. Please try again.', backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadImage(_imageFile!);
      }

      try {
        await FirebaseFirestore.instance.collection('buyer_notifications').add({
          'buyerId': buyerIdController.text,
          'sellerId': sellerUniqueId,  // Correctly storing seller's unique ID
          'sellerName':sellerName,
          'product': productController.text,
          'quantity': int.parse(quantityController.text),
          'price': double.parse(priceController.text),
          'location': selectedLocation,
          'status': 'pending',
          'message': 'New product request from seller',
          'imageUrl': imageUrl ?? '',
          'timestamp': FieldValue.serverTimestamp(),
        });

        buyerIdController.clear();
        productController.clear();
        quantityController.clear();
        priceController.clear();
        setState(() {
          _imageFile = null;
          selectedLocation = 'Dhaka';
        });

        Get.snackbar('Success', 'Request submitted successfully!', backgroundColor: Colors.green, colorText: Colors.white);
      } catch (e) {
        Get.snackbar('Error', 'Failed to submit request: $e', backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell Product'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(buyerIdController, 'Buyer ID', Icons.person),
                SizedBox(height: 16),
                _buildTextField(productController, 'Product', Icons.shopping_cart),
                SizedBox(height: 16),
                _buildTextField(quantityController, 'Quantity', Icons.production_quantity_limits, isNumber: true),
                SizedBox(height: 16),
                _buildTextField(priceController, 'Price', Icons.attach_money, isNumber: true),
                SizedBox(height: 16),
                _buildDropdown(),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Pick Product Image'),
                ),
                SizedBox(height: 16),
                _imageFile != null
                    ? Image.file(File(_imageFile!.path), height: 150, fit: BoxFit.cover)
                    : const SizedBox.shrink(),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitRequest,
                  child: const Text('Send Request to Buyer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
      ),
      validator: (value) => value!.isEmpty ? '$label is required' : null,
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedLocation,
      onChanged: (value) {
        setState(() {
          selectedLocation = value!;
        });
      },
      items: locations.map((location) {
        return DropdownMenuItem(value: location, child: Text(location));
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Select Location',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
