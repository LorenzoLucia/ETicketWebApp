import 'package:flutter/material.dart';
import 'package:eticket_web_app/pay_screen.dart';
import 'package:eticket_web_app/services/api_service.dart';

class ExtensionPage extends StatefulWidget {
  final String id;
  final String zone;
  final DateTime expirationDateTime;
  final String plate;
  final ApiService apiService;

  const ExtensionPage({super.key, 
    required this.id,
    required this.zone,
    required this.expirationDateTime,
    required this.plate,
    required this.apiService,
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
  Map<String, double> zonePrices = {
    'Zone A': 2.0,
    'Zone B': 1.5,
    'Zone C': 1.0,
  };

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