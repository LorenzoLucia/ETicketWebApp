import 'package:flutter/material.dart';
import 'package:eticket_web_app/pay_screen.dart';

class TicketPage extends StatefulWidget {
  @override
  _TicketPageState createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  String? selectedZone;
  int selectedTime = 1; // Default to 1 hour
  double price = 0.0;
  String? plate;

  // Placeholder zone prices
  final Map<String, double> zonePrices = {
    'Zone A': 2.0,
    'Zone B': 1.5,
    'Zone C': 1.0,
  };

  // Fake plates for debugging purposes
  final List<String> registeredPlates = [
    'ABC123',
    'XYZ789',
  ];

  void calculatePrice() {
    if (selectedZone != null) {
      setState(() {
        price = zonePrices[selectedZone]! * selectedTime;
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
            DropdownButton<double>(
              value: selectedTime.toDouble(),
              hint: Text('Choose end time'),
              items: List.generate(48, (index) {
                final now = DateTime.now();
                final endTime = now.add(Duration(minutes: 30 * (index + 1)));
                final hours = endTime.hour;
                final minutes = endTime.minute.toString().padLeft(2, '0');
                return DropdownMenuItem<double>(
                  value: (index + 1) * 0.5,
                  child: Text('$hours:$minutes'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTime = (value! * 2).toInt(); // Convert to integer for calculation
                  calculatePrice();
                });
              },
            ),
            Slider(
              value: selectedTime.toDouble(),
              min: 0,
              max: 24,
              divisions: 23,
              label: '$selectedTime',
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