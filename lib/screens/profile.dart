import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : AssetImage('assets/images/profile_pic.jpg') as ImageProvider,
            ),
            SizedBox(height: 20),
            // Name and Email
            Text(
              user?.displayName ?? "Guest User",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? "No email available",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(height: 20),
            Divider(),
            // Settings List
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text("Settings"),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.notifications),
                    title: Text("Notifications"),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text("Logout"),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      bool confirmLogout = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Logout"),
                          content: Text("Are you sure you want to logout?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text("Logout"),
                            ),
                          ],
                        ),
                      );
                      if (confirmLogout == true) {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
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

// Dummy Settings Screen
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Center(
        child: Text(
          "Settings Screen",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

// Dummy Notifications Screen
class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
      ),
      body: Center(
        child: Text(
          "Notifications Screen",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
