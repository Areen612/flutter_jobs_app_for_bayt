import 'dart:convert';
import 'package:http/http.dart' as http;

class Job {
  final String? title;
  final String? city;
  final String? country;
  double? latitude;
  double? longitude;
  //* defult constructer
  Job({this.title, this.city, this.country});
  //* this function take the city/country names and return their coordinates
  //* using Nominatim API
  Future<void> getCoordinates() async {
    final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$city, $country&format=json'));
    final data = jsonDecode(response.body);
    if (data.isNotEmpty) {
      final location = data[0];
      latitude = double.parse(location['lat']);
      longitude = double.parse(location['lon']);
    }
  }
}
