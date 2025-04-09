import 'package:flutter/material.dart';

class SystemAdminPage extends StatelessWidget {
  const SystemAdminPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Administrator Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to Add Profile Page
              },
              child: const Text('Add Profile'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to Remove Profile Page
              },
              child: const Text('Remove Profile'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to Modify Profile Page
              },
              child: const Text('Modify Profile'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to Play Role Page
              },
              child: const Text('Play Role as Another Profile'),
            ),
          ],
        ),
      ),
    );
  }
}