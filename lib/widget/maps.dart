import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class Maps extends StatefulWidget {
  const Maps({Key? key}) : super(key: key);

  @override
  MapsState createState() => MapsState();
}

class MapsState extends State<Maps> {
  late GoogleMapController googleMapController;
  static const CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(-7.983908, 112.621391), zoom: 14);
  Set<Marker> markers = {};

  static LatLng _center = const LatLng(-7.983908, 112.621391);

  MapType _currentMapType = MapType.normal;
  LatLng _lastMapPosition = _center;

  final Geolocator geolocator = Geolocator();

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition();

    return position;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onCameraMove: _onCameraMove,
          markers: markers,
          mapType: _currentMapType,
          onMapCreated: (GoogleMapController controller) {
            googleMapController = controller;
          },
          initialCameraPosition: CameraPosition(target: _center, zoom: 11.0),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.topRight,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: _onMapTypeButtonPressed,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Colors.blueGrey,
                  child: const Icon(
                    Icons.map_sharp,
                    size: 36.0,
                  ),
                ),
                const SizedBox(height: 16.0),
                FloatingActionButton(
                    onPressed: () async {
                      Position position = await _getCurrentLocation();

                      googleMapController.animateCamera(
                          CameraUpdate.newCameraPosition(CameraPosition(
                              target:
                                  LatLng(position.latitude, position.longitude),
                              zoom: 14)));

                      markers.clear();

                      markers.add(Marker(
                          markerId: const MarkerId('currentLocation'),
                          position:
                              LatLng(position.latitude, position.longitude)));

                      setState(() {});
                    },
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Colors.redAccent,
                    child: const Icon(Icons.location_on))
              ],
            ),
          ),
        )
      ],
    );
  }
}
