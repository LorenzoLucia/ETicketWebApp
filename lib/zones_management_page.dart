import 'package:flutter/material.dart';
import 'package:eticket_web_app/services/api_service.dart';

class ZonesManagementPage extends StatefulWidget {
  final ApiService apiService;

  const ZonesManagementPage({super.key, required this.apiService});
  @override
  _ZonesManagementPageState createState() => _ZonesManagementPageState();
}

class _ZonesManagementPageState extends State<ZonesManagementPage> {
  List<Map<String, dynamic>> zones = [];

  @override
  void initState() {
    super.initState();
    _fetchZones();
  }

  Future<void> _fetchZones() async {
    try {
      final fetchedZones = await widget.apiService.getZones();
      setState(() {
        zones = fetchedZones;
      });
    } catch (e) {
      // Handle error
      print('Error fetching zones: $e');
    }
  }

  void _modifyZone(int index) {
    final zone = zones[index];
    TextEditingController nameController = TextEditingController(text: zone['name']);
    TextEditingController priceController = TextEditingController(text: zone['price'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modify Zone'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Zone Name'),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
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
                try {
                  await widget.apiService.modifyZone(
                    zone['id'],
                    nameController.text,
                    double.parse(priceController.text),
                  );
                  setState(() {
                    zones[zones.indexWhere((z) => z['id'] == zone['id'])] = {
                      'id': zone['id'],
                      'name': nameController.text,
                      'price': double.parse(priceController.text),
                    };
                  });
                  Navigator.of(context).pop();
                } catch (e) {
                  // Handle error
                  print('Error updating zone: $e');
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteZone(int index) {
    final zone = zones[index];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Zone'),
          content: Text('Are you sure you want to delete ${zone['name']}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await widget.apiService.removeZone(zone['id']);
                  setState(() {
                    zones.removeWhere((z) => z['id'] == zone['id']);
                  });
                  Navigator.of(context).pop();
                } catch (e) {
                  // Handle error
                  print('Error deleting zone: $e');
                }
              },
              child: Text('Delete'),
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
        title: Text('Zones Management'),
      ),
      body: ListView.builder(
        itemCount: zones.length,
        itemBuilder: (context, index) {
          final zone = zones[index];
          return ListTile(
            title: Text(zone['name']),
            subtitle: Text('Price: \$${zone['price']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _modifyZone(index),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteZone(index),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
