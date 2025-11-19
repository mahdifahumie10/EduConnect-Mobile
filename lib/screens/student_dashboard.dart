import 'package:flutter/material.dart';
import '../widgets/dashboard_card.dart';
import 'student_assignments.dart';
import 'student_events.dart';
import 'student_timetable.dart';

class StudentDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Dashboard'),
        backgroundColor: Colors.blue,
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
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            DashboardCard(
              title: 'Assignments',
              icon: Icons.assignment,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudentAssignmentsPage()),
                );
              },
            ),
            DashboardCard(
              title: 'Events',
              icon: Icons.event,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudentEventsPage()),
                );
              },
            ),
            DashboardCard(
              title: 'Timetable',
              icon: Icons.schedule,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudentTimetablePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
