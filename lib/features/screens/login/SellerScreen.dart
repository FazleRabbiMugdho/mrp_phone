import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class SellerScreen extends StatefulWidget {
  const SellerScreen({super.key});

  @override
  _SellerScreenState createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController buyerIdController = TextEditingController();
  final TextEditingController productController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  File? _imageFile;
  String? _imageUrl;

  List<String> locations = ['Dhaka', 'Chittagong', 'Khulna', 'Rajshahi', 'Sylhet'];
  String selectedLocation = 'Dhaka';

  // Pick an image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Upload image to Firebase Storage
  Future<String?> _uploadImage(File imageFile) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('product_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image: $e', backgroundColor: Colors.red, colorText: Colors.white);
      return null;
    }
  }

  // Submit the request
  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      String? imageUrl;

      // Upload image if available
      if (_imageFile != null) {
        imageUrl = await _uploadImage(_imageFile!);
      }

      try {
        // Save request to Firestore
        await FirebaseFirestore.instance.collection('buyer_notifications').add({
          'buyerId': buyerIdController.text,  // Store buyer's ID
          'product': productController.text,
          'quantity': int.parse(quantityController.text),
          'price': double.parse(priceController.text),
          'location': selectedLocation,
          'status': 'pending', // Initially, the status is pending
          'message': 'New product request from seller',
          'imageUrl': imageUrl ?? '',  // Save the image URL if available
          'area': selectedLocation,  // Save the area/location
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Notify the buyer about the request submission (optional)
        await FirebaseFirestore.instance.collection('buyer_notifications').add({
          'buyerId': buyerIdController.text,
          'message': 'Seller has posted a new product request.',
          'status': 'pending',
          'product': productController.text,
          'quantity': int.parse(quantityController.text),
          'price': double.parse(priceController.text),
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Clear the form after submission
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: buyerIdController,
                decoration: const InputDecoration(labelText: 'Buyer ID'),
                validator: (value) => value!.isEmpty ? 'Buyer ID is required' : null,
              ),
              TextFormField(
                controller: productController,
                decoration: const InputDecoration(labelText: 'Product'),
                validator: (value) => value!.isEmpty ? 'Product is required' : null,
              ),
              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
                validator: (value) => value!.isEmpty ? 'Quantity is required' : null,
              ),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (value) => value!.isEmpty ? 'Price is required' : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedLocation,
                onChanged: (value) {
                  setState(() {
                    selectedLocation = value!;
                  });
                },
                items: locations.map((location) {
                  return DropdownMenuItem(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Select Location'),
              ),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Product Image'),
              ),
              _imageFile != null
                  ? Image.file(_imageFile!)
                  : const SizedBox.shrink(),
              ElevatedButton(
                onPressed: _submitRequest,
                child: const Text('Send Request to Buyer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
