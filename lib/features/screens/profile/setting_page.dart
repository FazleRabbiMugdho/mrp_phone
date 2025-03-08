import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:mrp_phone/features/screens/profile/settings/Language_screen.dart';
import 'package:mrp_phone/features/screens/profile/settings/account_information_screen.dart';
import 'package:mrp_phone/features/screens/profile/settings/account_security_screen.dart';
import 'package:mrp_phone/features/screens/profile/settings/appearance_screen.dart';
import 'package:mrp_phone/features/screens/profile/settings/helpSupport_screen.dart';
import 'package:mrp_phone/features/screens/profile/settings/notification_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(LineAwesomeIcons.angle_left_solid, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4, // Subtle shadow
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Account Settings Section
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LineAwesomeIcons.user_cog_solid, color: Colors.blue),
                        const SizedBox(width: 10),
                        const Text(
                          "Account Settings",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: const Icon(LineAwesomeIcons.info_circle_solid, color: Colors.blue),
                      title: const Text("Account Information"),
                      onTap: () {
                        // Navigate to Account Information Screen
                        Get.to(() => const AccountInformationScreen());
                      },
                    ),
                    ListTile(
                      leading: const Icon(LineAwesomeIcons.shield_alt_solid, color: Colors.blue),
                      title: const Text("Account Security"),
                      onTap: () {
                        // Navigate to Account Security Screen
                        Get.to(() => const AccountSecurityScreen());
                      },
                    ),
                    ListTile(
                      leading: const Icon(LineAwesomeIcons.bell, color: Colors.blue),
                      title: const Text("Notifications"),
                      onTap: () {
                        // Navigate to Notifications Screen
                        Get.to(() => const NotificationsScreen());
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // App Settings Section
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LineAwesomeIcons.cog_solid, color: Colors.blue),
                        const SizedBox(width: 10),
                        const Text(
                          "App Settings",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: const Icon(LineAwesomeIcons.palette_solid, color: Colors.blue),
                      title: const Text("Appearance"),
                      onTap: () {
                        // Navigate to Appearance Screen
                        Get.to(() => const AppearanceScreen());
                      },
                    ),
                    ListTile(
                      leading: const Icon(LineAwesomeIcons.language_solid, color: Colors.blue),
                      title: const Text("Language"),
                      onTap: () {
                        // Navigate to Language Screen
                        Get.to(() => const LanguageScreen());
                      },
                    ),
                    ListTile(
                      leading: const Icon(LineAwesomeIcons.question_circle, color: Colors.blue),
                      title: const Text("Help & Support"),
                      onTap: () {
                        // Navigate to Help & Support Screen
                        Get.to(() => const HelpSupportScreen());
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}