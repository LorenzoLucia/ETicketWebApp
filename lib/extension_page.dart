import 'package:flutter/material.dart';
import 'package:eticket_web_app/pay_screen.dart';

class ExtensionPage extends StatefulWidget {
  final String id;
  final String zone;
  final DateTime expirationDateTime;
  final String plate;

  const ExtensionPage({super.key, 
    required this.id,
    required this.zone,
    required this.expirationDateTime,
    required this.plate,
    });

  @override
  _ExtensionPageState createState() => _ExtensionPageState();
}

class _ExtensionPageState extends State<ExtensionPage> {
  String? selectedZone;
  int selectedTime = 1; // Default to 1 hour
  double price = 0.0;
  String? id;
  DateTime? expirationDateTime;
  
  @override
  void initState() {
    super.initState();
    id = widget.id;
    selectedZone = widget.zone;
    expirationDateTime = widget.expirationDateTime;
  }

  // The zonePrices map should be fetched from an HTTP request.
  // For now, we will use a placeholder map until the server is ready.
  // Future<void> fetchZonePrices() async {
  //   final response = await http.get(Uri.parse('https://example.com/api/zonePrices'));
  //   if (response.statusCode == 200) {
  //     setState(() {
  //       zonePrices = Map<String, double>.from(json.decode(response.body));
  //     });
  //   } else {
  //     throw Exception('Failed to load zone prices');
  //   }
  // }

  // Placeholder zone prices
  // This should be replaced with the actual data from the server.
  final Map<String, double> zonePrices = {
    'Zone A': 2.0,
    'Zone B': 1.5,
    'Zone C': 1.0,
  };

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
        title: Text('Select extension time.'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
              '$selectedZone',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Select New End Time:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<double>(
              value: selectedTime.toDouble(),
              hint: Text('Choose end time'),
              items: List.generate(48, (index) {
              // final now = DateTime.now();
              // final endTime = now.add(Duration(minutes: 30 * (index + 1)));
              final endTime = expirationDateTime!.add(Duration(minutes: 30 * (index + 1)));
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
              selectedZone != null
                ? 'Price: \$${price.toStringAsFixed(2)}'
                : 'Please select a zone to see the price',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
              onPressed: selectedZone != null
                ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                    builder: (context) => PayScreen(
                      amount: price,
                      duration: selectedTime,
                      zone: selectedZone!,
                      id: id!,
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