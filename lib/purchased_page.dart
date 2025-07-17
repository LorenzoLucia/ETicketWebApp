import 'package:eticket_web_app/qrcode_screen.dart';
import 'package:flutter/material.dart';
import 'package:eticket_web_app/extension_page.dart';
import 'package:eticket_web_app/services/api_service.dart';

class PurchasedPage extends StatefulWidget {
  final ApiService apiService;

  const PurchasedPage({super.key, required this.apiService});

  @override
  _PurchasedPage createState() => _PurchasedPage();
}



class _PurchasedPage extends State<PurchasedPage> {
  // Fake tickets for now
  // List<Map<String, dynamic>> fakeTickets = [
  //   {
  //     'id': '1',
  //     'plate': 'ABC123',
  //     'zone': 'Zone A',
  //     'price': 10.0,
  //     'startDateTime': DateTime.now(),
  //     'expirationDateTime': DateTime.now().add(Duration(hours: 2)),
  //     'status': 'active',
  //   },
  //   {
  //     'id': '2',
  //     'plate': 'XYZ789',
  //     'zone': 'Zone B',
  //     'price': 15.0,
  //     'startDateTime': DateTime.now().subtract(Duration(days: 1)),
  //     'expirationDateTime': DateTime.now().subtract(Duration(hours: 22)),
  //     'status': 'expired',
  //   },
  //   {
  //     'id': '3',
  //     'plate': 'LMN456',
  //     'zone': 'Zone C',
  //     'price': 20.0,
  //     'startDateTime': DateTime.now().add(Duration(days: 1)),
  //     'expirationDateTime': DateTime.now().add(Duration(days: 1, hours: 3)),
  //     'status': 'active',
  //   },
  // ];


  // Fetch tickets from the server (to be implemented)
  List<Map<String, dynamic>> tickets = [];
  late Future<bool> _hasTickets;

  Future<bool> fetchTickets() async {
    try {
      final response  = await widget.apiService.fetchTickets();
      // For now, return the fakeTickets
      if (response.isEmpty) {
        return false;
      }
      setState(() {
        tickets = response..sort((a, b) => DateTime.parse(b['start_time']).compareTo(DateTime.parse(a['start_time'])));
      });
      
      return true;
    } catch (e) {
      // Handle errors appropriately
      throw Exception('Error fetching tickets: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch tickets when the page is initialized
    _hasTickets = fetchTickets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchased Tickets'),
      ),
      body: FutureBuilder<bool>(
        future: _hasTickets,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching tickets'));
          } else if (!snapshot.data!) {
            return Center(child: Text('No tickets purchased yet'));
          } else {
            // final tickets = snapshot.data!;
            return ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) {
              final ticket = tickets[index];
              final isActive = ticket['is_active'];
              return Card(
                color: isActive ? Colors.green[100] : Colors.red[100],
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text('Plate: ${ticket['plate']['number']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Zone: ${ticket['zone']['name']}'),
                  Text('Price: €${double.parse(ticket['price']).toStringAsFixed(2)}'),
                  Text(
                    'Start: ${ticket['start_time']}',
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(
                    'Expires: ${ticket['end_time']}',
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    ElevatedButton(
                      onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                        builder: (context) => QRScreen(
                          ticketId: ticket['id'],
                          apiService: widget.apiService,
                        ),
                        ),
                      );
                      },
                      child: Text('QR Code'),
                    ),
                    if (isActive)
                      ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExtensionPage(
                          id: ticket['id'],
                          expirationDateTime: DateTime.parse(ticket['end_time']),
                          zone: ticket['zone']['name'],
                          plate: ticket['plate']['number'],
                          apiService: widget.apiService,
                          ),
                        ),
                        );
                      },
                      child: Text('Extend'),
                      ),
                    ],
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