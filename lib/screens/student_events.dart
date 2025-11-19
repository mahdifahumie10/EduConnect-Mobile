import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentEventsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var docs = snapshot.data!.docs;
          if (docs.isEmpty) return Center(child: Text('No events yet'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var event = docs[index];
              String eventName = event['eventName'] ?? '';
              String description = event['description'] ?? '';
              String dateTime = event['dateTime'] ?? '';

              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(eventName),
                  subtitle: Text('$description\nDate: $dateTime'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
