import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DistressInProgressPage extends StatefulWidget {
  const DistressInProgressPage({super.key});

  @override
  DistressInProgressPageState createState() => DistressInProgressPageState();
}

class DistressInProgressPageState extends State<DistressInProgressPage> {
  late Future<List<Map<String, String>>> _volunteersFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final distressId = ModalRoute.of(context)?.settings.arguments as String;
    _volunteersFuture = _fetchVolunteers(distressId);
  }

  Future<List<Map<String, String>>> _fetchVolunteers(String distressId) async {
    final response = await http.get(
      Uri.parse('https://example.com/api/distress/$distressId/volunteers'),
    );
    if (response.statusCode == 200) {
      List<dynamic> volunteerIds = jsonDecode(response.body);
      List<Map<String, String>> volunteers = [];

      for (var id in volunteerIds) {
        final volunteerResponse = await http.get(
          Uri.parse('https://example.com/api/volunteers/$id'),
        );
        if (volunteerResponse.statusCode == 200) {
          Map<String, dynamic> volunteerJson = jsonDecode(volunteerResponse.body);
          volunteers.add({
            'name': volunteerJson['name'] as String,
            'contact': volunteerJson['contact'] as String,
          });
        } else {
          throw Exception('Failed to load volunteer details for ID $id');
        }
      }
      return volunteers;
    } else {
      throw Exception('Failed to load volunteer IDs');
    }
  }

  @override
  Widget build(BuildContext context) {
    final distressId = ModalRoute.of(context)?.settings.arguments as String;

    return WillPopScope(
      onWillPop: () async {
        bool? confirm = await _showConfirmationDialog(context);
        if (confirm == true) {
          final response = await http.delete(
            Uri.parse('https://example.com/api/distress/$distressId'),
          );
          if (response.statusCode == 200) {
            return true;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to mark as resolved. Please try again.'),
              ),
            );
            return false;
          }
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Distress In Progress')),
        body: Column(
          children: [
            SizedBox(height: 20),
            // Call Emergency Services Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                textStyle: TextStyle(fontWeight: FontWeight.bold),
                foregroundColor: Colors.white, // Text color
              ),
              onPressed: () async {
                final Uri url = Uri(scheme: 'tel', path: '112');
                debugPrint('Launching URL: $url');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(Icons.call, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Dial Emergency Services @ 112'),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Volunteers List
            Expanded(
              /* child: ListView.builder(
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
              ), */
              child: FutureBuilder<List<Map<String, String>>>(
                future: _volunteersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } 
                  else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Failed to load first-responders'),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _volunteersFuture = _fetchVolunteers(distressId);
                              });
                            },
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } 
                  else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    Future.delayed(Duration(seconds: 2), () {
                      setState(() {
                        _volunteersFuture = _fetchVolunteers(distressId);
                      });
                    });
                    return Center(child: Text('Finding first-responders near you...'));
                  } 
                  else {
                    Future.delayed(Duration(seconds: 10), () {
                      setState(() {
                        _volunteersFuture = _fetchVolunteers(distressId);
                      });
                    });
                    final volunteers = snapshot.data!;
                    return ListView.builder(
                      itemCount: volunteers.length,
                      itemBuilder: (context, index) {
                        final volunteer = volunteers[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(volunteer['name']!),
                            subtitle: Text(volunteer['contact']!),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
                textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              foregroundColor: Colors.white, // Text color
              minimumSize: Size(double.infinity, 50), // Full-width button
            ),
            onPressed: () async {
              bool? confirm = await _showConfirmationDialog(context);
              if (confirm == true) {
                final response = await http.delete(
                  Uri.parse('https://example.com/api/distress/$distressId'),
                );
                if (response.statusCode == 200) {
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to mark as resolved. Please try again.'),
                    ),
                  );
                }
              }
            },
            child: Text('Mark as Resolved'),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Resolution'),
          content: Text('Are you sure you want to mark this as resolved?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
