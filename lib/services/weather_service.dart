import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/weather_model.dart';

class WeatherException implements Exception {
  final String message;
  const WeatherException(this.message);

  @override
  String toString() => message;
}

class WeatherService {
  static const String _apiKey = '94870090e1174146343af5280e6c7d02';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Weather> fetchWeatherByCity(String city) async {
    final query = city.trim();
    if (query.isEmpty) {
      throw const WeatherException('Please enter a city name.');
    }

    final uri = Uri.parse(
      '$_baseUrl?q=${Uri.encodeComponent(query)}&appid=$_apiKey&units=metric',
    );

    final http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 10));
    } on SocketException {
      throw const WeatherException('No internet connection. Please try again.');
    } on TimeoutException {
      throw const WeatherException('Request timed out. Please try again.');
    } catch (_) {
      throw const WeatherException('Something went wrong. Please try again.');
    }

    switch (response.statusCode) {
      case 200:
        return Weather.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      case 404:
        throw WeatherException('City "$query" not found. Check the spelling.');
      case 401:
        throw const WeatherException(
          'Invalid API key. Add a valid OpenWeatherMap key in weather_service.dart.',
        );
      default:
        throw const WeatherException('Server error. Please try again later.');
    }
  }
}
