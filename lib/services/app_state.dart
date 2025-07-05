import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  final String baseUrl;

  ApiService? apiService;

  AppState(this.baseUrl) {
    apiService = ApiService(baseUrl);
  }
  Map<String, dynamic>? userData;

  void setApiService(ApiService service) {
    apiService = service;
    notifyListeners();
  }

  void setUserData(Map<String, dynamic> user) {
    userData = user;
    notifyListeners();
  }

  void clear() {
    userData = null;
    apiService = ApiService(baseUrl);
    notifyListeners();
  }
}
