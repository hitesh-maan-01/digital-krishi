import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  String? get userId => Supabase.instance.client.auth.currentUser?.id;

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text("Please login to view notifications.")),
      );
    }

    final notificationsRef = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("notifications")
        .orderBy("timestamp", descending: true);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 255, 240),
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff058C42),
        actions: [
          TextButton(
            onPressed: () async {
              final snap = await notificationsRef.get();
              for (var doc in snap.docs) {
                doc.reference.update({"read": true});
              }
            },
            child: const Text(
              "Mark all read",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: notificationsRef.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No notifications yet.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final ts = data["timestamp"]?.toDate();
              final read = data["read"] ?? false;

              return Dismissible(
                key: Key(docs[index].id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  color: Colors.red,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => docs[index].reference.delete(),
                child: Card(
                  color: read ? Colors.white : const Color(0xffE8F5E9),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: const Icon(
                        Icons.notifications,
                        color: Colors.green,
                      ),
                    ),
                    title: Text(
                      data["message"] ?? "",
                      style: TextStyle(
                        fontWeight: read ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      ts != null ? ts.toString().substring(0, 16) : "",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: !read
                        ? const Icon(
                            Icons.fiber_manual_record,
                            color: Colors.green,
                            size: 12,
                          )
                        : null,
                    onTap: () => docs[index].reference.update({"read": true}),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
