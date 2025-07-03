import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoodTrackingScreen extends StatefulWidget {
  const MoodTrackingScreen({super.key});

  @override
  _MoodTrackingScreenState createState() => _MoodTrackingScreenState();
}

class _MoodTrackingScreenState extends State<MoodTrackingScreen> {
  String? selectedMood;
  List<String> selectedEmotions = [];
  List<String> selectedReasons = [];
  String notes = '';

  final PageController _pageController = PageController();

  void goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void goToPreviousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void saveJournalEntry() {
    if (selectedMood != null && selectedReasons.isNotEmpty) {
      addJournalEntry(
        selectedMood!,
        selectedEmotions,
        selectedReasons,
        notes,
      );
      Navigator.pop(context);
    } else {
      // Handle missing mood or reasons (show an error or alert)
    }
  }

  void addJournalEntry(String mood, List<String> emotions, List<String> reasons, String notes) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please log in to save your journal entry.")),
        );
      }
      return;
    }

    final userId = user.uid;
    try {
      // Reference to the user's journals subcollection
      final journalsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('journals');

      // Add the journal entry to Firestore
      await journalsRef.add({
        'mood': mood,
        'emotion': emotions,
        'reasons': reasons,
        'notes': notes,
        'timestamp': FieldValue.serverTimestamp(), // Add a timestamp for sorting
      });

      if (mounted) {
        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Journal entry saved successfully.")),
        );

        // Navigate back only after successful save
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        // Show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save entry: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(title: const Text('Mood Tracking',style: TextStyle
      (color: Color.fromARGB(255, 255, 255, 255)),),backgroundColor: const Color.fromARGB(255, 0, 6, 92), iconTheme: const IconThemeData(
    color: Colors.white, // Set the back icon color to white
  ),),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Screen1(
            onNext: goToNextPage,
            onMoodSelect: (mood) => setState(() => selectedMood = mood),
            selectedMood: selectedMood,
          ),
          Screen2(
            onNext: goToNextPage,
            onEmotionSelect: (emotion) {
              setState(() {
                if (selectedEmotions.contains(emotion)) {
                  selectedEmotions.remove(emotion);
                } else {
                  selectedEmotions.add(emotion);
                }
              });
            },
            selectedEmotions: selectedEmotions,
          ),
          Screen3(
            onNext: goToNextPage,
            onReasonSelect: (reason) {
              setState(() {
                if (selectedReasons.contains(reason)) {
                  selectedReasons.remove(reason);
                } else {
                  selectedReasons.add(reason);
                }
              });
            },
            selectedReasons: selectedReasons,
          ),
          Screen4(
            onSave: (note) => setState(() {
              notes = note;
              saveJournalEntry();
            }),
          ),
        ],
      ),
      floatingActionButton: _pageController.hasClients &&
              _pageController.page != null &&
              _pageController.page! > 0
          ? FloatingActionButton(
            backgroundColor: const Color.fromARGB(255, 0, 6, 92),
              onPressed: goToPreviousPage,
              child: const Icon(Icons.arrow_back,color: Color.fromARGB(255, 255, 255, 255)),
            )
          : null,
    );
  }
}
class Screen1 extends StatelessWidget {
  final VoidCallback onNext;
  final ValueChanged<String> onMoodSelect;
  final String? selectedMood;

  const Screen1({
    super.key,
    required this.onNext,
    required this.onMoodSelect,
    required this.selectedMood,
  });

  @override
  Widget build(BuildContext context) {
    // Define mood options with corresponding emoji image paths
    final List<Map<String, String>> moods = [
      {'name': 'Angry', 'emoji': 'assets/angry.png'},
      {'name': 'Sad', 'emoji': 'assets/sad.png'},
      {'name': 'Neutral', 'emoji': 'assets/neutral.png'},
      {'name': 'Happy', 'emoji': 'assets/happy.png'},
      {'name': 'Excited', 'emoji': 'assets/excited.png'},
      
    ];

    return SingleChildScrollView( // Wrap the entire screen in a scrollable view
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             const SizedBox(height: 30),
            const Text(
              "1/4 What's your mood now?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            // Centering the emojis horizontally using GridView
            // Constrain the GridView to avoid overflow
            GridView.builder(
              shrinkWrap: true, // Allow GridView to take as much space as its children
              physics: const NeverScrollableScrollPhysics(), // Prevent inner scrolling in GridView
              itemCount: moods.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 2 emojis per row
                crossAxisSpacing: 16, // Horizontal spacing between emojis
                mainAxisSpacing: 16,  // Vertical spacing between emojis
              ),
              itemBuilder: (context, index) {
                final mood = moods[index];
                final isSelected = selectedMood == mood['name'];

                return GestureDetector(
                  onTap: () {
                    onMoodSelect(mood['name']!);
                  },
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          if (isSelected)
                            Container(
                              width: 70, // Circle size
                              height: 70, // Circle size
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.withOpacity(0.2), // Blue background with transparency
                              ),
                            ),
                          Image.asset(
                            mood['emoji']!,
                            width: 50, // Adjust the size of the image
                            height: 50, // Adjust the size of the image
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mood['name']!,
                        style: TextStyle(
                          color: isSelected ? Colors.blue : Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Add some space before the button
            SizedBox(
  width: 350, // Set desired width
  height: 60, // Set desired height
  child: ElevatedButton(
   onPressed: selectedMood != null ? onNext : null, // Disable button if no mood is selected
                 
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 0, 6, 92), // Set the background color to blue
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0), // Rounded corners
      ),
    ),
    child: const Text(
      "Continue",
      style: TextStyle(fontSize: 18, color: Colors.white),
    ),
  ),
),
          ],
        ),
      ),
    );
  }
}


   
class Screen2 extends StatelessWidget {
  final VoidCallback onNext;
  final ValueChanged<String> onEmotionSelect;
  final List<String> selectedEmotions;

  const Screen2({
    super.key,
    required this.onNext,
    required this.onEmotionSelect,
    required this.selectedEmotions,
  });

  @override
Widget build(BuildContext context) {
  // Define emotion options with corresponding emojis
  final List<Map<String, String>> emotions = [
    {'name': 'Angry', 'emoji': 'assets/angry.png'},
    {'name': 'Sad', 'emoji': 'assets/sad.png'},
    {'name': 'Neutral', 'emoji': 'assets/neutral.png'},
    {'name': 'Happy', 'emoji': 'assets/happy.png'},
    {'name': 'Excited', 'emoji': 'assets/excited.png'},
    
    {'name': 'Disgust', 'emoji': 'assets/disgust.png'},
    {'name': 'Fear', 'emoji': 'assets/fear.png'},
    {'name': 'Sleepy', 'emoji': 'assets/sleepy.png'},
    {'name': 'Surprised', 'emoji': 'assets/surprised.png'},
    {'name': 'tired', 'emoji': 'assets/tired.png'},

  ];

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        const Text(
          "2/4 Choose your emotions",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: emotions.map((emotion) {
            final isSelected = selectedEmotions.contains(emotion['name']);
            return GestureDetector(
              onTap: () {
                onEmotionSelect(emotion['name']!);
              },
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isSelected)
                        Container(
                          width: 60, // Circle size
                          height: 60, // Circle size
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromARGB(255, 0, 49, 88),
                          ),
                        ),
                      Image.asset(
                        emotion['emoji']!,
                        width: 40, // Adjust the size of the emoji
                        height: 40, // Adjust the size of the emoji
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    emotion['name']!,
                    style: TextStyle(
                      color: isSelected ? Colors.blue : Colors.black,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
       
         SizedBox(
  width: 350, // Set desired width
  height: 50, // Set desired height
  child: ElevatedButton(
   onPressed: selectedEmotions != null ? onNext : null, // Disable button if no mood is selected
                 style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 0, 6, 92), // Set the background color to blue
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0), // Rounded corners
      ),
    ),
    child: const Text(
      "Continue",
      style: TextStyle(fontSize: 18, color: Colors.white),
    ),
  ),
),
      ],
    ),
  );
}

}
class Screen3 extends StatelessWidget {
  final VoidCallback onNext;
  final ValueChanged<String> onReasonSelect;
  final List<String> selectedReasons;

  const Screen3({
    super.key,
    required this.onNext,
    required this.onReasonSelect,
    required this.selectedReasons,
  });

  @override
  Widget build(BuildContext context) {
    // Adding more reasons without icons
    List<String> reasons = [
  'Work ', 
  'Health ', 
  'Family', 
  'Friendship ', 
  'Financial ', 
   
  'Personal growth ', 
  'Relationships ', 
  'Hobbies ',  
  'Self-care ', 
  'Spirituality ', 
  'Career goals ',  
  
  'Balance ', 
  'Motivation ', 
  
];


    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text("3/4 What are the reasons?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          Wrap(
            spacing: 16.0, // Horizontal space between chips
            runSpacing: 16.0, // Vertical space between chips
            children: reasons.map((reason) {
              return ChoiceChip(
                label: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 3.0),
                  child: Text(reason),
                ),
                selected: selectedReasons.contains(reason),
                onSelected: (selected) {
                  onReasonSelect(reason);
                },
                backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Light background for unselected chips
                selectedColor: const Color.fromARGB(255, 0, 6, 92), // Blue background for selected chips
                 checkmarkColor: Colors.white, // Set the tick color to white
               
                labelStyle: TextStyle(
                  color: selectedReasons.contains(reason) ? Colors.white : Colors.black,fontSize: 16
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                ),
              );
            }).toList(),
          ),
           const SizedBox(height: 20),
         
        SizedBox(
  width: 350, // Set desired width
  height: 60, // Set desired height
  child: ElevatedButton(
    onPressed: onNext,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 0, 6, 92), // Set the background color to blue
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0), // Rounded corners
      ),
    ),
    child: const Text(
      "Continue",
      style: TextStyle(fontSize: 18, color: Colors.white),
    ),
  ),
),

        ],
      ),
    );
  }
}

class Screen4 extends StatelessWidget {
  final ValueChanged<String> onSave;

  const Screen4({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    String tempNotes = ''; // Temporary variable to hold the text while typing

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
         
          const Text(
            "4/4 Add your notes",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          TextField(
            onChanged: (text) {
              tempNotes = text; // Update the temporary variable
            },
            decoration: const InputDecoration(
              hintText: 'Write something...',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 30),
          
         SizedBox(
  width: 900,
  height: 60, // Set the desired width
  child: ElevatedButton(
    onPressed: () {
      onSave(tempNotes); // Save the notes when the button is pressed
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 0, 6, 92),
       shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0), // Adjust the value for desired rounding
      ), // Set the background color to blue
    ),
    
    child: const Text(
      "Save Entry",
      style: TextStyle(fontSize: 18, color: Colors.white),
    ),
  ),
),

        ],
      ),
    );
  }
}
