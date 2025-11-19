import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClubEventsPage extends StatefulWidget {
  @override
  _ClubEventsPageState createState() => _ClubEventsPageState();
}

class _ClubEventsPageState extends State<ClubEventsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> addEvent() async {
    if (nameController.text.isEmpty ||
        descController.text.isEmpty ||
        dateController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('events').add({
      'eventName': nameController.text,
      'description': descController.text,
      'dateTime': dateController.text,
      'createdBy': 'Club Leader',
      'createdAt': Timestamp.now(),
    });

    nameController.clear();
    descController.clear();
    dateController.clear();
  }

  Future<void> updateEvent(String docId, Map<String, dynamic> data) async {
    nameController.text = data['eventName'];
    descController.text = data['description'];
    dateController.text = data['dateTime'];

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Update Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Event Name')),
            TextField(controller: descController, decoration: InputDecoration(labelText: 'Description')),
            TextField(controller: dateController, decoration: InputDecoration(labelText: 'Date & Time')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('events').doc(docId).update({
                'eventName': nameController.text,
                'description': descController.text,
                'dateTime': dateController.text,
              });
              Navigator.pop(context);
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteEvent(String docId) async {
    await FirebaseFirestore.instance.collection('events').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(controller: nameController, decoration: InputDecoration(labelText: 'Event Name')),
                TextField(controller: descController, decoration: InputDecoration(labelText: 'Description')),
                TextField(controller: dateController, decoration: InputDecoration(labelText: 'Date & Time')),
                SizedBox(height: 12),
                ElevatedButton(onPressed: addEvent, child: Text('Add Event')),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('events').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                var docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var event = docs[index];
                    return ListTile(
                      title: Text(event['eventName']),
                      subtitle: Text('${event['description']} | ${event['dateTime']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.orange),
                            onPressed: () => updateEvent(event.id, event.data()),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteEvent(event.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
