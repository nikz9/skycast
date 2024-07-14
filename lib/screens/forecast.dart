import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skycast/assets/images.dart';
import 'package:skycast/controllers/homecontroller.dart';

class Forecast extends StatelessWidget {
  Forecast({super.key});
  final controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("hourly_forecast".tr),
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            height: 88.h,
            child: ListView.builder(
              itemCount: controller.futureModel.value!.cnt!.toInt(),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.asset(
                    Images.starts,
                    height: 6.h,
                  ),
                  title: Text(
                    "${"time".tr}  ${DateTime.fromMillisecondsSinceEpoch(controller.futureModel.value!.list![index]["dt"] * 1000).toString().split(" ")[1].split(".")[0]}",
                  ),
                  subtitle: Text(
                      "${"temprature".tr} ${controller.futureModel.value!.list![index]["main"]["temp"].toString()} ${"humidity".tr} ${controller.futureModel.value!.list![index]["main"]["humidity"].toString()}"),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
