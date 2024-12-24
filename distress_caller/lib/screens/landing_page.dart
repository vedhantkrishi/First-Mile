import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

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
                  Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Row(
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
                    )
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
                    final distressId = await _sendDistressCall(context, distressType);
                    if (distressId != null) {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/distress', arguments: distressId);
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

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't continue
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, don't continue
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<String?> _sendDistressCall(BuildContext context, String distressType) async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    final phone = prefs.getString('phone');
    final email = prefs.getString('email');
    final age = prefs.getString('age');
    final gender = prefs.getString('gender');
    final bloodType = prefs.getString('bloodType');
    final emergencyContact = prefs.getString('emergencyContact');
    final medicalHistory = prefs.getString('medicalHistory');

    final userInfo = {
      "profilePhoto": "",
      "name": name,
      "phone": phone,
      "additionalData": {
        "email": email,
        "age": age,
        "gender": gender,
        "bloodType": bloodType,
        "emergencyContact": emergencyContact,
        "medicalHistory": medicalHistory,
      }
    };

    Position position = await _getCurrentLocation();
    debugPrint('Location: ${position.latitude}, ${position.longitude}');

    final distressData = {
      "location": {
        "type": "Point",
        "coordinates": [position.latitude, position.longitude]
      },
      "distressType": distressType
    };

    final body = jsonEncode({
      "userInfo": userInfo,
      ...distressData
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

      final distressId = jsonDecode(response.body)['id'];

      // Encode profile photo as Base64 and patch the initial request
      final profilePhoto = prefs.getString('profilePhoto');
      if (profilePhoto != null) {
        final bytes = await File(profilePhoto).readAsBytes();
        final profilePhotoBase64 = base64Encode(bytes);

        final patchBody = jsonEncode({
          "profile_photo": profilePhotoBase64,
        });

        await http.patch(
          Uri.parse('https://example.com/api/distress/$distressId'),
          headers: {'Content-Type': 'application/json'},
          body: patchBody,
        );
      }
      return distressId;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send distress call.')),
      );
      // return null;
      return '0';
    }
  }
}