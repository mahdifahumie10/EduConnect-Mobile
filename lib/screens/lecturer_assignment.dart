import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LecturerAssignmentPage extends StatefulWidget {
  @override
  _LecturerAssignmentPageState createState() => _LecturerAssignmentPageState();
}

class _LecturerAssignmentPageState extends State<LecturerAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController courseController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();

  @override
  void dispose() {
    courseController.dispose();
    descController.dispose();
    dueDateController.dispose();
    super.dispose();
  }

  Future<void> submitAssignment() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('assignments').add({
        'courseName': courseController.text,
        'description': descController.text,
        'dueDate': dueDateController.text,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Assignment added successfully!')));
      courseController.clear();
      descController.clear();
      dueDateController.clear();
    }
  }

  Future<void> updateAssignment(String docId, Map<String, dynamic> data) async {
    courseController.text = data['courseName'];
    descController.text = data['description'];
    dueDateController.text = data['dueDate'];

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Update Assignment'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: courseController,
                decoration: InputDecoration(labelText: 'Course Name'),
              ),
              TextFormField(
                controller: descController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: dueDateController,
                decoration: InputDecoration(labelText: 'Due Date (YYYY-MM-DD)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('assignments')
                  .doc(docId)
                  .update({
                'courseName': courseController.text,
                'description': descController.text,
                'dueDate': dueDateController.text,
              });
              Navigator.pop(context);
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteAssignment(String docId) async {
    await FirebaseFirestore.instance.collection('assignments').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assignments'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: courseController,
                    decoration: InputDecoration(labelText: 'Course Name'),
                  ),
                  TextFormField(
                    controller: descController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  TextFormField(
                    controller: dueDateController,
                    decoration: InputDecoration(labelText: 'Due Date (YYYY-MM-DD)'),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: submitAssignment,
                    child: Text('Add Assignment'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('assignments').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                var docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var assignment = docs[index];
                    return ListTile(
                      title: Text(assignment['courseName']),
                      subtitle: Text('${assignment['description']} | Due: ${assignment['dueDate']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.orange),
                            onPressed: () => updateAssignment(assignment.id, assignment.data()),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteAssignment(assignment.id),
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
