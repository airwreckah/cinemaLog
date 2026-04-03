import 'package:cinema_log/services/controller.dart';
import 'package:flutter/material.dart';

import '../screens/welcome_user.dart';
import '../screens/search.dart';
import '../screens/profile.dart';
import '../services/controller.dart';
import '../models/custom_list.dart';
import 'custom_list_detail.dart';

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
  void dispose() {
    _listNameController.dispose();
    super.dispose();
  }

  void _createList() {
    final listName = _listNameController.text.trim();

    if (listName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a list name')));
      return;
    }

    _controller.createCustomList(listName);

    setState(() {
      _listNameController.clear();
    });
  }

  void _deleteList(String id) {
    _controller.deleteCustomList(id);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<CustomList> customLists = _controller.getCustomLists();

    return Scaffold(
      appBar: AppBar(title: const Text('Custom Lists'), 
        centerTitle: true,
        automaticallyImplyLeading: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontFamily: 'Arimo',
          fontWeight: FontWeight.w700,
          height: 1.11,
          letterSpacing: -1.80,
        ),),
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
                            title: Text(customList.name),
                            subtitle: Text(
                              '${customList.items.length} item(s)',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
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
          };
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
