# Daily Weather

Daily Weather is a responsive weather application built with Flutter and Dart. It provides real-time weather information for cities around the world using the Open-Meteo API.

## Features

- Search weather by city name
- Real-time weather information
- Current temperature
- Feels-like temperature
- Weather condition
- Humidity
- Wind speed
- 7-day weather forecast
- Use My Location feature
- Refresh weather data
- Responsive and mobile-friendly UI
- Clean and modern interface
- Loading states

## Screens

The application includes:

- Splash Screen
- City Search Screen
- Current Weather Screen
- Weather Details
- 7-Day Forecast
- Location-based Weather

## Technologies Used

- Flutter
- Dart
- REST API
- HTTP
- Open-Meteo Weather API
- Open-Meteo Geocoding API

## API

This project uses Open-Meteo APIs for weather and location data.

### Geocoding API

Used to find the coordinates of a city.

### Forecast API

Used to retrieve:

- Current temperature
- Feels-like temperature
- Humidity
- Wind speed
- Weather condition
- 7-day forecast

## Project Structure

```text
daily_weather/
│
├── android/
├── ios/
├── web/
├── test/
│
├── lib/
│   ├── main.dart
│   └── weather_service.dart
│
├── pubspec.yaml
├── pubspec.lock
└── README.md
