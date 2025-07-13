import 'package:eticket_web_app/services/app_state.dart';
import 'package:eticket_web_app/services/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eticket_web_app/services/api_service.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';


class ParkingControllerPage extends StatefulWidget {

  ParkingControllerPage({super.key});
  @override
  _ParkingControllerPageState createState() => _ParkingControllerPageState();
}

class _ParkingControllerPageState extends State<ParkingControllerPage> {
  final TextEditingController _plateController = TextEditingController();
  String _ticketStatus =  'Enter a plate number to check ticket status.';
  Color _statusColor = Colors.black;
  String _ticketStartTime = '';
  String _ticketEndTime = '';
  String _ticketCost = '';
  String _zone = '';
  String _ticketPlate = '';
  bool already_fined = false;
  List<String> _chalkedCars = [];

  @override
  void initState() {
    super.initState();
    fetchChalkedCars(Provider.of<AppState>(context, listen: false).apiService!);
  }

  void _checkTicketStatus(ApiService apiService) async {
    String plate = _plateController.text.trim();
    if (plate.isEmpty) {
      setState(() {
        _ticketStatus = 'Please enter a valid plate number.';
        _statusColor = Colors.red;
        _ticketStartTime = '';
        _ticketEndTime = '';
        _ticketCost = '';
        _zone = '';
        _ticketPlate = '';
      });
      return;
    }

    try {
      final response = await apiService.checkTicketStatus(plate);
      print(response);

      setState(() {
        already_fined = response['fine_issued'];
        if (response['has_ticket']) {
          DateTime endTime = DateTime.parse(response['end_time']);
          DateTime currentTime = DateTime.now();

          if (currentTime.isBefore(endTime)) {
            _ticketStatus = 'Ticket is valid.';
            _statusColor = Colors.green;
          } else {
            _ticketStatus = 'Ticket is expired.';
            _statusColor = Colors.red;
          }

          _ticketStartTime = response['start_time'];
          _ticketEndTime = response['end_time'];
          _ticketCost = response['price'].toString();
          _zone = response['zone']['name'];
          _ticketPlate = plate;
        } else {
          _ticketStatus = 'Ticket not found for $plate';
          _statusColor = Colors.red;
          _ticketStartTime = '';
          _ticketEndTime = '';
          _ticketCost = '';
          _zone = '';
          _ticketPlate = '';
        }
      });
    } catch (e) {
      setState(() {
        _ticketStatus = 'Error checking ticket status.';
        _statusColor = Colors.red;
        _ticketStartTime = '';
        _ticketEndTime = '';
        _ticketCost = '';
        _zone = '';
        _ticketPlate = '';
        already_fined = false;
      });
      print('Error checking ticket status: $e');
    }
  }

  void _chalkCar(ApiService apiService) async {
    String plate = _plateController.text.trim();
    if (_chalkedCars.contains(plate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Car with plate $plate is already chalked.')),
      );
      return;
    }
    try {
      final response = await apiService.chalk(plate);
      if (response){
        setState(() {
          _chalkedCars.add(plate);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to chalk car: $plate')),
        ); 
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error chalking car: $e')),
      );
    }
  }

  void _removeChalkedCar(String plate, ApiService apiService) async {
    try {
      final response = await apiService.removeChalk(plate);
      if (response){
        setState(() {
          _chalkedCars.remove(plate);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove chalked car: $plate')),
        ); 
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing chalked car: $e')),
      );
    }
  }

  void fetchChalkedCars(ApiService apiService) async {
    try {
      final response = await apiService.fetchChalkedCars();
      setState(() {
        _chalkedCars = List<String>.from(response);
      });
    } catch (e) {
      print('Error fetching chalked cars: $e');
    }
  }

  void _submitFine(ApiService apiService) async {
    if (already_fined) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fine already issued for this plate today.')),
      );
      return;
    }
    String plate = _plateController.text.trim();
    if (plate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid plate number.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
      TextEditingController reasonController = TextEditingController();
      TextEditingController amountController = TextEditingController();

      return AlertDialog(
        title: Text('Submit Fine'),
        content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Are you sure you want to submit a fine for plate "$plate"?'),
          SizedBox(height: 16),
          TextField(
          controller: reasonController,
          decoration: InputDecoration(
            labelText: 'Reason for Fine',
            border: OutlineInputBorder(),
          ),
          ),
          SizedBox(height: 16),
          TextField(
          controller: amountController,
          decoration: InputDecoration(
            labelText: 'Amount to Pay',
            border: OutlineInputBorder(),
          ),
          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9/]'),
                            ),
                            EuroPriceFormatter(),
                          ],
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ],
        ),
        actions: [
        TextButton(
          onPressed: () {
          Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
          

          String reason = reasonController.text.trim();
          String amountText = amountController.text.trim();

          if (reason.isEmpty || amountText.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please provide both reason and amount for the fine.')),
            );
            return;
          }

          print("$amountText.");

          double? amount = double.tryParse(amountText.substring(1, amountText.length).replaceAll(',', '.'));
          if (amount == null) {
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter a valid amount.')),
            );
            return;
          }

          try {
            final response = await apiService.submitFine(plate, reason, amount);
            print(response);

            if (response) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Fine successfully submitted for plate "$plate".')),
            );
            } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to submit fine for plate "$plate", fine yet submitted today.')),
            );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error submitting fine for plate "$plate": $e')),
            );
          }
          Navigator.of(context).pop();
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
    final appState = Provider.of<AppState>(context, listen: false);
    final apiService = appState.apiService;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('Parking Controller'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              appState.clear();
              context.go('/');
            },
          ),
        ],
      ),
      body: isMobile
          ? SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
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
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9]'),
                            ),
                            UpperCaseTextFormatter(),
                          ],
                          textCapitalization: TextCapitalization.characters,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _checkTicketStatus(apiService!);
                          },
                          child: Text('Check Ticket Status'),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _chalkCar(apiService!),
                          child: Text('Chalk Car'),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _submitFine(apiService!);
                          },
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
                                Text('Plate: $_ticketPlate'),
                                Text('Start Time: $_ticketStartTime'),
                                Text('End Time: $_ticketEndTime'),
                                Text('Cost: ${double.parse(_ticketCost).toStringAsFixed(2)}'),
                                Text('Zone: ${_zone}'),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chalked Cars:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _chalkedCars.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(_chalkedCars[index]),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.check_circle),
                                    onPressed: () {
                                      _plateController.text = _chalkedCars[index];
                                      _checkTicketStatus(apiService!);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () => _removeChalkedCar(_chalkedCars[index], apiService!),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Row(
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
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9]'),
                            ),
                            UpperCaseTextFormatter(),
                          ],
                          textCapitalization: TextCapitalization.characters,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _checkTicketStatus(apiService!);
                          },
                          child: Text('Check Ticket Status'),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _chalkCar(apiService!),
                          child: Text('Chalk Car'),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _submitFine(apiService!);
                          },
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
                                Text('Plate: $_ticketPlate'),
                                Text('Start Time: $_ticketStartTime'),
                                Text('End Time: $_ticketEndTime'),
                                Text('Cost: ${double.parse(_ticketCost).toStringAsFixed(2)}'),
                                Text('Zone: ${_zone}'),
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
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.check_circle),
                                      onPressed: () {
                                        _plateController.text = _chalkedCars[index];
                                        _checkTicketStatus(apiService!);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () => _removeChalkedCar(_chalkedCars[index], apiService!),
                                    ),
                                  ],
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
