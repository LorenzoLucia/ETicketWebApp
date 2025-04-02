import 'package:flutter/material.dart';
import 'package:eticket_web_app/extension_page.dart';

class PurchasedPage extends StatelessWidget {
  // Fake tickets for now
  final List<Map<String, dynamic>> fakeTickets = [
    {
      'id': '1',
      'plate': 'ABC123',
      'zone': 'Zone A',
      'price': 10.0,
      'startDateTime': DateTime.now(),
      'expirationDateTime': DateTime.now().add(Duration(hours: 2)),
      'status': 'active',
    },
    {
      'id': '2',
      'plate': 'XYZ789',
      'zone': 'Zone B',
      'price': 15.0,
      'startDateTime': DateTime.now().subtract(Duration(days: 1)),
      'expirationDateTime': DateTime.now().subtract(Duration(hours: 22)),
      'status': 'expired',
    },
    {
      'id': '3',
      'plate': 'LMN456',
      'zone': 'Zone C',
      'price': 20.0,
      'startDateTime': DateTime.now().add(Duration(days: 1)),
      'expirationDateTime': DateTime.now().add(Duration(days: 1, hours: 3)),
      'status': 'active',
    },
  ];

  // Fetch tickets from the server (to be implemented)
  Future<List<Map<String, dynamic>>> fetchTickets() async {
    try {
      // Simulate a network call to fetch tickets from a server
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay

      // Replace this with actual API call logic
      // Example:
      // final response = await http.get(Uri.parse('https://api.example.com/tickets'));
      // if (response.statusCode == 200) {
      //   return List<Map<String, dynamic>>.from(json.decode(response.body));
      // } else {
      //   throw Exception('Failed to load tickets');
      // }

      // For now, return the fakeTickets
      return fakeTickets;
    } catch (e) {
      // Handle errors appropriately
      throw Exception('Error fetching tickets: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchased Tickets'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchTickets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching tickets'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tickets purchased yet'));
          } else {
            final tickets = snapshot.data!;
            return ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                final isActive = ticket['status'] == 'active';
                return Card(
                  color: isActive ? Colors.green[100] : Colors.red[100],
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                  title: Text('Plate: ${ticket['plate']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text('Zone: ${ticket['zone']}'),
                    Text('Price: \$${ticket['price']}'),
                    Text(
                      'Start: ${ticket['startDateTime'].toLocal()}',
                      style: TextStyle(
                      color: Colors.black,
                      ),
                    ),
                    Text(
                      'Expires: ${ticket['expirationDateTime'].toLocal()}',
                      style: TextStyle(
                      color: Colors.black,
                      ),
                    ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Text(
                      isActive ? 'Active' : 'Expired',
                      style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.green : Colors.red,
                      ),
                    ),
                    if (isActive)
                      ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExtensionPage(
                          id: ticket['id'],
                          expirationDateTime: ticket['expirationDateTime'],
                          zone: ticket['zone'],
                          plate: ticket['plate'],
                          ),
                        ),
                        );
                      },
                      child: Text('Extend'),
                      ),
                    ],
                  ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}