import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "https://api.openweathermap.org/data/2.5/")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @GET("{endpoint}")
  Future getCurrentWeather(@Path("endpoint") String endpoint);

  @GET("{endpoint}")
  Future getWeatherForecast(@Path("endpoint") String endpoint);
}

@JsonSerializable()
class CurrentWeather {
  Map<String, num>? coord;
  List<Map<String, dynamic>>? weather;
  String? base;
  Map<String, num>? main;
  num? visibility;
  Map<String, num>? wind;
  Map<String, num>? rain;
  Map<String, num>? clouds;
  num? dt;
  Map<String, dynamic>? sys;
  num? timezone;
  num? id;
  String? name;
  dynamic cod;

  CurrentWeather({
    this.coord,
    this.weather,
    this.base,
    this.main,
    this.visibility,
    this.wind,
    this.rain,
    this.clouds,
    this.dt,
    this.sys,
    this.timezone,
    this.id,
    this.name,
    this.cod,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) =>
      _$CurrentWeatherFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentWeatherToJson(this);
}

@JsonSerializable()
class WeatherForecast {
  String? cod;
  num? message;
  num? cnt;
  List<Map<String, dynamic>>? list;

  WeatherForecast({
    this.cod,
    this.message,
    this.cnt,
    this.list,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) =>
      _$WeatherForecastFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherForecastToJson(this);
}
