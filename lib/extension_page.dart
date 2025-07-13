import 'package:flutter/material.dart';
import 'package:eticket_web_app/pay_screen.dart';
import 'package:eticket_web_app/services/api_service.dart';
import 'package:eticket_web_app/wheel_time_picker_widget.dart';
import 'package:go_router/go_router.dart';

class ExtensionPage extends StatefulWidget {
  final String id;
  final String zone;
  final DateTime expirationDateTime;
  final String plate;
  final ApiService apiService;

  const ExtensionPage({
    super.key,
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
  int selectedTimeHours = 1; // Default to 1 hour
  int selectedTimeMinutes = 0; // Default to 0 minutes
  double price = 0.0;
  String? id;
  late DateTime expirationDateTime;
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    id = widget.id;
    selectedZone = widget.zone;
    expirationDateTime = widget.expirationDateTime;
    loadPrices();
    // loadRegisteredPlates(); // Uncomment if you want to load registered plates
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
  // Map<String, double> zonePrices = {
  //   'Zone A': 2.0,
  //   'Zone B': 1.5,
  //   'Zone C': 1.0,
  // };
  Map<String, double> zonePrices = {};

  Future<void> loadPrices() async {
    try {
      final prices = await widget.apiService.fetchZonePrices();
      setState(() {
        zonePrices = prices;
        calculatePrice();
      });
    } catch (e) {
      // Handle error
      print('Error loading plates: $e');
    }
  }

  void calculatePrice() {
    if (selectedZone != null) {
      setState(() {
        price = double.parse(
          (zonePrices[selectedZone]! *
                  (selectedTimeHours + selectedTimeMinutes / 60))
              .toStringAsFixed(1),
        );
      });
    }
  }

  String calculateTicketEndTime() {
    DateTime date = expirationDateTime!.add(
      Duration(hours: selectedTimeHours, minutes: selectedTimeMinutes),
    );
    Map<int, String> months = {
      1: "January",
      2: "February",
      3: "March",
      4: "April",
      5: "May",
      6: "June",
      7: "July",
      8: "August",
      9: "September",
      10: "October",
      11: "November",
      12: "December",
    };

    String month = months[date.month]!;
    int day = date.day;
    int hour = date.hour;
    int minutes = date.minute;

    return '$day of $month at ${hour.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select extension time')),
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
              'Select Extension Duration:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            // Text(
            //   'End Time: ${DateTime.now().add(Duration(hours: (selectedTime / 2).toInt())).hour}:${DateTime.now().add(Duration(hours: (selectedTime / 2).toInt(), minutes: 30 * (selectedTime % 2))).minute.toString().padLeft(2, '0')}',
            //   style: TextStyle(fontSize: 16),
            // ),
            // Slider(
            //   value: selectedTime.toDouble(),
            //   min: 0,
            //   max: 46,
            //   divisions: 46,
            //   label:
            //       '${DateTime.now().add(Duration(hours: (selectedTime / 2).toInt())).hour}:${DateTime.now().add(Duration(hours: (selectedTime / 2).toInt(), minutes: 30 * (selectedTime % 2))).minute.toString().padLeft(2, '0')}',
            //   onChanged: (value) {
            //     setState(() {
            //       selectedTime = value.toInt();
            //       calculatePrice();
            //     });
            //   },
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TimePickerTextField(
                    ticketEndTime: expirationDateTime,
                    title: "Select Ticket Extension Time",
                    initialTime: Duration(hours: now.hour, minutes: now.minute),
                    shortDurationWarning:
                        "Ticket extension time must be at least 5 minutes!",
                    onTimeChanged: (Duration value) {
                      setState(() {
                        selectedTimeHours = value.inHours;
                        selectedTimeMinutes = value.inMinutes.remainder(60);
                      });
                      calculatePrice();
                    },
                  ),
                  SizedBox(width: 25),
                  Text(
                    'New End Time: ${calculateTicketEndTime()}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            Text(
              selectedZone != null
                  ? 'Price: €${price.toStringAsFixed(2)}'
                  : 'Please select a zone to see the price',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed:
                    selectedZone != null
                        ? () {
                          context.go(
                            '/payment',
                            extra: {
                              'amount': price,
                              'duration':
                                  selectedTimeHours + selectedTimeMinutes / 60,
                              'plate': widget.plate,
                              'id': id,
                              'zone': selectedZone,
                              'expirationDateTime': expirationDateTime,
                            },
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
