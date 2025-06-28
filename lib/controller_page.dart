import 'package:flutter/material.dart';
import 'package:eticket_web_app/services/api_service.dart';


class ParkingControllerPage extends StatefulWidget {
  final ApiService apiService;

  ParkingControllerPage({super.key, required this.apiService});
  @override
  _ParkingControllerPageState createState() => _ParkingControllerPageState();
}

class _ParkingControllerPageState extends State<ParkingControllerPage> {
  final TextEditingController _plateController = TextEditingController();
  String _ticketStatus = '';
  Color _statusColor = Colors.black;
  String _ticketStartTime = '';
  String _ticketEndTime = '';
  String _ticketCost = '';
  List<String> _chalkedCars = [];

  void _checkTicketStatus() async {
    String plate = _plateController.text.trim();
    if (plate.isEmpty) {
      setState(() {
        _ticketStatus = 'Please enter a valid plate number.';
        _statusColor = Colors.red;
        _ticketStartTime = '';
        _ticketEndTime = '';
        _ticketCost = '';
      });
      return;
    }

    try {
      // Simulate API call
      final response = await widget.apiService.checkTicketStatus(plate);

      setState(() {
        if (response['hasTicket']) {
          DateTime endTime = DateTime.parse(response['endTime']);
          DateTime currentTime = DateTime.now();

          if (currentTime.isBefore(endTime)) {
            _ticketStatus = 'Ticket is valid.';
            _statusColor = Colors.green;
          } else {
            _ticketStatus = 'Ticket is expired.';
            _statusColor = Colors.red;
          }

          _ticketStartTime = response['startTime'];
          _ticketEndTime = response['endTime'];
          _ticketCost = response['cost'];
        } else {
          _ticketStatus = 'Ticket not found.';
          _statusColor = Colors.red;
          _ticketStartTime = '';
          _ticketEndTime = '';
          _ticketCost = '';
        }
      });
    } catch (e) {
      setState(() {
        _ticketStatus = 'Error checking ticket status.';
        _statusColor = Colors.red;
        _ticketStartTime = '';
        _ticketEndTime = '';
        _ticketCost = '';
      });
    }
  }

  void _chalkCar() {
    String plate = _plateController.text.trim();
    if (plate.isNotEmpty && !_chalkedCars.contains(plate)) {
      setState(() {
        _chalkedCars.add(plate);
      });
    }
  }

  void _removeChalkedCar(String plate) {
    setState(() {
      _chalkedCars.remove(plate);
    });
  }

  void _submitFine() async {
    String plate = _plateController.text.trim();
    if (plate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid plate number.')),
      );
      return;
    }

    if (_ticketStatus == 'Ticket is valid.') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Cannot Submit Fine'),
            content: Text('The ticket for plate "$plate" is valid. You cannot submit a fine.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Show confirmation dialog before submitting the fine
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Submit Fine'),
          content: Text('Are you sure you want to submit a fine for plate "$plate"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog

                try {
                  final response = await widget.apiService.submitFine(plate);

                  if (response) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Fine successfully submitted for plate "$plate".')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to submit fine for plate "$plate".')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error submitting fine for plate "$plate".')),
                  );
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parking Controller'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _plateController,
                    decoration: InputDecoration(
                      labelText: 'Enter Plate Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _checkTicketStatus,
                    child: Text('Check Ticket Status'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _chalkCar,
                    child: Text('Chalk Car'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitFine,
                    child: Text('Submit Fine'),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Ticket Status:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _statusColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _ticketStatus,
                          style: TextStyle(
                            fontSize: 16,
                            color: _statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_ticketStartTime.isNotEmpty) ...[
                          SizedBox(height: 8),
                          Text('Start Time: $_ticketStartTime'),
                          Text('End Time: $_ticketEndTime'),
                          Text('Cost: $_ticketCost'),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          VerticalDivider(),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chalked Cars:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _chalkedCars.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_chalkedCars[index]),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _removeChalkedCar(_chalkedCars[index]),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}