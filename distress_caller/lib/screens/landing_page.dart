import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
    String distressType = 'For Me';

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
                    'Issuing an alert will notify all first responders in your vicinity.',
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Text(
                          'For Me',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                      Switch(
                        value: distressType == 'For Someone Else',
                        onChanged: (value) {
                          setState(() {
                            distressType = value ? 'For Someone Else' : 'For Me';
                          });
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(
                          'For Someone Else',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ],
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
                  onPressed: () async {
                    final success = await _sendDistressCall(context, distressType);
                    if (success) {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/distress');
                    } else {
                      Navigator.pop(context);
                    }
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

  Future<bool> _sendDistressCall(BuildContext context, String distressType) async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    final phone = prefs.getString('phone');
    final email = prefs.getString('email');
    final age = prefs.getString('age');
    final gender = prefs.getString('gender');
    final bloodType = prefs.getString('bloodType');
    final medicalHistory = prefs.getString('medicalHistory');

    final userInfo = {
      "profile_photo": "",
      "name": name,
      "phone": phone,
      "additional_data": {
        "email": email,
        "age": age,
        "gender": gender,
        "blood_type": bloodType,
        "emergency_contacts": [
          {"name": "Jane Doe", "phone": "+0987654321"}
        ],
        "medical_history": medicalHistory,
      }
    };

    final distressData = {
      "location": {"latitude": 0.0, "longitude": 0.0}, // Replace with actual location data
      "type": "Medical Emergency"
    };

    final body = jsonEncode({
      "user_info": userInfo,
      "distress_data": distressData,
      "distress_type": distressType
    });

    final response = await http.post(
      Uri.parse('https://example.com/api/distress'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Distress call sent successfully!')),
      );

      // Encode profile photo as Base64 and patch the initial request
      final profilePhoto = prefs.getString('profilePhoto');
      if (profilePhoto != null) {
        final bytes = await File(profilePhoto).readAsBytes();
        final profilePhotoBase64 = base64Encode(bytes);

        final patchBody = jsonEncode({
          "profile_photo": profilePhotoBase64,
        });

        await http.patch(
          Uri.parse('https://example.com/api/distress/${jsonDecode(response.body)['id']}'),
          headers: {'Content-Type': 'application/json'},
          body: patchBody,
        );
      }
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send distress call.')),
      );
      return false;
    }
  }
}