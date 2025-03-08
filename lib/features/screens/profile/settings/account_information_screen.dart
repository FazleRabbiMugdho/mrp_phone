import 'package:flutter/material.dart';
class AccountInformationScreen extends StatelessWidget {
  const AccountInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Information"),
      ),
      body: const Center(
        child: Text("Account Information Screen"),
      ),
    );
  }
}