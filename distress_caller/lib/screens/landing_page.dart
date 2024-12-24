import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Distress App'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              // Navigate to Profile Page
              // Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showConfirmationDialog(context),
          child: Text('Distress Call'),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    bool callEmergencyServices = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Confirm Distress Call'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Issuing an alert will notify all first responders.',
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: callEmergencyServices,
                        onChanged: (value) {
                          setState(() {
                            callEmergencyServices = value ?? false;
                          });
                        },
                      ),
                      Text(
                        'Call emergency services',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
                TextButton(
                  onPressed: () {
                    // Navigate to distress page
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/distress');
                  },
                  child: Text('CONFIRM'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}