import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:connectivity_plus/connectivity_plus.dart';

class Service {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    id: json['id'].toString(),
    name: json['name'],
    description: json['description'],
    imageUrl: json['imageUrl'],
    price: (json['price'] as num).toDouble(),
  );
}

class ServiceProvider extends ChangeNotifier {
  List<Service> _services = [];
  bool _isOnline = true;
  bool _loading = false;

  List<Service> get services => _services;
  bool get isOnline => _isOnline;
  bool get loading => _loading;

  Future<void> fetchServices() async {
    _loading = true;
    notifyListeners();
    final connectivity = await Connectivity().checkConnectivity();
    _isOnline = connectivity != ConnectivityResult.none;
    try {
      if (_isOnline) {
        // Replace with your actual API endpoint or a mock JSON URL
        final response = await http.get(Uri.parse('https://raw.githubusercontent.com/SalonKuz/demo/main/services.json'));
        if (response.statusCode == 200) {
          final List data = json.decode(response.body);
          _services = data.map((e) => Service.fromJson(e)).toList();
        } else {
          await _loadLocalServices();
        }
      } else {
        await _loadLocalServices();
      }
    } catch (e) {
      await _loadLocalServices();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> _loadLocalServices() async {
    final jsonStr = await rootBundle.loadString('assets/services.json');
    final List data = json.decode(jsonStr);
    _services = data.map((e) => Service.fromJson(e)).toList();
  }
}

