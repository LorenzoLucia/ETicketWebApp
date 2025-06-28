import 'package:flutter/material.dart';
import 'package:eticket_web_app/pay_screen.dart';
import 'package:eticket_web_app/services/api_service.dart';
import 'wheel_time_picker_widget.dart';

class TicketPage extends StatefulWidget {
  final ApiService apiService;

  const TicketPage({super.key, required this.apiService});

  @override
  _TicketPageState createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  String? selectedZone;
  double selectedTime = 1; // Default to 1
  double price = 0.0;
  String? plate;
  Map<String, double> zonePrices = {};
  List<String> registeredPlates = [];
  DateTime now = DateTime.now();

  // // Placeholder zone prices
  // Map<String, double> zonePrices = {
  //   'Zone A': 2.0,
  //   'Zone B': 1.5,
  //   'Zone C': 1.0,
  // };

  // // Fake plates for debugging purposes
  // List<String> registeredPlates = [
  //   'ABC123',
  //   'XYZ789',
  // ];

  Future<void> loadRegisteredPlates() async {
    try {
      final plates = await widget.apiService.fetchPlates();
      setState(() {
        registeredPlates = plates;
      });
      print('Registered plates loaded: $registeredPlates');
    } catch (e) {
      // Handle error
      print('Error loading plates: $e');
    }
  }

  Future<void> loadPrices() async {
    try {
      final prices = await widget.apiService.fetchZonePrices();
      print('Zone prices loaded: $prices');
      setState(() {
        zonePrices = prices;
      });
    } catch (e) {
      // Handle error
      print('Error loading zones: $e');
    }
  }

  void calculatePrice() {
    if (selectedZone != null) {
      setState(() {
        price = double.parse(
          (zonePrices[selectedZone]! * selectedTime).toStringAsFixed(1),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadRegisteredPlates();
    loadPrices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Parking Zone and Time')),
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
              items:
                  zonePrices.keys.map((zone) {
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

            SizedBox(height: 20),

            TimePickerTextField(
              initialTime: Duration(hours: now.hour, minutes: now.minute),
              onTimeChanged: (double value) {
                setState(() {
                  selectedTime = value;
                });
                calculatePrice();
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
                          TextButton(
                            onPressed: () async {
                              try {
                                await widget.apiService.addPlate(newPlate);
                                setState(() {
                                  plate = newPlate;
                                  if (!registeredPlates.contains(newPlate)) {
                                    registeredPlates.add(newPlate);
                                  }
                                });
                                Navigator.of(context).pop();
                              } catch (e) {
                                // Handle error
                                print('Error saving plate: $e');
                              }
                            },
                            child: Text('Save'),
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
                onPressed:
                    selectedZone != null && plate != null
                        ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => PayScreen(
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
