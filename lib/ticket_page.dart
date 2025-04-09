import 'package:flutter/material.dart';
import 'package:eticket_web_app/pay_screen.dart';
import 'package:eticket_web_app/services/api_service.dart';

class TicketPage extends StatefulWidget {
  
  final ApiService apiService;

  const TicketPage({super.key, required this.apiService});

  @override
  _TicketPageState createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  String? selectedZone;
  int selectedTime = 1; // Default to 1 hour
  double price = 0.0;
  String? plate;

  // Placeholder zone prices
  Map<String, double> zonePrices = {
    'Zone A': 2.0,
    'Zone B': 1.5,
    'Zone C': 1.0,
  };

  // Fake plates for debugging purposes
  List<String> registeredPlates = [
    'ABC123',
    'XYZ789',
  ];

  Future<void> loadRegisteredPlates() async {
    try {
      final plates = await widget.apiService.fetchPlates();
      setState(() {
        registeredPlates = plates;
      });
    } catch (e) {
      // Handle error
      print('Error loading plates: $e');
    }
  }

  Future<void> loadPrices() async {
    try {
      final prices = await widget.apiService.fetchZonePrices();
      setState(() {
        zonePrices = prices;
      });
    } catch (e) {
      // Handle error
      print('Error loading plates: $e');
    }
  }

  void calculatePrice() {
    if (selectedZone != null) {
      setState(() {
        price = zonePrices[selectedZone]! * selectedTime/2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Parking Zone and Time'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Zone:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: selectedZone,
              hint: Text('Choose a zone'),
              items: zonePrices.keys.map((zone) {
                return DropdownMenuItem<String>(
                  value: zone,
                  child: Text(zone),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedZone = value;
                  calculatePrice();
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'Select End Time:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'End Time: ${DateTime.now().add(Duration(hours: (selectedTime/2).toInt())).hour}:${DateTime.now().add(Duration(hours: (selectedTime/2).toInt(), minutes: 30*(selectedTime%2))).minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 16),
            ),
            Slider(
              value: selectedTime.toDouble(),
              min: 0,
              max: 46,
              divisions: 46,
              label: '${DateTime.now().add(Duration(hours: (selectedTime/2).toInt())).hour}:${DateTime.now().add(Duration(hours: (selectedTime/2).toInt(), minutes: 30*(selectedTime%2))).minute.toString().padLeft(2, '0')}',
              onChanged: (value) {
                setState(() {
                  selectedTime = value.toInt();
                  calculatePrice();
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'Enter or Select Plate:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: plate,
              hint: Text('Choose a registered plate or enter a new one'),
              items: [
                ...registeredPlates.map((plate) {
                  return DropdownMenuItem<String>(
                    value: plate,
                    child: Text(plate),
                  );
                }),
                DropdownMenuItem<String>(
                  value: 'NEW',
                  child: Text('Enter a new plate'),
                ),
              ],
              onChanged: (value) {
                if (value == 'NEW') {
                  showDialog(
                    context: context,
                    builder: (context) {
                      String newPlate = '';
                      return AlertDialog(
                        title: Text('Enter New Plate'),
                        content: TextField(
                          onChanged: (text) {
                            newPlate = text;
                          },
                          decoration: InputDecoration(hintText: 'Plate number'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                plate = newPlate;
                                if (!registeredPlates.contains(newPlate)) {
                                  registeredPlates.add(newPlate);
                                }
                              });
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  setState(() {
                    plate = value;
                  });
                }
              },
            ),
            SizedBox(height: 20),
            Text(
              selectedZone != null
                  ? 'Price: \$${price.toStringAsFixed(2)}'
                  : 'Please select a zone to see the price',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: selectedZone != null && plate != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PayScreen(
                              amount: price,
                              duration: selectedTime,
                              zone: selectedZone!,
                              plate: plate!,
                              apiService: widget.apiService,
                            ),
                          ),
                        );
                      }
                    : null,
                child: Text('Proceed to Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}