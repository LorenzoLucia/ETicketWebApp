import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  final String baseUrl;
  late String user_id;

  Future<String?> getTokenId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  setUserId(String uid) {
    user_id = uid;
  }

  ApiService(this.baseUrl);

  Future<Map<String, double>> fetchZonePrices() async {
    final tokenId = await getTokenId();
    final response = await http.get(
      Uri.parse('$baseUrl/zones'),
      headers: {'auth': (tokenId ?? '')},
    );
    if (response.statusCode == 200) {
      Map<String, double> zonePrices = {};
      final data = jsonDecode(response.body);
      for (var zone in data) {
        zonePrices[zone['name']] = double.parse(zone['price']);
      }

      return zonePrices;
    } else {
      throw Exception('Failed to load zone prices');
    }
  }

  // Future<bool> hasRegisteredPaymentMethods() async {

  //   try {
  //     final tokenId = await getTokenId();
  //     final url = Uri.parse('$baseUrl/$user_id/payment-methods');
  //     final response = await http.get(
  //       url,
  //       headers: {'auth': (tokenId ?? '')});
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       return data['hasPaymentMethods'] ?? false;
  //     } else {
  //       throw Exception('Failed to load payment methods');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //     // return false;
  //     return true; // For debug purposes, always return true
  //   }
  // }

  Future<List<Map<String, dynamic>>> fetchTickets() async {
    try {
      final tokenId = await getTokenId();
      final response = await http.get(
        Uri.parse('$baseUrl/users/$user_id/tickets'),
        headers: {'auth': (tokenId ?? '')},
      );
      if (response.statusCode == 200) {
        print(json.decode(response.body));
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to load tickets');
      }
    } catch (e) {
      // Handle errors appropriately
      throw Exception('Error fetching tickets: $e');
    }
  }

  // Future<Map<String, dynamic>> fetchProfileData() async {
  //   try {
  //     final tokenId = await getTokenId();
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/profile'),
  //       headers: {'auth': (tokenId ?? '')});
  //     if (response.statusCode == 200) {
  //       return Map<String, dynamic>.from(json.decode(response.body));
  //     } else {
  //       throw Exception('Failed to load tickets');
  //     }
  //   } catch (e) {
  //     // Handle errors appropriately
  //     throw Exception('Error fetching tickets: $e');
  //   }
  // }

  Future<List<Map<String, String>>> fetchPaymentMethods() async {
    try {
      final tokenId = await getTokenId();
      final response = await http.get(
        Uri.parse('$baseUrl/users/$user_id/payment-methods'),
        headers: {'auth': (tokenId ?? '')},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<Map<String, String>> paymentMethods = [];

        for (var entry in data) {
          // Assumiamo che ogni entry sia Map<String, dynamic>
          final map = Map<String, String>.from(
            (entry as Map).map(
              (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
            ),
          );
          paymentMethods.add(map);
        }

        return paymentMethods;
      } else {
        throw Exception('Failed to load payment methods');
      }
    } catch (e) {
      throw Exception('Error fetching payment methods: $e');
    }
  }

  Future<String> addPaymentMethod(
    String cardNumber,
    String expiry,
    String cvc,
    String cardOwner,
  ) async {
    final tokenId = await getTokenId();
    final url = Uri.parse('$baseUrl/users/$user_id/payment-methods');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'auth': (tokenId ?? '')},
        body: jsonEncode({
          'card_number': cardNumber,
          'expiry': expiry,
          'cvc': cvc,
          "owner_name": cardOwner,
        }),
      );
      if (response.statusCode == 200) {
        return response
            .body; // Assuming the response contains the ID of the added payment method
      } else {
        throw Exception('Failed to add payment method');
      }
    } catch (e) {
      throw Exception('Error adding payment method: $e');
    }
  }

  Future<void> removePaymentMethod(String methodId) async {
    final tokenId = await getTokenId();
    final url = Uri.parse('$baseUrl/users/$user_id/payment-methods/$methodId');
    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json', 'auth': (tokenId ?? '')},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to remove payment method');
      }
    } catch (e) {
      throw Exception('Error removing payment method: $e');
    }
  }

  Future<List<String>> fetchPlates() async {
    try {
      final tokenId = await getTokenId();
      final response = await http.get(
        Uri.parse('$baseUrl/users/$user_id/plates'),
        headers: {'auth': (tokenId ?? '')},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        return List<String>.from(data);
      } else {
        throw Exception('Failed to load plates');
      }
    } catch (e) {
      // Handle errors appropriately
      throw Exception('Error fetching plates: $e');
    }
  }

  Future<void> addPlate(String plate) async {
    final tokenId = await getTokenId();
    final url = Uri.parse('$baseUrl/users/$user_id/plates');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'auth': (tokenId ?? '')},
        body: jsonEncode({'plate': plate}),
      );
      return;
    } catch (e) {
      throw Exception('Error adding plate: $e');
    }
  }

  Future<void> removePlate(String plate) async {
    final tokenId = await getTokenId();
    final url = Uri.parse('$baseUrl/users/$user_id/plates/$plate');
    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json', 'auth': (tokenId ?? '')},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to remove plate');
      }
    } catch (e) {
      throw Exception('Error removing plate: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final url = Uri.parse('$baseUrl/users');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'auth': (await getTokenId() ?? ''),
        },
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw ('Error fetching users: $e');
    }
  }

  Future<bool> addUser(String email, String name, String surname, String role) async {
    final body = jsonEncode({
      // 'username': username,
      'name': name,
      'surname': surname,
      'email': email,
      'role': role,
    });
    final url = Uri.parse('$baseUrl/users');

    try {
      final response = await http.post(
        url,
        body: body,
        headers: {
          'Content-Type': 'application/json',
          'auth': (await getTokenId() ?? ''),
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      throw ('Error adding user: $e');
    }
  }

  Future<bool> removeUser(String uid) async {
    final url = Uri.parse('$baseUrl/users/$uid');
    final body = jsonEncode({});

    try {
      final response = await http.delete(
        url,
        body: body,
        headers: {
          'Content-Type': 'application/json',
          'auth': (await getTokenId() ?? ''),
        },
      );
      return response.statusCode == 201;
    } catch (e) {
      throw ('Error removing user: $e');
    }
  }

  Future<bool> modifyUser(
    String uid,
    String new_email,
    String new_role,
  ) async {
    final url = Uri.parse('$baseUrl/users/$uid');
    final body = jsonEncode({
      'email': new_email,
      'role': new_role,
    });

    try {
      final response = await http.put(
        url,
        body: body,
        headers: {
          'Content-Type': 'application/json',
          'auth': (await getTokenId() ?? ''),
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      throw ('Error modifying user: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getZones() async {
    final url = Uri.parse('$baseUrl/zones');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'auth': (await getTokenId() ?? ''),
        },
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to load zones');
      }
    } catch (e) {
      throw ('Error fetching zones: $e');
    }
  }

  Future<bool> addZone(String name, double price) async {
    final url = Uri.parse('$baseUrl/zones');
    final body = jsonEncode({'name': name, 'price': price});

    try {
      final response = await http.post(
        url,
        body: body,
        headers: {
          'Content-Type': 'application/json',
          'auth': (await getTokenId() ?? ''),
        },
      );
      return response.statusCode == 201;
    } catch (e) {
      throw ('Error adding zone: $e');
    }
  }

  Future<bool> removeZone(String ZoneId) async {
    final url = Uri.parse('$baseUrl/zones/$ZoneId');
    final body = jsonEncode({});

    try {
      final response = await http.delete(
        url,
        body: body,
        headers: {
          'Content-Type': 'application/json',
          'auth': (await getTokenId() ?? ''),
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      throw ('Error removing zone: $e');
    }
  }

  Future<bool> modifyZone(String ZoneId, String name, double? price) async {
    final url = Uri.parse('$baseUrl/zones/$ZoneId');
    final body = jsonEncode({'zoneName': name, 'price': price});

    try {
      final response = await http.put(
        url,
        body: body,
        headers: {
          'Content-Type': 'application/json',
          'auth': (await getTokenId() ?? ''),
        },
      );
      return response.statusCode == 201;
    } catch (e) {
      throw ('Error modifying zone: $e');
    }
  }

  Future<bool> sendRegistrationData(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/register');
    final body = jsonEncode(data);

    try {
      final response = await http.post(
        url,
        body: body,
        headers: {
          'Content-Type': 'application/json',
          'auth': (await getTokenId() ?? ''),
        },
      );
      return response.statusCode == 201;
    } catch (e) {
      throw ('Error sending registration data: $e');
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    final tokenId = await getTokenId();
    print(tokenId);
    final url = Uri.parse('$baseUrl/get-me');
    try {
      final response = await http.get(url, headers: {'auth': (tokenId ?? '')});
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load user data');
    }
  }

  // TO BE IMPLEMENTED IN BackEnd //
  Future<Map<String, dynamic>> checkTicketStatus(String plate) async {
    final tokenId = await getTokenId();
    final url = Uri.parse('$baseUrl/tickets/$plate');
    try {
      final response = await http.get(url, headers: {'auth': (tokenId ?? '')});
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to check ticket status');
      }
    } catch (e) {
      throw Exception('Error checking ticket status: $e');
    }
  }

  Future<bool> submitFine(String plate) async {
    final tokenId = await getTokenId();
    final url = Uri.parse('$baseUrl/fines');
    final body = jsonEncode({
      'plate': plate,
      'timestamp': DateTime.now().toIso8601String(),
    });
    try {
      final response = await http.post(
        url,
        body: body,
        headers: {'Content-Type': 'application/json', 'auth': (tokenId ?? '')},
      );
      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Error submitting fine: $e');
    }
  }

  Future<bool> payTicket(
    String plate,
    String methodId,
    String amount,
    String duration,
    String zone,
    String? id,
  ) async {
    final tokenId = await getTokenId();
    final url = Uri.parse('$baseUrl/users/$user_id/pay');
    try {
      print(
        jsonEncode({
          'payment_method_id': methodId,
          'amount': amount,
          'duration': duration,
          'zone': zone,
          'ticket_id': id!,
          'plate': plate,
        }),
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'auth': (tokenId ?? '')},
        body: jsonEncode({
          'payment_method_id': methodId,
          'amount': amount,
          'duration': duration,
          'zone': zone,
          'ticket_id': id!,
          'plate': plate,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error paying ticket: $e');
    }
  }
}
