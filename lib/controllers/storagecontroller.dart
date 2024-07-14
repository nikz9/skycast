import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageController extends GetxController {
  final StorageService _storageService = StorageService();

  void setLanguage(String lang) {
    _storageService.setString("lang", lang);
  }

  String? getLanguage() {
    return _storageService.getString("lang");
  }

  void setTempUnit(String temp) {
    _storageService.setString("temp", temp);
  }

  String? getTempUnit() {
    return _storageService.getString("temp");
  }

  void setLocation(String lat, String long) {
    _storageService.setString("lat", lat);
    _storageService.setString("long", long);
  }

  List<String>? getLocation() {
    List<String> location = [];
    location.add(_storageService.getString("lat").toString());
    location.add(_storageService.getString("long").toString());
    return location;
  }

  void setCache(String timestamp, String weather, String forecast) {
    _storageService.setStringList("json", [timestamp, weather, forecast]);
  }

  List<String>? getCache() {
    List<String>? _cache = _storageService.getStringList("json");
    List<String>? cache = [];
    if (_cache != null) {
      if (DateTime.now()
              .difference(
                DateTime.fromMillisecondsSinceEpoch(
                  int.parse(_cache[0]),
                ),
              )
              .inMinutes <
          1) {
        cache.add(_cache[1]);
        cache.add(_cache[2]);
      }
    }

    return cache;
  }
}

class StorageService {
  static final StorageService _instance = StorageService._internal();
  SharedPreferences? _preferences;

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  Future<void> setString(String key, String value) async {
    await _preferences?.setString(key, value);
  }

  String? getString(String key) {
    return _preferences?.getString(key);
  }

  Future<void> setStringList(String key, List<String> value) async {
    await _preferences?.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return _preferences?.getStringList(key);
  }
}
