import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  Future<Map<String, dynamic>?> getCoordinates(String city) async {
    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search'
      '?name=${Uri.encodeComponent(city)}'
      '&count=1'
      '&language=en'
      '&format=json',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['results'] != null && data['results'].isNotEmpty) {
          final location = data['results'][0];

          return {
            'name': location['name'],
            'country': location['country'] ?? '',
            'latitude': location['latitude'],
            'longitude': location['longitude'],
          };
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getWeather(
    double latitude,
    double longitude,
  ) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$latitude'
      '&longitude=$longitude'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,wind_speed_10m,weather_code'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min'
      '&timezone=auto'
      '&forecast_days=7',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'current': data['current'],
          'daily': data['daily'],
        };
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}