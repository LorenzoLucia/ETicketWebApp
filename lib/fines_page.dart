import 'package:flutter/material.dart';
import 'package:eticket_web_app/services/api_service.dart';

class FinesPage extends StatefulWidget {
  final ApiService apiService;

  const FinesPage({super.key, required this.apiService});

  @override
  _FinesPage createState() => _FinesPage();
}



class _FinesPage extends State<FinesPage> {

  // Fetch fines from the server (to be implemented)
  List<Map<String, dynamic>> fines = [];
  late Future<bool> _hasFines;

  Future<bool> fetchFines() async {
    try {
      final response  = await widget.apiService.fetchFines();
      // For now, return the fakeTickets
      print('Fetched fines: $response');

      if (response.isEmpty) {
        return false;
      }
      setState(() {
        fines = response..sort((a, b) => DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));
      });
      
      return true;
    } catch (e) {
      // Handle errors appropriately
      throw Exception('Error fetching fines: $e');
    }
  }

  Future<void> issueFine(String fineId) async {
    try {
      final response = await widget.apiService.issueFine(fineId);
      // Optionally, refresh the fines list after issuing a fine
      if (response){
        await fetchFines();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fine issued successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to issue fine')),
        );
      }
      
    } catch (e) {
      // Handle errors appropriately
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error issuing fine: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch fines when the page is initialized
    _hasFines = fetchFines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fines history'),
      ),
      body: FutureBuilder<bool>(
        future: _hasFines,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error fetching fines: ${snapshot.error}');
            return Center(child: Text('Error fetching fines'));
          } else if (!snapshot.data!) {
            return Center(child: Text('No fines emitted yet'));
          } else {
            // final fines = snapshot.data!;
            return ListView.builder(
              itemCount: fines.length,
              itemBuilder: (context, index) {
                final fine = fines[index];
                final issued = fine['issued'];
                return Card(
                  color: issued ? Colors.green[100] : Colors.red[100],
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                  title: Text('Plate: ${fine['plate']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // Text('Zone: ${fine['zone']['name']}'),
                    Text('Amount: \$${fine['amount']}'),
                    Text(
                      'Date: ${fine['timestamp']}',
                      style: TextStyle(
                      color: Colors.black,
                      ),
                    ),
                    Text(
                      'Reason: ${fine['reason']}',
                      style: TextStyle(
                      color: Colors.black,
                      ),
                    ),
                    ],
                  ),
                    trailing: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Text(
                        issued ? 'Issued' : 'Not issued',
                        style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: issued ? Colors.green : Colors.red,
                        ),
                      ),
                      if (!issued)
                        ElevatedButton(
                        onPressed: () {
                          issueFine(fine['id']);
                        },
                        child: Text('Mark as Issued'),
                        ),
                      ],
                    ),
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