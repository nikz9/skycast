import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skycast/assets/consts.dart';
import 'package:skycast/controllers/homecontroller.dart';
import 'package:skycast/controllers/storagecontroller.dart';
import 'package:skycast/network/api_client.dart';
import 'package:skycast/screens/forecast.dart';
import 'package:skycast/screens/home.dart';
import 'package:skycast/screens/settings.dart';

final controller = Get.put(HomeController());

Future getLocation() async {
  Location location = Location();

  bool serviceEnabled;
  PermissionStatus permissionGranted;

  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return;
    }
  }

  permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      return;
    }
  }
}

Future getWeather() async {
  Location location = Location();
  var permission = await location.hasPermission();
  LocationData? loca;

  if (permission == PermissionStatus.granted ||
      permission == PermissionStatus.grantedLimited) {
    if (await location.serviceEnabled()) {
      loca = await location.getLocation();
    } else {
      await location.requestService();
      if (await location.serviceEnabled()) {
        loca = await location.getLocation();
      }
    }
  }

  final dio = Dio();
  ApiClient apiClient = ApiClient(dio);
  final storageController = Get.put(StorageController());

  String? unit = storageController.getTempUnit();
  String? lang = storageController.getLanguage();

  List<String>? cache = storageController.getCache();

  if (cache!.isNotEmpty) {
    controller.currentModel = CurrentWeather.fromJson(jsonDecode(cache[1])).obs;
    controller.futureModel = WeatherForecast.fromJson(jsonDecode(cache[2])).obs;
  } else {
    try {
      if (loca != null) {
        storageController.setLocation(
          loca.latitude.toString(),
          loca.longitude.toString(),
        );

        var val = await apiClient.getCurrentWeather(
          "weather?lat=${loca.latitude}&lon=${loca.longitude}&units=$unit&lang=$lang&appid=0d6c76acfff3a672f2ad1701299e3cd2",
        );

        var val1 = await apiClient.getWeatherForecast(
          "forecast?lat=${loca.latitude}&lon=${loca.longitude}&units=$unit&lang=$lang&appid=0d6c76acfff3a672f2ad1701299e3cd2",
        );

        controller.currentModel = CurrentWeather.fromJson(val).obs;
        controller.futureModel = WeatherForecast.fromJson(val1).obs;
        storageController.setCache(
          DateTime.now().millisecondsSinceEpoch.toString(),
          jsonEncode(val),
          jsonEncode(val1),
        );
      } else {
        var val = await apiClient.getCurrentWeather(
          "weather?lat=19.0760&lon=72.8777&units=$unit&lang=$lang&appid=0d6c76acfff3a672f2ad1701299e3cd2",
        );

        var val1 = await apiClient.getWeatherForecast(
          "forecast?lat=19.0760&lon=72.8777&units=$unit&lang=$lang&appid=0d6c76acfff3a672f2ad1701299e3cd2",
        );

        controller.currentModel = CurrentWeather.fromJson(val).obs;
        controller.futureModel = WeatherForecast.fromJson(val).obs;
        storageController.setCache(
          DateTime.now().millisecondsSinceEpoch.toString(),
          jsonEncode(val),
          jsonEncode(val1),
        );
      }
    } catch (e) {
      Get.closeAllSnackbars();
      Get.snackbar(
        "Network Error",
        "Server error occured, please try later!",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService().init();
  await getLocation();
  await getWeather();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final storageController = Get.put(StorageController());

  Locale getLang() {
    Locale lang;

    String? check = storageController.getLanguage();
    if (check == "en") {
      lang = const Locale("en_UK");
    } else if (check == "hin") {
      lang = const Locale("hi_in");
    } else {
      lang = const Locale("en_UK");
    }

    return lang;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return GetMaterialApp(
          initialBinding: Binding(),
          title: "SkyCast",
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
            ),
            useMaterial3: true,
          ),
          translations: Consts(),
          locale: getLang(),
          fallbackLocale: const Locale("en", "UK"),
          initialRoute: "/home",
          getPages: [
            GetPage(
              name: "/home",
              page: () => const Home(),
            ),
            GetPage(
              name: "/forecast",
              page: () => Forecast(),
            ),
            GetPage(
              name: "/settings",
              page: () => Settings(),
            ),
          ],
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.lazyPut(() => StorageController(), fenix: true);
  }
}
