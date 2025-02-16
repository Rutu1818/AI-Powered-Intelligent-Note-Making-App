import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'transcript_detail_screen.dart';
import 'upload_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "User";
  TextEditingController searchController = TextEditingController();
  List<DocumentSnapshot> allLectures = [];
  List<DocumentSnapshot> filteredLectures = [];

  @override
  void initState() {
    super.initState();
    fetchUserName();
    fetchLectures();
  }

  void fetchUserName() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? user.email!.split('@')[0];
      });
    }
  }

  void fetchLectures() async {
    FirebaseFirestore.instance
        .collection('lectures')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        allLectures = snapshot.docs;
        filteredLectures = allLectures; // Initially show all
      });
    });
  }

  void filterLectures(String query) {
    setState(() {
      filteredLectures = allLectures
          .where((doc) => doc['title'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFeeedf2),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, $userName!",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "My Notes",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF3b3b3b)),
                  ),
                ],
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: const DecorationImage(
                    image: AssetImage("assets/images/1.jpg"),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 🔍 Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFFF4F6FD),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.indigo),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: filterLectures,
                    decoration: const InputDecoration(
                      hintText: "Search Lectures",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 📌 Recent Notes Title
          const Text(
            "Recent Notes",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3b3b3b)),
          ),
          const SizedBox(height: 10),

          // 📄 Lecture List (Fetched from Firestore)
          if (filteredLectures.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No lectures found"))),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredLectures.length,
            itemBuilder: (context, index) {
              var lecture = filteredLectures[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TranscriptDetailScreen(lecture)),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6, spreadRadius: 2)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lecture['title'],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Last edited: ${lecture['timestamp'].toDate().toString().substring(0, 10)}",
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.indigo.shade300, size: 16),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 30),

          // 📤 Upload Button
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UploadScreen()));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.indigo,
              ),
              child: const Center(
                child: Text("Upload Now", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
