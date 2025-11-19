import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LecturerClassesPage extends StatefulWidget {
  @override
  _LecturerClassesPageState createState() => _LecturerClassesPageState();
}

class _LecturerClassesPageState extends State<LecturerClassesPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController courseController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController dateTimeController = TextEditingController();

  @override
  void dispose() {
    courseController.dispose();
    classController.dispose();
    dateTimeController.dispose();
    super.dispose();
  }

  Future<void> submitClass() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('classes').add({
          'courseName': courseController.text,
          'className': classController.text,
          'dateTime': dateTimeController.text,
          'createdAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Class added successfully!')),
        );

        // Clear fields
        courseController.clear();
        classController.clear();
        dateTimeController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding class: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Class'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {
            Navigator.pop(context); // Back to dashboard
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: courseController,
                decoration: InputDecoration(
                  labelText: 'Course Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the course name' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: classController,
                decoration: InputDecoration(
                  labelText: 'Class Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the class name' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: dateTimeController,
                decoration: InputDecoration(
                  labelText: 'Date & Time (YYYY-MM-DD HH:MM)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter date and time' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: submitClass,
                child: Text('Submit Class'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
