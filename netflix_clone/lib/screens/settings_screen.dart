import 'package:flutter/material.dart';
import 'download_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            leading: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
            title: const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 16)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.download_for_offline_outlined, color: Colors.white, size: 28),
            title: const Text('Downloads', style: TextStyle(color: Colors.white, fontSize: 16)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DownloadScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.check, color: Colors.white, size: 28),
            title: const Text('My List', style: TextStyle(color: Colors.white, fontSize: 16)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('My List - View your saved movies')),
              );
            },
          ),
          const Divider(color: Colors.grey, height: 32),
          ListTile(
            leading: const Icon(Icons.account_circle_outlined, color: Colors.white, size: 28),
            title: const Text('Account', style: TextStyle(color: Colors.white, fontSize: 16)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account settings')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.white, size: 28),
            title: const Text('Help', style: TextStyle(color: Colors.white, fontSize: 16)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & Support')),
              );
            },
          ),
          const SizedBox(height: 40),
          Center(
            child: SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
