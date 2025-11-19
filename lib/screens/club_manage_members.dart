import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClubManageMembersPage extends StatefulWidget {
  @override
  _ClubManageMembersPageState createState() => _ClubManageMembersPageState();
}

class _ClubManageMembersPageState extends State<ClubManageMembersPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  // --------------------- ADD MEMBER ---------------------
  Future<void> addMember() async {
    if (firstNameController.text.isEmpty || lastNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both first and last names')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('members').add({
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'createdAt': Timestamp.now(),
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Member added successfully!')));

    firstNameController.clear();
    lastNameController.clear();
  }

  // --------------------- DELETE MEMBER ---------------------
  Future<void> deleteMember(String docId) async {
    await FirebaseFirestore.instance.collection('members').doc(docId).delete();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Member deleted successfully!')));
  }

  // --------------------- UPDATE MEMBER ---------------------
  Future<void> updateMember(String docId, String currentFirst, String currentLast) async {
    TextEditingController updateFirst = TextEditingController(text: currentFirst);
    TextEditingController updateLast = TextEditingController(text: currentLast);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update Member"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: updateFirst,
                decoration: InputDecoration(labelText: "First Name"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: updateLast,
                decoration: InputDecoration(labelText: "Last Name"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text("Update"),
              onPressed: () async {
                if (updateFirst.text.isEmpty || updateLast.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Fields cannot be empty")),
                  );
                  return;
                }

                await FirebaseFirestore.instance
                    .collection('members')
                    .doc(docId)
                    .update({
                  'firstName': updateFirst.text,
                  'lastName': updateLast.text,
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Member updated successfully!')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // --------------------- PAGE UI ---------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Members'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: addMember,
              child: Text('Add Member'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            SizedBox(height: 16),

            // ---------------- LIST OF MEMBERS ----------------
            Expanded(
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('members').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();

                  var docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var member = docs[index];

                      return ListTile(
                        title: Text(
                          '${member['firstName']} ${member['lastName']}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ---- EDIT BUTTON ----
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => updateMember(
                                member.id,
                                member['firstName'],
                                member['lastName'],
                              ),
                            ),

                            // ---- DELETE BUTTON ----
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteMember(member.id),
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
      ),
    );
  }
}
