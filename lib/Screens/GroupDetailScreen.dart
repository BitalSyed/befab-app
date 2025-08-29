import 'package:flutter/material.dart';

class GroupDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Groups")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network("https://via.placeholder.com/300x150", fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: Text("Sweat & Smile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                ElevatedButton(onPressed: () {
                  
                }, child: Text("Join")),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text("A place for fitness enthusiasts..."),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Text("156 posts • 3.3k members • 89 events", style: TextStyle(color: Colors.grey)),
          ),
          TabBarSection(),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {}, child: Icon(Icons.add)),
      bottomNavigationBar: buildBottomNavBar(2, (_) {}),
    );
  }
}

class TabBarSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: const [
          TabBar(
            labelColor: Colors.black,
            tabs: [
              Tab(text: "Posts"),
              Tab(text: "Members"),
              Tab(text: "Events"),
            ],
          ),
          SizedBox(height: 150, child: Center(child: Text("Tab content here..."))),
        ],
      ),
    );
  }
}
BottomNavigationBar buildBottomNavBar(int selectedIndex, Function(int) onTap) {
  return BottomNavigationBar(
    currentIndex: selectedIndex,
    onTap: onTap,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Health"),
      BottomNavigationBarItem(icon: Icon(Icons.group), label: "Groups"),
      BottomNavigationBarItem(icon: Icon(Icons.message), label: "Message"),
    ],
  );
}