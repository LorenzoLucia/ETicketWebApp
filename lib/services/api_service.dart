import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<Map<String, double>> fetchZonePrices() async {
    final response = await http.get(Uri.parse('$baseUrl/zonePrices'));
    if (response.statusCode == 200) {
      // setState(() {
      //   zonePrices = Map<String, double>.from(json.decode(response.body));
      // });

      return Map<String, double>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load zone prices');
    }
  }

  Future<bool> hasRegisteredPaymentMethods() async {
    final url = Uri.parse('$baseUrl/payment-methods');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['hasPaymentMethods'] ?? false;
      } else {
        throw Exception('Failed to load payment methods');
      }
    } catch (e) {
      print('Error: $e');
      // return false;
      return true; // For debug purposes, always return true
    }
  }

  Future<List<Map<String, dynamic>>> fetchTickets() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tickets'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to load tickets');
      }
    } catch (e) {
      // Handle errors appropriately
      throw Exception('Error fetching tickets: $e');
    }
  }

  Future<Map<String, dynamic>> fetchProfileData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/profile'));
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to load tickets');
      }
    } catch (e) {
      // Handle errors appropriately
      throw Exception('Error fetching tickets: $e');
    }
  }

  Future<List<String>> fetchPaymentMethods() async {
    try {
      // Simulate an API call to fetch payment methods
      // Example:
      final response = await http.get(Uri.parse('$baseUrl/payment-methods'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['paymentMethods']);
      } else {
        throw Exception('Failed to load payment methods');
      }
    } catch (e) {
      // Handle errors appropriately
      throw Exception('Error fetching tickets: $e');
    }
  }

  Future<List<String>> fetchPlates() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/plates'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['plates']);
      } else {
        throw Exception('Failed to load plates');
      }
    }catch (e) {
      // Handle errors appropriately
      throw Exception('Error fetching tickets: $e');
    }
  }

  Future<bool> addUser(String username, String email, String role) async {

    final body = jsonEncode({'username': username, 'email': email, 'role': role});
    final url = Uri.parse('$baseUrl/users/add_users');

    try {
      final response = await http.post(url, body: body, headers: {'Content-Type': 'application/json'});
      return response.statusCode == 201;
    } catch (e) {
      throw('Error adding user: $e');
    }
  }

  Future<bool> removeUser(String username, String role) async {

    final url = Uri.parse('$baseUrl/users/remove_users');
    final body = jsonEncode({'username': username, 'role': role});

    try {
      final response = await http.post(url, body: body, headers: {'Content-Type': 'application/json'});
      return response.statusCode == 201;
      
    } catch (e) {
      throw('Error removing user: $e');
    }
  }

  Future<bool> modifyUser(String username, String new_email, String new_role) async {

    final url = Uri.parse('$baseUrl/users/modify_users');
    final body = jsonEncode({'username': username, 'email': new_email, 'role': new_role});

    try {
      final response = await http.put(url, body: body, headers: {'Content-Type': 'application/json'});
      return response.statusCode == 201;
      }
    catch (e) {
      throw('Error modifying user: $e');
    }
  }

  Future<bool> addZone(String name, double? price) async {

    final url = Uri.parse('$baseUrl/zones/add_zones');
    final body = jsonEncode({'zoneName': name, 'price': price});

    try {
      final response = await http.post(url, body: body, headers: {'Content-Type': 'application/json'});
      return response.statusCode == 201;
    } catch (e) {
      throw('Error adding zone: $e');
    }
  }

  Future<bool> removeZone(String name) async {

    final url = Uri.parse('$baseUrl/zones/remove_zones');
    final body = jsonEncode({'zoneName': name});

    try {
      final response = await http.post(url, body: body, headers: {'Content-Type': 'application/json'});
      return response.statusCode == 201;
    } catch (e) {
      throw('Error removing zone: $e');
    }
  }

  Future<bool> modifyZone(String name, double? price) async {

    final url = Uri.parse('$baseUrl/zones/modify_zones');
    final body = jsonEncode({'zoneName': name, 'price': price});

    try {
      final response = await http.put(url, body: body, headers: {'Content-Type': 'application/json'});
      return response.statusCode == 201;
    } catch (e) {
      throw('Error modifying zone: $e');
    }
  }

}