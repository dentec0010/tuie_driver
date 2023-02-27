import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';

class SearchDestinyWidget extends StatefulWidget {
  const SearchDestinyWidget({Key? key}) : super(key: key);

  @override
  State<SearchDestinyWidget> createState() => _SearchDestinyWidgetState();
}

const kGoogleApiKey = 'AIzaSyDnS-LAt0PZd0KgnpBrE24LMjhmMCk4tWE';
final homeScaffoldKey = GlobalKey<ScaffoldState>();
final homeScaffoldKeyD = GlobalKey<ScaffoldState>();

class _SearchDestinyWidgetState extends State<SearchDestinyWidget> {

  CameraPosition initialCameraPosition = const CameraPosition(zoom: 18, target: LatLng(0.0, 0.0));
  double latCliente = 0.0;
  double logCliente = 0.0;

  String ondeEstou = '';
  String ondevou = '';

  String descrisaoActual = '';
  String descrisaoAdm = '';

  double _percent = 0.0;

  Set<Marker> _markers = Set();
  Map<PolylineId, Polyline> polylines = {};
  GoogleMapController? mapController; //controller for Google map
  List<LatLng> polylineCoordinatess = [];
  PolylinePoints polylinePoints = PolylinePoints();
  final Mode _mode = Mode.overlay;
  double distance = 0.0;
  double distanceDestino = 0.0;

  double latitude_cliente = 0;
  double longitude_cliente = 0;

  //------------------- METHOD MAP -------------------- -/
  getDirections(double latitude_origem, double longitude_origem, double latitude_destino, double longitude_destino) async {

    BitmapDescriptor markerbitmaps = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/images/stopy.png",
    );

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      kGoogleApiKey,
      PointLatLng(latitude_origem, longitude_origem),
      PointLatLng(latitude_destino, longitude_destino),
      //travelMode: TravelMode.driving,
    );


    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinatess.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }

    double totalDistance = 0;
    for (var i = 0; i < polylineCoordinatess.length - 1; i++) {
      totalDistance += calculateDistanceClienteDestino(
          polylineCoordinatess[i].latitude,
          polylineCoordinatess[i].longitude,
          polylineCoordinatess[i + 1].latitude,
          polylineCoordinatess[i + 1].longitude);
    }

    setState(() {
      _markers.add(Marker(
        markerId: const MarkerId("1"),
        position: LatLng(latitude_destino, longitude_destino),
        infoWindow: const InfoWindow(title: 'Destino'),
        icon: markerbitmaps,
      ));
      /*mapController!.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat_motorista, log_motorista), zoom: 18)
          //17 is new zoom level
          ));*/
      distance = totalDistance;
      addPolyLine(polylineCoordinatess);
    });

  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.lightBlue,
      points: polylineCoordinates,
      width: 4,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  double calculateDistanceClienteDestino(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p) / 2 + cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  //**************************** PESQUISAR DESTINO ****************************
  Future<void> _pesquisarDestino() async {
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        onError: onErrorD,
        mode: _mode,
        language: 'pt',
        strictbounds: false,
        types: [""],
        decoration: InputDecoration(
          hintText: 'Onde vais?',
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.white)),
        ),
        components: [
          //Component(Component.country, "pk"),
          Component(Component.country, "ao")
        ]);

    displayDestino(p!, homeScaffoldKeyD.currentState);
    List<Placemark> placemark = await placemarkFromCoordinates(latitude_cliente, longitude_cliente);
    descrisaoActual = '${placemark[0].name}';
    descrisaoAdm = '${placemark[0].administrativeArea}';

    ondeEstou = descrisaoActual + ' ' + descrisaoAdm;
  }

  void onErrorD(PlacesAutocompleteResponse response) {
    homeScaffoldKeyD.currentState!.showSnackBar(SnackBar(content: Text(response.errorMessage!)));
  }

  Future<void> displayDestino(Prediction p, ScaffoldState? currentState) async {
    GoogleMapsPlaces placesD = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders());

    PlacesDetailsResponse detail = await placesD.getDetailsByPlaceId(p.placeId!);

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;

    ondevou = detail.result.name;

    mapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 18)
      //17 is new zoom level
    ));

    await getDirections(latitude_cliente, longitude_cliente, lat, lng);

  }


  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
