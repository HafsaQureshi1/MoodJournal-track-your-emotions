import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

// Add this import for FirebaseOptions
import 'package:fl_chart/fl_chart.dart'; // For bar chart representation

import 'package:flutter/foundation.dart' show kIsWeb;
import 'moodtrack.dart';

void main() async {
  // Ensure Firebase is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Conditionally initialize Firebase based on the platform
  if (kIsWeb) {
    // Firebase configuration for web (replace with your actual web config)
    await Firebase.initializeApp(
      options: const FirebaseOptions(
       
  apiKey: "AIzaSyAoTZUrYs5dMBJBo9TQhtCI2M1dIebBqwM",
  authDomain: "moodjournal123.firebaseapp.com",
  projectId: "moodjournal123",
  storageBucket: "moodjournal123.firebasestorage.app",
  messagingSenderId: "789456357459",
  appId: "1:789456357459:web:1de65ab8096081d0125ea6",
  measurementId: "G-LYZP4DWYGN"

      ),
    );
  } else {
    // Firebase initialization for Android or other platforms
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'Mental ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(), // Set SplashScreen as the initial screen
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the AuthScreen after a 3-second delay
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Dark purple background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Emoji-representing image
            Image.asset(
              'assets/logo.jpg', // Replace with your image asset path
              width: 140,
              height: 140,
            ),
            const SizedBox(height: 0),
            const Text(
              'Mood Journal',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 1, 24, 85),
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Track your mood, reflect, and connect',
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(179, 12, 0, 175),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); // For Signup only
  bool isSignup = false;

  // Signup Function
  Future<void> signup() async {
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        'email': userCredential.user?.email,
        'createdAt': Timestamp.now(),
        'name': _nameController.text.trim(),
        'profilePic': '',
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (error) {
      showErrorDialog('Error signing up');
    }
  }

  // Login Function
  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (error) {
      showErrorDialog('Error logging in');
    }
  }

  // Show error dialog
  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Dark purple background
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(29.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Logo image at the top
            Image.asset(
              'assets/logo.jpg', // Replace with your logo asset path
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 0),
            // Login or Sign Up title
            Text(
              isSignup ? 'Create your Account' : 'Login to your Account',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            // Email TextField
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Color.fromARGB(255, 179, 179, 179))
                ),
                hintText: 'Enter your email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            // Password TextField
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                 borderSide: const BorderSide(color: Color.fromARGB(255, 179, 179, 179))
                 ),
                hintText: 'Enter your password',
              ),
              obscureText: true,
            ),
            if (isSignup) ...[
              const SizedBox(height: 20),
              // Full Name TextField
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                     borderSide: const BorderSide(color: Color.fromARGB(255, 179, 179, 179))
               ),
                  hintText: 'Enter your full name',
                ),
              ),
            ],
            const SizedBox(height: 20),
            // Elevated Button
            ElevatedButton(
              onPressed: isSignup ? signup : login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 8, 92), // Dark blue color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                minimumSize: const Size(320, 50),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Text(
                isSignup ? 'Sign Up' : 'Login',
                style: const TextStyle(fontSize: 18,color: Color.fromARGB(255, 255, 255, 255)),
              ),
            ),
            const SizedBox(height: 10),
            // Toggle between Login and Sign Up
            TextButton(
              onPressed: () {
                setState(() {
                  isSignup = !isSignup; // Toggle between signup and login
                });
              },
              child: Text(
                isSignup ? 'Already have an account? Login' : 'Create a new account',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
class MoodWeekView extends StatefulWidget {
  const MoodWeekView({super.key});

  @override
  _MoodWeekViewState createState() => _MoodWeekViewState();
}

class _MoodWeekViewState extends State<MoodWeekView> {
  Map<String, String> moodData = {};
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchMoodDataForWeek();
    
    // Set up periodic refresh
    _refreshTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _fetchMoodDataForWeek();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(0, 196, 196, 196),
        border: Border.all(
          color: const Color.fromARGB(255, 255, 255, 255),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(7, (index) {
            final weekday = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index];
            final moodImage = moodData[weekday] ?? 'assets/neutral.png';

            return Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekday,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Image.asset(
                    moodImage,
                    width: 30,
                    height: 30,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Future<void> _fetchMoodDataForWeek() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print("User not logged in");
      return;
    }

    // Get current date
    final now = DateTime.now();
    
    // Calculate the most recent Monday (even if today is Monday)
    final startOfWeek = now.subtract(Duration(days: (now.weekday - 1)));
    // Set time to start of day
    final weekStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    // Calculate end of week (Sunday) and set to end of day
    final weekEnd = weekStart.add(const Duration(days: 6))
        .add(const Duration(hours: 23, minutes: 59, seconds: 59));

    // Fetch journal entries for the week
    final journalEntries = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('journals')
        .where('timestamp', isGreaterThanOrEqualTo: weekStart)
        .where('timestamp', isLessThanOrEqualTo: weekEnd)
        .orderBy('timestamp', descending: true)
        .get();

    // Initialize mood data for each weekday
    Map<String, String> tempMoodData = {
      'Mon': 'assets/neutral.png',
      'Tue': 'assets/neutral.png',
      'Wed': 'assets/neutral.png',
      'Thu': 'assets/neutral.png',
      'Fri': 'assets/neutral.png',
      'Sat': 'assets/neutral.png',
      'Sun': 'assets/neutral.png',
    };

    for (var entry in journalEntries.docs) {
      var data = entry.data();
      String mood = data['mood'] ?? '';
      DateTime timestamp = (data['timestamp'] as Timestamp).toDate();
      String dayOfWeek = DateFormat('EEE').format(timestamp);

      if (tempMoodData[dayOfWeek] == 'assets/neutral.png') {
        switch (mood) {
          case 'Angry':
            tempMoodData[dayOfWeek] = 'assets/angry.png';
            break;
          case 'Sad':
            tempMoodData[dayOfWeek] = 'assets/sad.png';
            break;
          case 'Excited':
          case 'Happy':
            tempMoodData[dayOfWeek] = 'assets/excited.png';
            break;
          default:
            tempMoodData[dayOfWeek] = 'assets/neutral.png';
        }
      }
    }

    if (mounted) {
      setState(() {
        moodData = tempMoodData;
      });
    }
  }
}
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EE, MMMM d').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 6, 0, 92),
       scrolledUnderElevation: 0, // Prevents color change when scrolling

         title: Container(
          
      padding: const EdgeInsets.only(left: 8, bottom: 16, top: 16,right: 0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(0, 255, 255, 255), // or any color you prefer
        borderRadius: BorderRadius.circular(20), // 10 pixel rounded corners
      ),
      child: const Text(
        "Hello User",
        style: TextStyle(fontWeight: FontWeight.bold,color: Color.fromARGB(255, 255, 255, 255)),
      ),),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
      padding: const EdgeInsets.only(left: 16, bottom: 8, right: 16,top: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255), // or any color you prefer
        borderRadius: BorderRadius.circular(30), // 10 pixel rounded corners
      ),
      child:  Text(
        formattedDate,
        style: const TextStyle(fontWeight: FontWeight.bold,color: Color.fromARGB(255, 6, 0, 92)),
      ),),
          ),
        ],
      ),
      body: _currentIndex == 0
          ? const Column(
              children: [
                // MoodWeekView always shown at the top on home screen
                SizedBox(height: 30),
                
                Text("Weekly Updated Mood", style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                 SizedBox(height: 0),
               
                MoodWeekView(),
                
                // MoodChartScreen shown below MoodWeekView on home screen
                Expanded(child: MoodChartScreen()),
              ],
            )
          : _currentIndex == 1
              ? const JournalEntriesScreen()  // Show only JournalEntriesScreen when selected
              : const Moodboost(),      // Show GroupChatScreen when selected
      bottomNavigationBar: BottomNavigationBar(
         selectedItemColor: const Color.fromARGB(255, 255, 255, 255), // Changes both icon and label color for selected item
  unselectedItemColor: const Color.fromARGB(255, 186, 207, 253), // Changes both icon and label color for unselected items
  
        backgroundColor: const Color.fromARGB(255, 6, 0, 92),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Color.fromARGB(255, 255, 255, 255),),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book, color: Color.fromARGB(255, 255, 255, 255),),
            label: "Journal Entries",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, color: Color.fromARGB(255, 255, 255, 255),),
            label: "Moodboost",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MoodTrackingScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
class MoodChartScreen extends StatefulWidget {
  const MoodChartScreen({super.key});

  @override
  _MoodChartScreenState createState() => _MoodChartScreenState();
}
class _MoodChartScreenState extends State<MoodChartScreen> {
  // This will hold the mood data
  Map<String, double> moodData = {'happy': 0.0, 'sad': 0.0, 'angry': 0.0, 'excited': 0.0};
  late StreamSubscription<QuerySnapshot> _subscription;

  // Mood colors map
  final Map<String, Color> moodColors = {
    'happy': Colors.green,
    'sad': Colors.blue,
    'angry': Colors.red,
    'excited': Colors.yellow,
  };

  @override
  void initState() {
    super.initState();
    _subscribeToJournalEntries();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  // Subscribe to journal entries and update mood data
  void _subscribeToJournalEntries() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Exit if user is not logged in.

    final String userId = user.uid;
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('journals')
        .snapshots()
        .listen((snapshot) {
      print("Snapshot size: ${snapshot.docs.length}");
      for (var doc in snapshot.docs) {
        print("Document data: ${doc.data()}");
      }

      if (snapshot.docs.isNotEmpty) {
        final newMoodData = <String, double>{'happy': 0.0, 'sad': 0.0, 'angry': 0.0, 'excited': 0.0};
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final mood = (data['mood'] ?? '').toLowerCase(); // Normalize to lowercase
          print("Mood fetched (normalized): $mood");

          if (newMoodData.containsKey(mood)) {
            newMoodData[mood] = (newMoodData[mood]! + 1);
          } else {
            print("Unknown mood key: $mood");
          }
        }

        setState(() {
          moodData = newMoodData;
          print("Updated Mood Data: $moodData");
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        
        children: [
  const SizedBox(height: 16),
  const Text(
    "Mood Chart",
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ),
  const SizedBox(height: 16),

  // Mood Chart with Emoji and Border
  Container(
    
    decoration: BoxDecoration(
       color: const Color.fromARGB(127, 248, 251, 255), // Border color
      border: Border.all(
        color: const Color.fromARGB(255, 219, 219, 219), // Border color
        width: 1.0, // Border width
      ),
      borderRadius: BorderRadius.circular(8.0), // Rounded corners
    ),
    padding: const EdgeInsets.all(16.0), // Padding inside the border
    child: SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          maxY: 5, // Adjust this based on the max mood value
          barGroups: moodData.entries.map((entry) {
            final moodIndex = moodData.keys.toList().indexOf(entry.key);
            final moodValue = entry.value.toDouble();
            final moodColor = moodColors[entry.key] ?? Colors.grey; // Default color for unknown moods
            return BarChartGroupData(
              x: moodIndex,
              barRods: [
                BarChartRodData(
                  toY: moodValue, // Ensure it fits within maxY
                  color: moodColor,
                  width: 20, // Adjust width to fit better within the available space
                  borderRadius: BorderRadius.zero, // Optional: Adjust border radius if needed
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final int index = value.toInt();
                  final mood = moodData.keys.toList()[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      mood,
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    ),
  ),
  const SizedBox(height: 16),


          const SizedBox(height: 16),

          // Journal Entries Section
          const Text(
            "Journal Entries",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .collection('journals')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No journal entries found."));
              }

              final journalEntries = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return {
                  'date': (data['timestamp'] != null
                      ? DateTime.fromMillisecondsSinceEpoch(
                              data['timestamp'].millisecondsSinceEpoch)
                          .toLocal()
                          .toString()
                          .split(' ')[0]
                      : 'Unknown Date'),
                  'mood': data['mood'] ?? 'No mood specified',
                  'emotion': data['emotion'] ?? 'No emotion specified',
                  'reasons': data['reasons'] ?? 'No reason provided',
                  'notes': data['notes'] ?? 'No notes available.',
                };
              }).toList();

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: journalEntries.length,
                itemBuilder: (context, index) {
                  final entry = journalEntries[index];
                 return Card(
  color: const Color.fromARGB(255, 6, 0, 92),
  elevation: 2.0,
  margin: const EdgeInsets.symmetric(vertical: 8.0),
  child: Padding(  // Added padding wrapper
    padding: const EdgeInsets.all(16.0),  // Padding around all content
    child: ListTile(
      title: Text(
        "Your Mood was ${entry['mood']}", 
        style: const TextStyle(
          fontSize: 16,
          color: Color.fromARGB(255, 255, 255, 255),
          fontWeight: FontWeight.bold
        )
      ),
      contentPadding: EdgeInsets.zero,  // Remove ListTile's default padding
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ 
          const SizedBox(height: 8),  // Spacing after title
          Text(
            "You felt : ${entry['emotion']}", 
            style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255))
          ),
          const SizedBox(height: 4),  // Spacing between items
          Text(
            "Reasons to felt that : ${entry['reasons']}", 
            style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255))
          ),
          const SizedBox(height: 4),
          Text(
            "Notes: ${entry['notes']}", 
            style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255))
          ),
          const SizedBox(height: 4),
          Text(
            "On : ${entry['date']}", 
            style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255))
          ),
        ],
      ),
    ),
  ),
);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class JournalEntriesScreen extends StatefulWidget {
  const JournalEntriesScreen({super.key});

  @override
  _JournalEntriesScreenState createState() => _JournalEntriesScreenState();
}

class _JournalEntriesScreenState extends State<JournalEntriesScreen> {
  late Stream<QuerySnapshot> _entriesStream;

  @override
  void initState() {
    super.initState();
    // Ensure the user is logged in
    if (FirebaseAuth.instance.currentUser != null) {
      final String userId = FirebaseAuth.instance.currentUser!.uid;
      // Query the journals subcollection inside the user document
      _entriesStream = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('journals')
          .snapshots();
    } else {
      // Redirect to the login screen or show a message
      _entriesStream = const Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            const Text(
              "Your Journal Entries",
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _entriesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No journal entries found.'));
                  }

                  var journalEntries = snapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: journalEntries.length,
                    itemBuilder: (context, index) {
                      var entry = journalEntries[index];
                      var data = entry.data() as Map<String, dynamic>;

                      // Safely extract fields with default values
                      String mood = data['mood'] ?? 'Unknown mood';
                      List<dynamic> emotions = data['emotion'] ?? [];
                      List<dynamic> reasons = data['reasons'] ?? [];
                      String notes = data['notes'] ?? 'No notes';
                      var timestamp = data['timestamp'];

                      // Convert the timestamp to a human-readable date
                      String formattedDate = timestamp != null
                          ? DateTime.fromMillisecondsSinceEpoch(
                                  timestamp.millisecondsSinceEpoch)
                              .toLocal()
                              .toString()
                              .split(' ')[0]
                          : 'No Date';

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: const Color.fromARGB(255, 255, 255, 255),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your Mood was $mood",
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "You felt: ${emotions.join(', ')}",
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Reasons: ${reasons.join(', ')}",
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Notes: $notes",
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Date: $formattedDate",
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 75, 75, 75),
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class Moodboost extends StatelessWidget {
  const Moodboost({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Mood Boost Activities",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
  width: 300,
  height: 50, // Set the desired width
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MemoryGame()),
              );// Save the notes when the button is pressed
    },style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 0, 6, 92),
       shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // Adjust the value for desired rounding
      ), // Set the background color to blue
    ),
     child: const Text('Play Memory  game',style:TextStyle(fontSize: 18,color: Color.fromARGB(255, 255, 255, 255))),
    
    
          
          
  )
          ),
          const SizedBox(height: 10),
          SizedBox(
  width: 300,
  height: 50, // Set the desired width
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ColorGuessingGame()),
              );// Save the notes when the button is pressed
    },style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 0, 6, 92),
       shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // Adjust the value for desired rounding
      ), // Set the background color to blue
    ),
     child: const Text('Play Coloring guessing game',style:TextStyle(fontSize: 18,color: Color.fromARGB(255, 255, 255, 255))),
    
    
          
          
  )
          ),
        ],
      ),
    );
  }
}
class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  _MemoryGameState createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  final List<String> _cardImages = [
    
    'assets/disgust.png', 'assets/disgust.png',
    'assets/surprised.png', 'assets/surprised.png',
    'assets/smile.png', 'assets/smile.png',
    'assets/fear.png', 'assets/fear.png',
    'assets/excited.png', 'assets/excited.png'
  ];

  List<String> _shuffledCards = [];
  List<bool> _cardStates = [];
  final List<int> _flippedIndices = [];
  int _numMoves = 0;
  bool _gameOver = false;
  final int _maxMoves = 16; // Maximum number of moves allowed

  @override
  void initState() {
    super.initState();
    _shuffledCards = List.from(_cardImages);
    _shuffledCards.shuffle(Random());
    _cardStates = List.generate(_shuffledCards.length, (index) => false);
  }

  void _flipCard(int index) {
    if (_gameOver || _cardStates[index]) return;

    setState(() {
      _cardStates[index] = true;
      _flippedIndices.add(index);
      _numMoves++;
    });

    if (_flippedIndices.length == 2) {
      if (_shuffledCards[_flippedIndices[0]] == _shuffledCards[_flippedIndices[1]]) {
        // Cards match, keep them visible
        _flippedIndices.clear();
      } else {
        // Cards don't match, flip back after a brief delay
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            _cardStates[_flippedIndices[0]] = false;
            _cardStates[_flippedIndices[1]] = false;
            _flippedIndices.clear();
          });
        });
      }
    }

    if (_numMoves >= _maxMoves) {
      // Game over if moves exceed the limit
      _showGameOver();
    }

    if (_cardStates.where((state) => state == true).length == _shuffledCards.length) {
      // All cards matched
      _showCongratulations();
    }
  }

  void _showCongratulations() {
    setState(() {
      _gameOver = true;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Congratulations!'),
        content: Text('You completed the game in $_numMoves moves!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void _showGameOver() {
    setState(() {
      _gameOver = true;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over!'),
        content: Text('You exceeded $_maxMoves moves. Try again!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      _gameOver = false;
      _numMoves = 0;
      _shuffledCards.shuffle(Random());
      _cardStates = List.generate(_shuffledCards.length, (index) => false);
      _flippedIndices.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memory Game',style:TextStyle(color: Color.fromARGB(255, 255, 255, 255))), iconTheme: const IconThemeData(
    color: Colors.white, // Set the back icon color to white
  ),backgroundColor: const Color.fromARGB(255, 0, 6, 92),),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_gameOver)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Moves: $_numMoves / $_maxMoves',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemCount: _shuffledCards.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _flipCard(index),
                child: Card(
                  color: _cardStates[index] ? Colors.white : Colors.blue,
                  child: _cardStates[index]
                      ? Image.asset(_shuffledCards[index], fit: BoxFit.cover)
                      : const Icon(Icons.question_mark, size: 50),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ColorGuessingGame extends StatefulWidget {
  const ColorGuessingGame({super.key});

  @override
  _ColorGuessingGameState createState() => _ColorGuessingGameState();
}

class _ColorGuessingGameState extends State<ColorGuessingGame> {
  final List<Color> _colors = [Colors.red, Colors.green, Colors.blue, Colors.yellow, Colors.purple, Colors.orange, Colors.pink];
  final List<String> _colorNames = ['Red', 'Green', 'Blue', 'Yellow', 'Purple', 'Orange', 'Pink'];

  Color? _displayedColor;
  String? _correctColorName;
  int _score = 0;
  int _attemptsLeft = 3;
  bool _isGameOver = false;

  void _startNewRound() {
    if (_attemptsLeft <= 0) {
      _showGameOverDialog();
      return;
    }

    // Pick a random color and its name
    final randomIndex = Random().nextInt(_colors.length);
    setState(() {
      _displayedColor = _colors[randomIndex];
      _correctColorName = _colorNames[randomIndex];
    });

    // Show the color for 1 second before displaying the options
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _displayedColor = null;  // Hide the color after 1 second
      });
      _showColorOptions();
    });
  }

  void _showColorOptions() {
    // Pick 2 wrong options and shuffle with the correct one
    List<String> options = List.from(_colorNames)..shuffle();
    if (!options.contains(_correctColorName)) {
      options[Random().nextInt(3)] = _correctColorName!;
    }

    _showOptionsDialog(options);
  }
void _showOptionsDialog(List<String> options) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(
        'Choose the correct color',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: options
            .map((option) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 16), // Add spacing between buttons
                  child: ElevatedButton(
                    onPressed: () => _onOptionSelected(option),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 6, 92), // Customize button color
                      padding: const EdgeInsets.symmetric(vertical: 15.0,horizontal: 26), // Increase button height
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Rounded corners
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(
                      option,
                      style: const TextStyle(
                        color: Colors.white, // Set text color for better contrast
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Add rounded corners to the dialog
      ),
      contentPadding: const EdgeInsets.all(20), // Add padding around content
    ),
  );
}

  void _onOptionSelected(String selectedColor) {
    setState(() {
      if (selectedColor == _correctColorName) {
        _score++;
      } else {
        _attemptsLeft--;
      }

      if (_attemptsLeft > 0) {
        Navigator.of(context).pop();
        _startNewRound();
      } else {
        Navigator.of(context).pop();
        _showGameOverDialog();
      }
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Your score: $_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _score = 0;
                _attemptsLeft = 5;
                _isGameOver = false;
              });
              _startNewRound();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
    setState(() {
      _isGameOver = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _startNewRound();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Color guessing game',style:TextStyle(color: Color.fromARGB(255, 255, 255, 255))), iconTheme: const IconThemeData(
    color: Colors.white, // Set the back icon color to white
  ),backgroundColor: const Color.fromARGB(255, 0, 6, 92),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isGameOver)
              Text(
                'Score: $_score\nAttempts Left: $_attemptsLeft',
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
            if (_displayedColor != null)
              Container(
                height: 200,
                width: 200,
                color: _displayedColor,
                child: const Center(
                  child: Text(
                    'Color Displayed!',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            if (_displayedColor == null)
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
