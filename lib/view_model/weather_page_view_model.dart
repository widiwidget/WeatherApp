import 'dart:async';

import 'package:flutter/material.dart';
import 'package:weather_app/model/weather_five_days_with_three_hours_model.dart';
import 'package:weather_app/service/background_image_service.dart';
import '../model/weather_model.dart';
import '../product/api/project_api.dart';
import '../service/notification_service.dart';
import '../service/weather_service.dart';
import '../view/weather_page_view.dart';

abstract class WeatherPageViewModel extends State<WeatherPageView>{
  final String _weatherApiKey = ProjectApi().getWeatherApi;
  final String _baseUrl = "https://api.openweathermap.org/data/2.5";
  final String randomImageUrl = RandomBackgroundImage().url;
  late Timer _timer;
  late final IWeatherService _weatherService;
  WeatherModel? weatherModel;
  late final NotificationService notificationService;
  late Future<void> initBackgroundImageAndWeatherFuture;
  WeatherFiveDaysWithThreeHourModel? weatherThreeHoursModel;
  late final IWeatherService _weatherThreeHoursService;

  @override
  void initState() {
    super.initState();
    initBackgroundImageAndWeatherFuture = _initBackgroundImageAndWeather();
    _startTimer();
    print("weatherThreeHoursModel :${weatherThreeHoursModel?.cityName}");
  }

  Future<void> _initBackgroundImageAndWeather() async {
    await initNotificationAndWeather().then((weather) {
      print(weather?.cityName);
    });
  }

  Future<WeatherModel?> initNotificationAndWeather() async {
    notificationService = NotificationService();
    WeatherModel? weather;
    _weatherService = CurrentWeatherService(apiKey: _weatherApiKey, baseUrl: _baseUrl);
    await _weatherService.getLocationWithPermission();
    await notificationService.initializeNotification(null);
    weather = await _weatherService.getWeatherData();
    await initFiveDaysThreeHoursWeatherData().then((weather) {
      print(weather?.temp);
    });
    setState(() async {
      weatherModel = weather;
    });
    return weather;
  }

  Future<WeatherFiveDaysWithThreeHourModel?> initFiveDaysThreeHoursWeatherData() async {
    WeatherFiveDaysWithThreeHourModel model;
    _weatherThreeHoursService = WeatherServiceForFiveDaysWithThreeHours(apiKey: _weatherApiKey, baseUrl: _baseUrl);
    await _weatherThreeHoursService.getLocationWithPermission();
    model = await _weatherThreeHoursService.getWeatherData();
    print("model :${model.cityName}");
    setState(() {
      weatherThreeHoursModel = model;
    });
    return model;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 20), (timer) {
      _showNotification();
    });
  }

  Future<void> _showNotification() async {
    await notificationService.showNotification(
      title: "${weatherThreeHoursModel?.cityName}",
      body: "${weatherModel?.mainCondition} ${weatherModel?.temp?.toInt()}°",
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

/*
void startPeriodicNotifications() {
  int k = 1;
  _timer = Timer.periodic(const Duration(seconds: 20), (timer) {
    if (weatherThreeHoursModel != null) {
      if (k < (weatherThreeHoursModel?.mainCondition?.length ?? 0)) {
        String? mainCondition = weatherThreeHoursModel?.mainCondition?[k];
        double? temperature = weatherThreeHoursModel?.temp?[k].toInt().toDouble();
        notificationService.showNotification(
          title: "${weatherThreeHoursModel?.cityName}",
          body: "$mainCondition ${temperature?.toInt()}°",
        );
        k += 2;
      } else {
        k = 1;
      }
    }
  });
}*/
