import 'package:cinema_log/services/controller.dart';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../screens/welcome_user.dart';
import '../screens/search.dart';
import '../screens/profile.dart';
import '../services/controller.dart';
import '../models/custom_list.dart';
import 'custom_list_detail.dart';
import 'watch_status_screen.dart';

class CustomListsScreen extends StatefulWidget {
  const CustomListsScreen({super.key});

  @override
  State<CustomListsScreen> createState() => _CustomListsScreenState();
}

class _CustomListsScreenState extends State<CustomListsScreen> {
  final Controller _controller = Controller();
  final TextEditingController _listNameController = TextEditingController();
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    Future.wait([
      _controller.loadCustomLists(),
      _controller.loadWatchStatus(),
    ]).then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _listNameController.dispose();
    super.dispose();
  }

  Future<void> _createList() async {
    final listName = _listNameController.text.trim();

    if (listName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a list name')));
      return;
    }

    await _controller.createCustomList(listName);
    await _controller.loadCustomLists();

    setState(() {
      _listNameController.clear();
    });
  }

  Future<void> _deleteList(String id) async {
    await _controller.deleteCustomList(id);
    await _controller.loadCustomLists();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<CustomList> customLists = _controller.getCustomLists();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: GradientText(
          'Cinema Log',
          style: TextStyle(
            fontSize: 30,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w900,
            height: 1.33,
            letterSpacing: -1.20,
          ),
          colors: [Color(0xFF615FFF), Color(0xFFAD46FF)], //header title
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _listNameController,
              decoration: InputDecoration(
                labelText: 'Enter custom list name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _createList,
                ),
              ),
              onSubmitted: (_) => _createList(),
            ),
            const SizedBox(height: 16),
            // My Watch Status card
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: const Color(0xFF1A2238),
              child: ListTile(
                leading: const Icon(Icons.push_pin, color: Colors.amber),
                title: const Text(
                  'Watch Status',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Watched • Watching • Want to Watch',
                  style: TextStyle(color: Color(0xFF99A1AF)),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => WatchStatusScreen()),
                  );
                },
              ),
            ),
            Expanded(
              child: customLists.isEmpty
                  ? const Center(
                      child: Text(
                        'No custom lists yet.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: customLists.length,
                      itemBuilder: (context, index) {
                        final customList = customLists[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            tileColor: Color(0xFF101728),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            title: Text(
                              customList.name,
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              '${customList.items.length} item(s)',
                              style: TextStyle(color: Color(0xFF99A1AF)),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              color: Color(0xFF99A1AF),
                              focusColor: Colors.white,
                              onPressed: () => _deleteList(customList.id),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CustomListDetailScreen(
                                    customList: customList,
                                  ),
                                ),
                              ).then((_) {
                                setState(() {});
                              });
                            },
                          ),
                        );
                      },
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WelcomeUser()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Search()),
            );
          } else if (index == 2) {
            // Already on Custom Lists screen, do nothing
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Profile()),
            );
          }
          ;
        },

        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home), //Home tab
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search), //Search tab
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border), //List tab
            label: 'Lists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), //Profile tab
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
