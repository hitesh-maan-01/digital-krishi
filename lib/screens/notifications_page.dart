import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        titleTextStyle: TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontSize: 18,
        ),
        backgroundColor: const Color.fromARGB(255, 5, 150, 105),
      ),
      body: const Center(
        child: Text('No new notifications', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
