import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../modules/job.dart';
import 'package:xml/xml.dart' as xml;

final LatLng currentLocation = LatLng(25.1193, 55.3773);

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Job> jobs = [];
  final List<Marker> _markers = [];
  bool _isError = false;
  bool _isLoading = false;
  //* I limited the number of items to make it easier to test and trace
  int maxItems = 45;

//* this method is invoked when the widget is created.
  @override
  void initState() {
    super.initState();
    _getFeedData();
    //_addMarkers();
  }

//* this method send an http get request then extract the required fields from the
//* response and create Job object by sending the fields to the Job constructer
//* after making sure the data is correct the Job object is added to the Jobs list
  void _getFeedData() async {
    //* setState() is invoked to update the page whenever any change happens Kinda
    //* like a refresh
    setState(() {
      _isLoading = true;
    });
    try {
      _isError = false;
      var response = await http.get(
        Uri.parse('https://www.rotanacareers.com/live-bookmarks/all-rss.xml'),
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        //* using xml package to parse the response
        final document = xml.XmlDocument.parse(response.body);
        final items = document.findAllElements('item');
        if (items.isNotEmpty) {
          for (int i = 0; i < maxItems; i++) {
            final item = items.elementAt(i);
            final title = item.findElements('title').first.text;
            final city = item.findElements('city').first.text;
            final country = item.findElements('country').first.text;
            if (title.isNotEmpty && city.isNotEmpty && country.isNotEmpty) {
              final job = Job(title: title, city: city, country: country);
              await job.getCoordinates();
              //* this code won't be excuted until the getCoordinate() is done
              if (job.latitude != null && job.longitude != null) {
                print('lat: ${job.latitude} , lon: ${job.longitude}');
                //* if the Coordinates were added correctly the job will be added to the list
                jobs.add(job);
              }
            }
          }
          //* this method is invoked after getting all the data of the jobs to add the
          //* the markers on the map
          _addMarkers();
        } else {
          setState(() {
            _isError = true;
            _isLoading = false;
          });
        }
        setState(() {
          _isError = false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      // handle error
      setState(() {
        _isError = true;
        _isLoading = false;
      });
    }
  }

  void _addMarkers() {
    //* for every job in the list a marker is being created and added to the markers list
    //* by sending the latitude and the longitude of the job
    for (int i = 0; i < jobs.length; i++) {
      final job = jobs[i];
      final marker = Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(job.latitude!, job.longitude!),
          builder: (ctx) => const Icon(
                Icons.location_on,
                color: Colors.red,
              ));
      //  print('Marker: $marker');
      _markers.add(marker);
    }
  }

//* this is the front_end code
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jobs Feed"),
        backgroundColor: Colors.blue,
      ),
      body: _isError
          //* if there's an error this message will be shown
          ? const Center(
              child: Text("Failed to load data. Please try again later."))
          //* if the page is still loading a circular indicator will be shown
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : jobs.isNotEmpty
                  ? Row(
                      children: [
                        Expanded(
                          flex: 1,
                          //* if everything is fine the map will be invoked using flutter_map package
                          child: FlutterMap(
                            options: MapOptions(
                              center: currentLocation,
                              zoom: 5,
                              interactiveFlags:
                                  InteractiveFlag.all - InteractiveFlag.rotate,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName:
                                    'dev.fleaflet.flutter_map.example',
                              ),
                              //! please note that some markers won't appear on the map
                              //! cause their Coordinates are being rejected, out of boundaries
                              //! or so near of each other.
                              MarkerLayer(markers: _markers),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          //* on the other half of the screen the job list will be shown
                          child: ListView.separated(
                            itemCount: jobs.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                title: Text(jobs[index].title!),
                                subtitle: Text(
                                    "${jobs[index].city!}, ${jobs[index].country!}\n"),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return const Divider();
                            },
                            // list view options here
                          ),
                        ),
                      ],
                    )
                  //* if there's no jobs in the list this message will be shown
                  : const Center(child: Text("No jobs found.")),
    );
  }
}
