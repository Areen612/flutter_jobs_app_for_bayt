// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_application_for_bayt/packages/home/body.dart';
import 'package:latlong2/latlong.dart';

//* Defult location of the camera on the map is Dubai
final LatLng currentLocation = LatLng(25.1193, 55.3773);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bayt',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Jobs'),
    );
  }
}
