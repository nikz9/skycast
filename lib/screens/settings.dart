import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skycast/controllers/storagecontroller.dart';

class Settings extends StatelessWidget {
  Settings({super.key});
  final storageController = Get.find<StorageController>();

  String getLang() {
    String lang;

    String? check = storageController.getLanguage();
    if (check == "en") {
      lang = "eng".tr;
    } else if (check == "hin") {
      lang = "hin".tr;
    } else {
      lang = "eng".tr;
    }

    return lang;
  }

  String getTemp() {
    String temp;

    String? check = storageController.getTempUnit();
    if (check == "metric") {
      temp = "cel".tr;
    } else if (check == "imperial") {
      temp = "fah".tr;
    } else {
      temp = "cel".tr;
    }

    return temp;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("settings".tr),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 18.sp,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "language".tr,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButtonFormField(
                value: getLang(),
                hint: Text("language".tr),
                items: [
                  DropdownMenuItem(
                    value: "eng".tr,
                    child: Text("eng".tr),
                  ),
                  DropdownMenuItem(
                    value: "hin".tr,
                    child: Text("hin".tr),
                  ),
                ],
                onChanged: (value) {
                  if (value == "eng".tr) {
                    storageController.setLanguage("en");
                    Get.updateLocale(const Locale("en_UK"));
                  } else {
                    storageController.setLanguage("hin");
                    Get.updateLocale(const Locale("hi_in"));
                  }
                },
              ),
              SizedBox(height: 3.h),
              Text(
                "temp_unit".tr,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButtonFormField(
                value: getTemp(),
                hint: Text("temp_unit".tr),
                items: [
                  DropdownMenuItem(
                    value: "cel".tr,
                    child: Text("cel".tr),
                  ),
                  DropdownMenuItem(
                    value: "fah".tr,
                    child: Text("fah".tr),
                  ),
                ],
                onChanged: (value) {
                  if (value == "cel".tr) {
                    storageController.setTempUnit("metric");
                  } else {
                    storageController.setTempUnit("imperial");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
