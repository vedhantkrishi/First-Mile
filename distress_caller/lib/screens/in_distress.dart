import 'package:flutter/material.dart';

class DistressInProgressPage extends StatelessWidget {
  const DistressInProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Distress In Progress')),
      body: Column(
        children: [
          // Call Emergency Services Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // Emergency services logic
            },
            child: Text('Call Emergency Services'),
          ),

          // Volunteers List
          Expanded(
            child: ListView.builder(
              itemCount: 3, // Replace with actual volunteer list size
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text('Volunteer ${index + 1}'),
                    subtitle: Text('Contact info here'),
                  ),
                );
              },
            ),
          ),

          // Mark as Resolved Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Mark as Resolved'),
          ),
        ],
      ),
    );
  }
}
