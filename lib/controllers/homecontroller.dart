// ignore_for_file: file_names

import 'package:get/get.dart';
import 'package:skycast/network/api_client.dart';

class HomeController extends GetxController {
  Rx<CurrentWeather?> currentModel = CurrentWeather().obs;
  Rx<WeatherForecast?> futureModel = WeatherForecast().obs;

  void updateCurrent(dynamic val) {
    currentModel = CurrentWeather.fromJson(val).obs;
    update();
  }

  void updateFuture(dynamic val) {
    futureModel = WeatherForecast.fromJson(val).obs;
    update();
  }
}
