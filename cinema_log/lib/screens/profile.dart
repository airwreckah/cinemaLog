import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../models/app_user.dart';
import '../services/tracker_manager.dart';
import '../screens/movie_details_screen.dart';
import 'package:cinema_log/screens/search.dart';
import 'package:cinema_log/screens/custom_lists_screen.dart';
import 'package:cinema_log/screens/welcome_user.dart';
import 'package:cinema_log/screens/stats_screen.dart';
import 'auth_wrapper.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  static late AppUser currentUser;
  static late TrackerManager trackerManager;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TrackerManager tracker = TrackerManager();
  int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await tracker.loadWatchHistory();
    setState(() {});
  }

  // ================= UPDATE PASSWORD =================
  Future<void> _showUpdatePasswordDialog(BuildContext context) async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101728),
          title: const Text("Update Password", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Current Password",
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "New Password",
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            TextButton(
              child: const Text("Update", style: TextStyle(color: Colors.blue)),
              onPressed: () async {
                try {
                  final user = FirebaseAuth.instance.currentUser!;
                  final cred = EmailAuthProvider.credential(
                    email: user.email!,
                    password: currentPasswordController.text.trim(),
                  );

                  await user.reauthenticateWithCredential(cred);
                  await user.updatePassword(newPasswordController.text.trim());

                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(" Password updated successfully")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // ================= UPDATE EMAIL =================
  Future<void> _showUpdateEmailDialog(BuildContext context) async {
    final passwordController = TextEditingController();
    final newEmailController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101728),
          title: const Text("Update Email", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newEmailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "New Email",
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Current Password",
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            TextButton(
              child: const Text("Update", style: TextStyle(color: Colors.blue)),
              onPressed: () async {
                try {
                  final user = FirebaseAuth.instance.currentUser!;

                  final cred = EmailAuthProvider.credential(
                    email: user.email!,
                    password: passwordController.text.trim(),
                  );

                  await user.reauthenticateWithCredential(cred);

                  await user.verifyBeforeUpdateEmail(newEmailController.text.trim());

                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(" Verification email sent. Check your inbox."),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // ================= DELETE DATA =================
  Future<void> _deleteEntireUserData(User user) async {
    final firestore = FirebaseFirestore.instance;
    final userRef = firestore.collection('users').doc(user.uid);

    final watchHistory = await userRef.collection('watchHistory').get();
    for (var doc in watchHistory.docs) {
      await doc.reference.delete();
    }

    final customLists = await userRef.collection('customLists').get();
    for (var doc in customLists.docs) {
      await doc.reference.delete();
    }

    await userRef.delete();
  }

  // ================= DELETE ACCOUNT =================
  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101728),
          title: const Text("Delete Account", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "This action is permanent.\nEnter password to continue.",
                style: TextStyle(color: Colors.redAccent),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            TextButton(
              child: const Text("Continue", style: TextStyle(color: Colors.orange)),
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _confirmFinalDelete(context, passwordController.text);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmFinalDelete(BuildContext context, String password) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101728),
          title: const Text("Final Confirmation", style: TextStyle(color: Colors.white)),
          content: const Text(
            "Are you absolutely sure? This cannot be undone.",
            style: TextStyle(color: Colors.red),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            TextButton(
              child: const Text("DELETE", style: TextStyle(color: Color(0xFFFB2C36))),
              onPressed: () async {
                try {
                  final user = FirebaseAuth.instance.currentUser!;

                  final cred = EmailAuthProvider.credential(
                    email: user.email!,
                    password: password,
                  );

                  await user.reauthenticateWithCredential(cred);

                  await _deleteEntireUserData(user);
                  await user.delete();

                  Navigator.pop(dialogContext);

                  WelcomeUser.currentUser = AppUser.anonymous();
                  Profile.currentUser = AppUser.anonymous();

                  if (!context.mounted) return;

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AuthWrapper()),
                    (route) => false,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    tracker.calculateStatistics(filter: StatisticsFilterType.lifetime);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: GradientText(
          'Cinema Log',
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          colors: const [Color(0xFF615FFF), Color(0xFFAD46FF)],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 10),
            Text(Profile.currentUser.fullName ?? "No Name",
                style: const TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 5),
            Text("Email: ${Profile.currentUser.email ?? ''}",
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),

            Center(
              child: Container(
                width: 375,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF101728),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => StatsScreen()),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('View Your Statistics',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const Divider(),

                    GestureDetector(
                      onTap: () => _showUpdatePasswordDialog(context),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('Update Password',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const Divider(),

                    GestureDetector(
                      onTap: () => _showUpdateEmailDialog(context),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('Update Email',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const Divider(),

                    //
                    GestureDetector(
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();

                        WelcomeUser.currentUser = AppUser.anonymous();
                        Profile.currentUser = AppUser.anonymous();

                        if (!context.mounted) return;

                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const AuthWrapper()),
                          (route) => false,
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Color(0xFFFB2C36)),
                            SizedBox(width: 8),
                            Text('Sign Out',
                                style: TextStyle(color: Color(0xFFFB2C36))),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),

                    
                    GestureDetector(
                      onTap: () => _showDeleteAccountDialog(context),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(Icons.delete_forever_rounded,
                                color: Color(0xFFFB2C36)),
                            SizedBox(width: 8),
                            Text('Delete Account',
                                style: TextStyle(color: Color(0xFFFB2C36))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => WelcomeUser()));
          } else if (index == 1) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Search()));
          } else if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CustomListsScreen()));
          } else if (index == 3) {
            Profile.currentUser = WelcomeUser.currentUser;
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Profile()));
          }

          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_border), label: 'Lists'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
