// ignore_for_file: prefer_typing_uninitialized_variables, must_be_immutable

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skycast/assets/images.dart';
import 'package:skycast/controllers/homecontroller.dart';
import 'package:skycast/controllers/storagecontroller.dart';
import 'package:skycast/network/api_client.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final controller = Get.find<HomeController>();
  final storageController = Get.find<StorageController>();
  final searchController = TextEditingController();

  final _key = GlobalKey<FormFieldState>();
  RxBool check = false.obs;
  RxBool loading = false.obs;

  Future getWeather() async {
    List<String>? loca = storageController.getLocation();

    final dio = Dio();
    ApiClient apiClient = ApiClient(dio);

    String? unit = storageController.getTempUnit();
    String? lang = storageController.getLanguage();

    List<String>? cache = storageController.getCache();

    if (cache!.isNotEmpty) {
      controller.currentModel =
          CurrentWeather.fromJson(jsonDecode(cache[0])).obs;
      controller.futureModel =
          WeatherForecast.fromJson(jsonDecode(cache[1])).obs;
    } else {
      try {
        if (loca != null) {
          var val = await apiClient.getCurrentWeather(
            "weather?lat=${loca[0]}&lon=${loca[1]}&units=$unit&lang=$lang&appid=0d6c76acfff3a672f2ad1701299e3cd2",
          );
          var val1 = await apiClient.getWeatherForecast(
            "forecast?lat=${loca[0]}&lon=${loca[1]}&units=$unit&lang=$lang&appid=0d6c76acfff3a672f2ad1701299e3cd2",
          );

          controller.currentModel = CurrentWeather.fromJson(val).obs;
          controller.futureModel = WeatherForecast.fromJson(val1).obs;
          storageController.setCache(
            DateTime.now().millisecondsSinceEpoch.toString(),
            jsonEncode(val),
            jsonEncode(val1),
          );
          setState(() {});
        } else {
          var val = await apiClient.getCurrentWeather(
            "weather?lat=19.0760&lon=72.8777&units=$unit&lang=$lang&appid=0d6c76acfff3a672f2ad1701299e3cd2",
          );
          var val1 = await apiClient.getWeatherForecast(
            "forecast?lat=19.0760&lon=72.8777&units=$unit&lang=$lang&appid=0d6c76acfff3a672f2ad1701299e3cd2",
          );

          controller.currentModel = CurrentWeather.fromJson(val).obs;
          controller.futureModel = WeatherForecast.fromJson(val1).obs;
          storageController.setCache(
            DateTime.now().millisecondsSinceEpoch.toString(),
            jsonEncode(val),
            jsonEncode(val1),
          );
          setState(() {});
        }
      } catch (e) {
        Get.closeAllSnackbars();
        Get.snackbar(
          "Network Error",
          "Server error occured, please try later!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Timer.periodic(
      const Duration(minutes: 1),
      (v) {
        getWeather();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Obx(
            () => TextFormField(
              key: _key,
              controller: searchController,
              decoration: InputDecoration(
                hintText: "search".tr,
                icon: const Icon(Icons.search),
                suffixIcon: check.value
                    ? IconButton(
                        onPressed: loading.value
                            ? null
                            : () async {
                                loading.value = true;
                                final dio = Dio();
                                ApiClient apiClient = ApiClient(dio);

                                String? unit = storageController.getTempUnit();
                                String? lang = storageController.getLanguage();

                                List<Location> locations =
                                    await locationFromAddress(
                                  searchController.text.trim(),
                                );

                                storageController.setLocation(
                                  locations[0].latitude.toString(),
                                  locations[0].longitude.toString(),
                                );

                                try {
                                  var val = await apiClient.getCurrentWeather(
                                    "weather?lat=${locations[0].latitude}&lon=${locations[0].longitude}&units=$unit&lang=$lang&appid=0d6c76acfff3a672f2ad1701299e3cd2",
                                  );
                                  controller.updateCurrent(val);

                                  var val1 = await apiClient.getWeatherForecast(
                                    "forecast?lat=${locations[0].latitude}&lon=${locations[0].longitude}&units=$unit&lang=$lang&appid=0d6c76acfff3a672f2ad1701299e3cd2",
                                  );
                                  controller.updateFuture(val1);

                                  searchController.clear();
                                  loading.value = false;
                                  setState(() {});
                                } catch (e) {
                                  Get.closeAllSnackbars();
                                  Get.showSnackbar(GetSnackBar(
                                    title: "err".tr,
                                  ));
                                  loading.value = false;
                                }
                              },
                        icon: loading.value
                            ? const CircularProgressIndicator()
                            : const Icon(Icons.check),
                      )
                    : null,
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  check.value = true;
                } else {
                  check.value = false;
                }
              },
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 18.sp,
            ),
            child: Obx(
              () => Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 15.sp),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.currentModel.value!.name.toString(),
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.sp,
                              ),
                            ),
                            Text(
                              DateTime.now().toString().split(" ")[0],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        SizedBox(
                          height: 15.h,
                          width: 15.h,
                          child: Padding(
                            padding: EdgeInsets.all(20.sp),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.sp),
                              child: Image.asset(
                                Images.map,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 15.sp),
                    child: Container(
                      padding: EdgeInsets.all(12.sp),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.sp),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue.withOpacity(0.7),
                            Colors.blue,
                            Colors.blue,
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 33.sp,
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${"temprature".tr} ${controller.currentModel.value!.main?["temp"].toString()}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 19.sp,
                                      ),
                                    ),
                                    Text(
                                      "${"feels_like".tr} ${controller.currentModel.value!.main?["feels_like"].toString()}",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.white,
                                        Colors.white.withOpacity(0.1),
                                      ],
                                    ).createShader(bounds);
                                  },
                                  child: Image.asset(
                                    Images.sun,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 33.sp,
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${"conditions".tr} ${controller.currentModel.value!.weather?[0]["main"].toString()}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 19.sp,
                                      ),
                                    ),
                                    Text(
                                      "${"time".tr} ${DateTime.now().toString().split(".")[0].split(" ")[1]}",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 20.sp,
                      top: 10.sp,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 33.sp,
                              child: Padding(
                                padding: EdgeInsets.all(11.sp),
                                child: Image.asset(
                                  Images.heavyRain,
                                ),
                              ),
                            ),
                            Text(
                              "${"cloud_cover".tr}: ${controller.currentModel.value!.clouds?["all"]}%",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            SizedBox(
                              height: 33.sp,
                              child: Padding(
                                padding: EdgeInsets.all(11.sp),
                                child: Image.asset(
                                  Images.wind,
                                ),
                              ),
                            ),
                            Text(
                              "${"wind_speed".tr}: ${controller.currentModel.value!.wind?["speed"]} ${"km_h".tr}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            SizedBox(
                              height: 33.sp,
                              child: Padding(
                                padding: EdgeInsets.all(11.sp),
                                child: Image.asset(
                                  Images.sunHeavyRain,
                                ),
                              ),
                            ),
                            Text(
                              "${"Humidity".tr}: ${controller.currentModel.value!.main?["humidity"]}%",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "hourly_forecast".tr,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed("/forecast");
                        },
                        child: Text(
                          "next_days".tr,
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20.h,
                    child: ListView.builder(
                      itemCount: 4,
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(vertical: 15.sp),
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Card(
                              elevation: 10,
                              margin: EdgeInsets.symmetric(horizontal: 11.sp),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.sp),
                              ),
                              child: Container(
                                height: 15.h,
                                width: 19.w,
                                padding: EdgeInsets.symmetric(
                                  vertical: 11.sp,
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      controller.futureModel.value!
                                          .list?[index]["dt_txt"]
                                          .split(" ")[1],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Image.asset(
                                      Images.sun,
                                      height: 6.h,
                                    ),
                                    Text(
                                      controller.futureModel.value!
                                          .list![index]["main"]["temp"]
                                          .toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.toNamed("/settings");
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.sp),
          ),
          child: const Icon(Icons.settings),
        ),
      ),
    );
  }
}
