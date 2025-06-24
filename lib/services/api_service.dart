import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  final String baseUrl;
  Future<String?> getTokenId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  ApiService(this.baseUrl);

  Future<Map<String, double>> fetchZonePrices() async {
    final tokenId = await getTokenId();
    final response = await http.get(
      Uri.parse('$baseUrl/zonePrices'),
      headers: {'auth': (tokenId ?? '')});
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
    
    try {
      final tokenId = await getTokenId();
      final url = Uri.parse('$baseUrl/payment-methods');
      final response = await http.get(
        url,
        headers: {'auth': (tokenId ?? '')});
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
      final tokenId = await getTokenId();
      final response = await http.get(
        Uri.parse('$baseUrl/tickets'),
        headers: {'auth': (tokenId ?? '')});
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
      final tokenId = await getTokenId();
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {'auth': (tokenId ?? '')});
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
      final tokenId = await getTokenId();
      final response = await http.get(
        Uri.parse('$baseUrl/payment-methods'),
        headers: {'auth': (tokenId ?? '')});
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
      final tokenId = await getTokenId();
      final response = await http.get(
        Uri.parse('$baseUrl/plates'),
        headers: {'auth': (tokenId ?? '')});
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

  Future<List<Map<String,dynamic>>> getUsers() async {


    final url = Uri.parse('$baseUrl/users');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'auth': (await getTokenId() ?? '')});
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw('Error fetching users: $e');
    }
  }

  Future<bool> addUser(String username, String email, String role) async {

    final body = jsonEncode({'username': username, 'email': email, 'role': role});
    final url = Uri.parse('$baseUrl/users');

    try {
      final response = await http.post(
        url,
        body: body,
        headers: {'Content-Type': 'application/json', 'auth': (await getTokenId() ?? '')});
      return response.statusCode == 201;
    } catch (e) {
      throw('Error adding user: $e');
    }
  }

  Future<bool> removeUser(String uid) async {

    final url = Uri.parse('$baseUrl/users/$uid');
    final body = jsonEncode({});

    try {
      final response = await http.delete(
        url, 
        body: body,
        headers: {'Content-Type': 'application/json', 'auth': (await getTokenId() ?? '')});
      return response.statusCode == 201;
      
    } catch (e) {
      throw('Error removing user: $e');
    }
  }

  Future<bool> modifyUser(String uid, String username, String new_email, String new_role) async {

    final url = Uri.parse('$baseUrl/users/$uid');
    final body = jsonEncode({'username': username, 'email': new_email, 'role': new_role});

    try {
      final response = await http.put(
        url,
      body: body,
      headers: {'Content-Type': 'application/json', 'auth': (await getTokenId() ?? '')});
      return response.statusCode == 201;
      }
    catch (e) {
      throw('Error modifying user: $e');
    }
  }

  Future<List<Map<String,dynamic>>> getZones() async {


    final url = Uri.parse('$baseUrl/zones');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'auth': (await getTokenId() ?? '')});
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to load zones');
      }
    } catch (e) {
      throw('Error fetching zones: $e');
    }
  }

  Future<bool> addZone(String ZoneId, String name, double? price) async {

    final url = Uri.parse('$baseUrl/zones/$ZoneId');
    final body = jsonEncode({'zoneName': name, 'price': price});

    try {
      final response = await http.post(
        url,
        body: body,
        headers: {'Content-Type': 'application/json', 'auth': (await getTokenId() ?? '')});
      return response.statusCode == 201;
    } catch (e) {
      throw('Error adding zone: $e');
    }
  }

  Future<bool> removeZone(String ZoneId) async {

    final url = Uri.parse('$baseUrl/zones/$ZoneId');
    final body = jsonEncode({});

    try {
      final response = await http.delete(url, body: body, headers: {'Content-Type': 'application/json', 'auth': (await getTokenId() ?? '')});
      return response.statusCode == 201;
    } catch (e) {
      throw('Error removing zone: $e');
    }
  }

  Future<bool> modifyZone(String ZoneId, String name, double? price) async {

    final url = Uri.parse('$baseUrl/zones/$ZoneId');
    final body = jsonEncode({'zoneName': name, 'price': price});

    try {
      final response = await http.put(
        url,
        body: body,
        headers: {'Content-Type': 'application/json', 'auth': (await getTokenId() ?? '')});
      return response.statusCode == 201;
    } catch (e) {
      throw('Error modifying zone: $e');
    }
  }

  Future<bool> sendRegistrationData(Map<String, String?> data) async {
    final url = Uri.parse('$baseUrl/register');
    final body = jsonEncode(data);

    try {
      final response = await http.post(
        url,
        body: body,
        headers: {'Content-Type': 'application/json', 'auth': (await getTokenId() ?? '')});
      return response.statusCode == 201;
    } catch (e) {
      throw('Error sending registration data: $e');
    }
  }

  Future<Map<String,dynamic>> getMe() async{
    final tokenId = await getTokenId();
    final url = Uri.parse('$baseUrl/get-me');
    try {
      final response = await http.get(
        url,
        headers: {'auth': (tokenId ?? '')});
      if (response.statusCode == 200) {
        return Map<String,dynamic>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load user data');
    }
  }

}