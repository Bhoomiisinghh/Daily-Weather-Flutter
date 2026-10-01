import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'weather_service.dart';

void main() {
  runApp(const DailyWeatherApp());
}

class DailyWeatherApp extends StatelessWidget {
  const DailyWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daily Weather',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const WelcomePage(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B82F6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.cloud_rounded,
              size: 90,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'Daily Weather',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Weather made simple',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController cityController = TextEditingController();
  final WeatherService weatherService = WeatherService();

  bool loading = false;

  Future<void> searchCity() async {
    if (cityController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      loading = true;
    });

    final location = await weatherService.getCoordinates(
      cityController.text.trim(),
    );

    if (location != null) {
      final weather = await weatherService.getWeather(
        location['latitude'],
        location['longitude'],
      );

      if (weather != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WeatherPage(
              cityName: location['name'],
              countryName: location['country'],
              latitude: location['latitude'],
              longitude: location['longitude'],
              weatherData: weather,
            ),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> useMyLocation() async {
    setState(() {
      loading = true;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      setState(() {
        loading = false;
      });

      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        loading = false;
      });

      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();

      final weather = await weatherService.getWeather(
        position.latitude,
        position.longitude,
      );

      if (weather != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WeatherPage(
              cityName: 'My Location',
              countryName: '',
              latitude: position.latitude,
              longitude: position.longitude,
              weatherData: weather,
            ),
          ),
        );
      }
    } catch (e) {
      //
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.cloud_rounded,
                    size: 90,
                    color: Color(0xFF3B82F6),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Daily Weather',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Check the weather anywhere',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: cityController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => searchCity(),
                    decoration: InputDecoration(
                      hintText: 'Enter city name',
                      prefixIcon: const Icon(Icons.location_city),
                      suffixIcon: IconButton(
                        onPressed: loading ? null : searchCity,
                        icon: const Icon(Icons.search),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: loading ? null : searchCity,
                      icon: const Icon(Icons.search),
                      label: const Text(
                        'Search Weather',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: loading ? null : useMyLocation,
                      icon: const Icon(Icons.my_location),
                      label: const Text(
                        'Use My Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF3B82F6),
                        side: const BorderSide(
                          color: Color(0xFF3B82F6),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  if (loading) ...[
                    const SizedBox(height: 25),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WeatherPage extends StatefulWidget {
  final String cityName;
  final String countryName;
  final double latitude;
  final double longitude;
  final Map<String, dynamic> weatherData;

  const WeatherPage({
    super.key,
    required this.cityName,
    required this.countryName,
    required this.latitude,
    required this.longitude,
    required this.weatherData,
  });

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late Map<String, dynamic> weatherData;
  final WeatherService weatherService = WeatherService();

  bool refreshing = false;

  @override
  void initState() {
    super.initState();
    weatherData = widget.weatherData;
  }

  Future<void> refreshWeather() async {
    setState(() {
      refreshing = true;
    });

    final result = await weatherService.getWeather(
      widget.latitude,
      widget.longitude,
    );

    if (result != null && mounted) {
      setState(() {
        weatherData = result;
      });
    }

    if (mounted) {
      setState(() {
        refreshing = false;
      });
    }
  }

  String weatherDescription(int code) {
    if (code == 0) return 'Clear Sky';
    if (code <= 3) return 'Partly Cloudy';
    if (code == 45 || code == 48) return 'Foggy';
    if (code >= 51 && code <= 67) return 'Drizzle / Rain';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Rain';
    if (code >= 95) return 'Thunderstorm';
    return 'Unknown';
  }

  IconData weatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny_rounded;
    if (code <= 3) return Icons.cloud_rounded;
    if (code == 45 || code == 48) return Icons.cloud_rounded;
    if (code >= 51 && code <= 67) return Icons.water_drop_rounded;
    if (code >= 71 && code <= 77) return Icons.ac_unit_rounded;
    if (code >= 80 && code <= 82) {
      return Icons.water_drop_rounded;
    }
    if (code >= 95) return Icons.thunderstorm_rounded;
    return Icons.cloud_rounded;
  }

  String getDayName(String date) {
    final day = DateTime.parse(date).weekday;

    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return days[day - 1];
  }

  @override
  Widget build(BuildContext context) {
    final current = weatherData['current'];
    final daily = weatherData['daily'];

    final int weatherCode = current['weather_code'];
    final double temperature =
        (current['temperature_2m'] as num).toDouble();
    final double feelsLike =
        (current['apparent_temperature'] as num).toDouble();
    final int humidity = current['relative_humidity_2m'];
    final double windSpeed =
        (current['wind_speed_10m'] as num).toDouble();

    final List dates = daily['time'];
    final List maxTemps = daily['temperature_2m_max'];
    final List minTemps = daily['temperature_2m_min'];
    final List codes = daily['weather_code'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: refreshWeather,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Daily Weather',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: refreshing ? null : refreshWeather,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.cityName,
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF3B82F6),
                      Color(0xFF2563EB),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.countryName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Icon(
                      weatherIcon(weatherCode),
                      size: 70,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${temperature.round()}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      weatherDescription(weatherCode),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Feels like ${feelsLike.round()}°',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.water_drop_rounded,
                      title: 'Humidity',
                      value: '$humidity%',
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.air_rounded,
                      title: 'Wind',
                      value: '${windSpeed.round()} km/h',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const Text(
                '7-Day Forecast',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 155,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: dates.length,
                  itemBuilder: (context, index) {
                    return _ForecastCard(
                      day: getDayName(dates[index]),
                      icon: weatherIcon(codes[index]),
                      maxTemp: maxTemps[index],
                      minTemp: minTemps[index],
                    );
                  },
                ),
              ),
              const SizedBox(height: 25),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.search),
                label: const Text('Search Another City'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              if (refreshing) ...[
                const SizedBox(height: 20),
                const Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF3B82F6),
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  final String day;
  final IconData icon;
  final dynamic maxTemp;
  final dynamic minTemp;

  const _ForecastCard({
    required this.day,
    required this.icon,
    required this.maxTemp,
    required this.minTemp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 125,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day.substring(0, 3),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Icon(
            icon,
            size: 32,
            color: const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 10),
          Text(
            '${maxTemp.round()}° / ${minTemp.round()}°',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}