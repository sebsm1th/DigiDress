import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  Map<String, dynamic>? weatherData;
  bool isLoading = true;

  // OpenWeatherMap API Key
  final String apiKey = '9bed8a23f096d258cbf41798a94c060a';

  @override
  void initState() {
    super.initState();
    fetchWeatherData();  // Fetch weather data when the page is loaded
  }

  // Function to determine the user's current location
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    // Get the user's current location
    return await Geolocator.getCurrentPosition();
  }

  // Function to fetch weather data using latitude and longitude
  Future<void> fetchWeatherData() async {
    try {
      // Get the user's location
      Position position = await _determinePosition();
      double latitude = position.latitude;
      double longitude = position.longitude;

      // Build the OpenWeatherMap API URL with lat/lon for 5-day forecast
      final String apiUrl =
          'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          weatherData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        print('Failed to load weather data');
      }
    } catch (e) {
      print('Error fetching weather data: $e');
    }
  }

  // Extract weather information from the API response
  Widget buildWeatherInfo() {
    if (weatherData == null) {
      return const Center(child: Text('No weather data available'));
    }

    // Get the first forecast data (most current forecast)
    final forecast = weatherData!['list'][0];  // First item in the forecast list

    // Extract necessary weather information
    final String cityName = weatherData!['city']['name'];
    final double temp = forecast['main']['temp'];
    final double feelsLike = forecast['main']['feels_like'];
    final double tempMin = forecast['main']['temp_min'];
    final double tempMax = forecast['main']['temp_max'];
    final String description = forecast['weather'][0]['description'];
    final int humidity = forecast['main']['humidity'];
    final double windSpeed = forecast['wind']['speed'];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('City: $cityName', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('Temperature: ${temp.toStringAsFixed(1)}°C', style: const TextStyle(fontSize: 18)),
          Text('Feels Like: ${feelsLike.toStringAsFixed(1)}°C', style: const TextStyle(fontSize: 18)),
          Text('Min Temperature: ${tempMin.toStringAsFixed(1)}°C', style: const TextStyle(fontSize: 18)),
          Text('Max Temperature: ${tempMax.toStringAsFixed(1)}°C', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Text('Weather: $description', style: const TextStyle(fontSize: 18)),
          Text('Humidity: $humidity%', style: const TextStyle(fontSize: 18)),
          Text('Wind Speed: ${windSpeed.toStringAsFixed(1)} m/s', style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Information'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())  // Display loading spinner while fetching data
          : buildWeatherInfo(),  // Display weather information once data is fetched
    );
  }
}
