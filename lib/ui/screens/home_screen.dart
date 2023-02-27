import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_network_connectivity/flutter_network_connectivity.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:tuie_driver/constants/constant_color.dart';
import 'package:tuie_driver/ui/screens/about_us_screen.dart';
import 'package:tuie_driver/ui/screens/edit_profile_screen.dart';
import 'package:tuie_driver/ui/screens/help_screen.dart';
import 'package:tuie_driver/ui/screens/payment_screen.dart';
import 'package:tuie_driver/ui/screens/promotion_screen.dart';
import 'package:tuie_driver/ui/screens/riders_screen.dart';
import 'package:tuie_driver/ui/widgets/search_destination_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

const kGoogleApiKey = 'AIzaSyDnS-LAt0PZd0KgnpBrE24LMjhmMCk4tWE';
final homeScaffoldKey = GlobalKey<ScaffoldState>();
final homeScaffoldKeyD = GlobalKey<ScaffoldState>();

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {

  CameraPosition initialCameraPosition = const CameraPosition(zoom: 18, target: LatLng(0.0, 0.0));
  Position ? _position;
  double latCliente = 0;
  double logCliente = 0;
  double latitude_cliente = 0;
  double longitude_cliente = 0;
  double latitude_destino = 0;
  double longitude_destino = 0;

  String ondeEstou = '';
  String ondevou = '';

  String descrisaoActual = '';
  String descrisaoAdm = '';

  double _percent = 0.0;
  bool map = false;
  bool route = false;
  bool solicitation = false;

  bool economico = false;
  bool conforto = false;

  bool isChecked = false;
  Duration _duration = Duration(milliseconds: 370);
  Animation<Alignment>? _animation;
  AnimationController? _animationController;


  Set<Marker> _markers = Set();
  Map<PolylineId, Polyline> polylines = {};
  GoogleMapController? mapController; //controller for Google map
  List<LatLng> polylineCoordinatess = [];
  PolylinePoints polylinePoints = PolylinePoints();
  final Mode _mode = Mode.overlay;
  double distance = 0.0;
  double distanceDestino = 0.0;

   double totalEconomico = 0;
   double totalConforto = 0;



  final FlutterNetworkConnectivity _flutterNetworkConnectivity =
  FlutterNetworkConnectivity(
    isContinousLookUp: true,
    lookUpDuration: const Duration(seconds: 5),
  );

  bool? _isInternetAvailableOnCall;
  bool _isInternetAvailableStreamStatus = false;

  StreamSubscription<bool>? _networkConnectionStream;

  //********************** INITSTATE ********************** */
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _flutterNetworkConnectivity.getInternetAvailabilityStream().listen((event) {
      _isInternetAvailableStreamStatus = event;
      setState(() {});
    });
    init();

    _animationController =
        AnimationController(vsync: this, duration: _duration);
    _animation =
        AlignmentTween(begin: Alignment.centerLeft, end: Alignment.centerRight)
            .animate(
          CurvedAnimation(
            parent: _animationController!,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeIn,
          ),
        );
  }

  @override
  void dispose() {
    _networkConnectionStream?.cancel();
    _flutterNetworkConnectivity.unregisterAvailabilityListener();
    _animationController!.dispose();
    super.dispose();
  }

  void init() async {
    await _flutterNetworkConnectivity.registerAvailabilityListener();
  }


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

    setState(() async {
      _markers.add(Marker(
        markerId: const MarkerId("1"),
        position: LatLng(latitude_destino, longitude_destino),
        infoWindow: const InfoWindow(title: 'Destino'),
        icon: markerbitmaps,
      ));

      distance = totalDistance;
      polylines.clear();
      addPolyLine(polylineCoordinatess);
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude_destino, longitude_destino);
      Placemark place = placemarks[0];
      ondevou = place.street! +', ' + place.subAdministrativeArea! +', ' + place.administrativeArea!;
      route = true;
      _calcularPreco(distance);
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
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }


  void _getCurrentLocation() async {
    Position position = await _determinePosition();
    setState(() {
      _position = position;
      longitude_cliente = _position!.longitude;
      latitude_cliente = _position!.latitude;
    });
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location Permissions are denied');
      }
    }
    return await Geolocator.getCurrentPosition();
  }


  double _calcularPreco(double kilometro) {
    double preco_inicial = 800;
    double preco_adicional = 200;
    double kilometro_inicial = 3;
    double kilometro_adicional = 1;
    double sub_total = 0;

    if (kilometro <= kilometro_inicial) {
      totalEconomico = preco_inicial;
      totalConforto = preco_inicial + 500;
    } else if (kilometro > kilometro_inicial) {
      double valor = kilometro - kilometro_inicial;
      //double valor1 = preco_adicional * kilometro_adicional;
      for (int i = 0; i <= valor; i++) {
        sub_total = i * preco_adicional;
      }
      setState((){
      totalEconomico = preco_inicial + sub_total;
      totalConforto = preco_inicial + sub_total + 500;
      });

    }
    //print(total);
    return totalEconomico;
  }

  _offOnline(){
    return AnimatedBuilder(
      animation: _animationController!,
      builder: (context, child) {
        return Center(
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              setState(
                    () {
                  if (_animationController!.isCompleted) {
                    _animationController!.reverse();
                  } else {
                    _animationController!.forward();
                  }
                  isChecked = !isChecked;
                },
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Container(
                  width: 40,
                  height: 40,
                  padding: EdgeInsets.fromLTRB(0, 6, 0, 6),
                  decoration: BoxDecoration(
                    color: isChecked ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.all(
                      Radius.circular(99),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isChecked
                            ? Colors.green.withOpacity(0.6)
                            : Colors.red.withOpacity(0.6),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: _animation!.value,
                        child: GestureDetector(
                          onTap: () {
                            setState(
                                  () {
                                if (_animationController!.isCompleted) {
                                  _animationController!.reverse();
                                } else {
                                  _animationController!.forward();
                                }
                                isChecked = !isChecked;
                              },
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  isChecked ? 'N' : 'F',
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 42,
                    color: ConstantColor.blackColor,
                  ),
                )

              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (economico || conforto) {
          setState(() {
            economico = false;
            conforto = false;
          });
          return false;
        } else {
          setState(() {
            economico = false;
            conforto = false;
          });
          return false;
        }
      },
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          endDrawerEnableOpenDragGesture: false,
          body: Stack(
            children: [

              //************************** MAP ***************************** */
              Positioned.fill(
                bottom: MediaQuery.of(context).size.height * 0.15,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  child: GoogleMap(
                    mapType: MapType.normal,
                    myLocationEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(latCliente, logCliente),
                      zoom: 14,
                    ),
                    myLocationButtonEnabled: true,
                    markers: _markers,
                    polylines: Set<Polyline>.of(polylines.values),
                    onMapCreated: (controller) {
                      setState(() {
                        mapController = controller;
                      });
                    },
                  ),
                ),
              ),

              //---------------------- MENU BUTTON --------------------------
             Positioned(
                top: MediaQuery.of(context).size.height * 0.02,
                left: MediaQuery.of(context).size.width * 0.02,
                child: FloatingActionButton(
                  child: const Icon(
                    Icons.menu,
                    color: ConstantColor.blackColor,
                  ),
                  backgroundColor: ConstantColor.whiteColor,
                  onPressed: () => _scaffoldKey.currentState!.openDrawer(),
                ),
              ),


              //---------------------- CHECK INTERNET --------------------------
              _isInternetAvailableStreamStatus ?
              Text(
                '',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: ConstantColor.blackColor,
                ),
              )

              :

              Positioned(
                top: MediaQuery.of(context).size.height / 9,
                left: MediaQuery.of(context).size.width / 8,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: ConstantColor.colorPrimary,
                  ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                          Icon(
                            Icons.warning,
                            size: 50,
                            color: ConstantColor.whiteColor,
                          ),
                          Text(
                            'Estas Offline, Conecte-se a internet.',
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: ConstantColor.whiteColor,
                            ),
                          ),
                      ],
                    ),
                  ),
              ),


              //---------------------- DRAWERS --------------------------
              Positioned(
                child: NotificationListener<DraggableScrollableNotification>(
                  onNotification: (notification){
                    setState(() {
                      _percent = 2 * notification.extent - 0.6;
                    });
                    return true;
                  },
                  child: DraggableScrollableSheet(
                    maxChildSize:  0.90,
                    minChildSize: 0.2,
                    initialChildSize: route ? 0.45 : 0.25,
                    builder: (_, controller) {
                      return Material(
                        elevation: 20,
                        color: ConstantColor.whiteColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Container(
                                    height: 5,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50.0),
                                      color: ConstantColor.colorClickButton,
                                    ),
                                  ),
                                ),
                              ),

                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          route ? 'A caminho  ' : 'É bom ter você aqui.',
                                          style: GoogleFonts.quicksand(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: ConstantColor.colorClickButton,
                                          ),
                                        ),

                                        route ? LoadingAnimationWidget.discreteCircle(
                                          color: ConstantColor.colorPrimary,
                                          size: 10,
                                        ) : Container(),
                                      ],
                                    ),



                                    _offOnline(),
                                  ],
                                ),
                              ),

                              route ? _clientDataRideAcept('Tuie Comigo', 'Economico', '1000', -8.886892722268989, 13.246079719889684)
                                  :
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height / 9,
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                  //border: Border.all(width: 1, color: Colors.black38),
                                ),
                                child: FutureBuilder<List>(
                                  //future: getRacing(),
                                  builder: (context, snapshot) {

                                      //ListRacing(list: snapshot.data as List);
                                      return isChecked ? ListView.builder(
                                        scrollDirection: Axis.vertical,
                                        itemCount: 12,
                                        padding: EdgeInsets.only(left: 10),
                                        itemBuilder: (context, index) {

                                          return InkWell(
                                            onTap: () {
                                              showDialog(context: context, builder: (BuildContextcontext) {
                                                return Dialog(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20.0)),
                                                  child: Container(
                                                    height: MediaQuery.of(context).size.height / 1.8,
                                                    width: MediaQuery.of(context).size.width - 10,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(20),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [

                                                          //--------------- TITLE ---------- -/
                                                          Text(
                                                            "Corrida Solicitada",
                                                            style: GoogleFonts.quicksand(
                                                                color: Colors.black,
                                                                fontSize: 20,
                                                                fontWeight: FontWeight.bold),
                                                          ),

                                                          const SizedBox(height: 10),

                                                          //--------------- NAME -------------- -/
                                                          Text(
                                                            'Tuie',
                                                            style: GoogleFonts.quicksand(
                                                                color: Colors.black,
                                                                fontSize: 20,
                                                                fontWeight: FontWeight.bold),
                                                          ),

                                                          const SizedBox(height: 5,),

                                                          //--------------- PHONE ---------------- -/
                                                          Text(
                                                            'Comigo',
                                                            style: GoogleFonts.quicksand(
                                                                color: Colors.black,
                                                                fontSize: 20,
                                                                fontWeight: FontWeight.normal
                                                            ),
                                                          ),

                                                          const SizedBox(height: 20,),

                                                          //--------------- ADRESS & TIME --------- -/
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Column(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  _adressTimeItem(Icons.location_on,'Camama', Colors.green),
                                                                  SizedBox(height: 10,),
                                                                  _adressTimeItem(Icons.location_on, 'Golf-2', Colors.red),
                                                                ],
                                                              ),

                                                              Container(
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons.money,
                                                                      size: 20,
                                                                      color: Colors.black,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 1,
                                                                    ),

                                                                    Text(
                                                                      ' AOA',
                                                                      style: GoogleFonts.quicksand(
                                                                          color: Colors.black,
                                                                          fontSize:  12,
                                                                          fontWeight: FontWeight.bold),
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              /*_adressTimeItem(
                                                            Icons.money,
                                                            snapshot.data![index]['valor_total_corrida'] + ' AOA',
                                                            ColorConstant.colorPrimary
                                                          ),*/
                                                            ],
                                                          ),

                                                          const SizedBox(height: 20,),

                                                          //---------------- WISHES -------------- -/
                                                          Column(
                                                            children: [
                                                              _witches('Economico', ""),
                                                              const SizedBox(height: 20,),
                                                              _witches("Total", ' AOA'),
                                                            ],
                                                          ),

                                                          const SizedBox(height: 20,),

                                                          SizedBox(
                                                            width: MediaQuery.of(context).size.width,
                                                            child: Container(
                                                              width: MediaQuery.of(context).size.width,
                                                              height: MediaQuery.of(context).size.height / 14,
                                                              child: RaisedButton(
                                                                onPressed: ()  {
                                                                  setState(() async{
                                                                    await getDirections(latitude_cliente, longitude_cliente, -8.886892722268989, 13.246079719889684);
                                                                    await updateCameraLocation(LatLng(latitude_cliente, longitude_cliente), LatLng(-8.886892722268989, 13.246079719889684), mapController!);
                                                                    Navigator.pop(context);
                                                                  });
                                                                },
                                                                child: Text(
                                                                  "Aceitar Corrida",
                                                                  style: GoogleFonts.quicksand(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                                                ),
                                                                color: Colors.black,
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              });
                                            },
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              height: MediaQuery.of(context).size.height * 0.04,
                                              padding: const EdgeInsets.all(5),
                                              decoration: const BoxDecoration(
                                                color: Colors.transparent,
                                                //border: Border.all(width: 1, color: Colors.black38),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  Container(
                                                    width: MediaQuery.of(context).size.width / 3.5,
                                                    child: Text(
                                                      'Camama',
                                                      style: GoogleFonts.quicksand(color: Colors.black,
                                                        fontSize:16,
                                                        fontWeight: FontWeight.normal,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),

                                                  //-------------------- ICON STATE ---------------- -/
                                                  Container(
                                                    width: MediaQuery.of(context).size.width / 3.5,
                                                    child: Text(
                                                      'Golf-2',
                                                      style: GoogleFonts.quicksand(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.normal),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),

                                                  Container(
                                                    width: MediaQuery.of(context).size.width / 3.5,
                                                    child: Text(
                                                     '1000 AOA',
                                                      style: GoogleFonts.quicksand(color: Colors.black,
                                                          fontSize:  16,
                                                          fontWeight: FontWeight.normal),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),

                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                      :
                                      Container(
                                        height: 40,
                                        width: 40,
                                        child: Center(
                                          child: LoadingAnimationWidget.discreteCircle(
                                            color: ConstantColor.whiteColor,
                                            size: 30,
                                          ),
                                        )
                                    );
                                  },
                                ),

                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ),

              //------------------------ SEARCH DESTINY --------------------------
              Positioned(
                right: 0,
                left: 0,
                top: -190 * (1 - _percent),
                //top: -(MediaQuery.of(context).size.height * 0.2) * (1 - _percent),
                child: const SearchDestinationWidget()
              ),
            ],
          ),

          //----------------------------- DRAWER ---------------------------------
          drawer: Drawer(
            backgroundColor: ConstantColor.whiteColor,
            elevation: 5,
            child: ListView(
              children: [
                Container(
                  height: 100,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, left: 20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          maxRadius: 30,
                          minRadius: 20,
                          backgroundImage: AssetImage(
                              "assets/logo/logo_tuie.png"),
                        ),

                        SizedBox(
                          width: 10,
                        ),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              "Tuié",
                              style: GoogleFonts.quicksand(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ConstantColor.blackColor,
                              ),
                            ),

                            InkWell(
                              onTap: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) => const EditProfileScreen()
                                    //
                                    //ProductPage
                                  ),
                                );
                              },
                              child: Text(
                                "Editar perfil",
                                style: GoogleFonts.quicksand(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: ConstantColor.colorPrimary,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),

                Divider(
                  height: 50,
                  thickness: 10,
                ),

                ListTile(
                  leading: const Icon(Icons.credit_card),
                  title: Text(
                    "Pagamento",
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ConstantColor.blackColor,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => const PaymentScreen()
                        //
                        //ProductPage
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.card_giftcard_outlined),
                  title: Text(
                    "Promoções",
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ConstantColor.blackColor,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => const PromotionScreen()
                        //
                        //ProductPage
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.run_circle_rounded),
                  title: Text(
                    "Minhas Viagens",
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ConstantColor.blackColor,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => const RidersScreen()
                        //
                        //ProductPage
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.question_mark_outlined),
                  title: Text(
                    "Ajuda",
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ConstantColor.blackColor,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => const HelpScreen()
                        //
                        //ProductPage
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: Text(
                    "Sobre Nós",
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ConstantColor.blackColor,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => const AboutUsScreen()
                        //
                        //ProductPage
                      ),
                    );
                  },
                ),
                Divider(
                  height: 50,
                  thickness: 10,
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<void> updateCameraLocation(LatLng source, LatLng destination, GoogleMapController mapController,) async {
    if (mapController == null) return;

    LatLngBounds bounds;

    if (source.latitude > destination.latitude &&
        source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(source.latitude, destination.longitude),
          northeast: LatLng(destination.latitude, source.longitude));
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destination.latitude, source.longitude),
          northeast: LatLng(source.latitude, destination.longitude));
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 70);

    return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }


  //********************* CLIENT DATA RIDE ACEPT ************************ */
  _clientDataRideAcept(String nome_cliente, String desejo, String valor, double latitude, double longitude) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 3,
      //padding: EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.white,
        //border: Border.all(width: 1, color: Colors.black38),
      ),
      child: Column(
        children: [
          //::::::::::::::::::::: CLIENT :::::::::::::::::::::: :/
          Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //------------------- PHOTO CLIENT -------------------- -/
                  Row(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height / 10,
                        width: MediaQuery.of(context).size.width / 5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(300),
                          border:
                          Border.all(width: 1, color: Colors.transparent),
                          image: const DecorationImage(
                              image: AssetImage("assets/images/tuie_comigo.jpg"),
                              fit: BoxFit.fill),
                        ),
                      ),

                      //------------------- SPACE -------------------- -/
                      const SizedBox(
                        width: 10,
                      ),

                      //----------------------- CLIENT NAME --------------------- -/
                      Column(
                        children: [
                          Text(
                            'Tuie',
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),

                          //------------------- SPACE -------------------- -/

                          Text(
                            '948824600',
                            style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),

                        ],
                      ),
                    ],
                  ),

                  //-------------------- PRICE ---------------------- -/
                  Column(
                    children: [
                      Text(
                        valor + ' AOA',
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        //distanceMotoristaCliente.toStringAsFixed(2) +
                            "km",
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          //:::::::::::::::::::::: SPACE :::::::::::::::::::::::: :/
          const SizedBox(
            height: 5,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [

              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on_sharp, color: Colors.green,),

                      Text(
                        'Camama',
                        style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Colors.black
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Icon(Icons.location_on_sharp, color: Colors.red,),

                      Text(
                        'Golf-2',
                        style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Colors.black
                        ),
                      ),
                    ],
                  ),
                ],
              ),


              InkWell(
                onTap: () async {
                  //await FlutterPhoneDirectCaller.callNumber(telefone_cli);
                  //FlutterPhoneDirectCaller.callNumber(telefone_cli);
                  //FlutterPhoneDirectCaller.callNumber(telefone_cli);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.black12,
                          shape: BoxShape.circle
                      ),
                      child: Icon(Icons.call),
                    ),
                    Center(
                      child: Text(
                        'Ligar',
                        style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Colors.black
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            ],
          )
        ],
      ),
    );
  }



  //**************** ADRESS & TIME ************* */
  _adressTimeItem(IconData iconData, String description, Color color) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    Size tamanhoFonte = mediaQuery.size;
    return Container(
      child: Row(
        children: [
          Icon(
            iconData,
            size: 20,
            color: color,
          ),
          SizedBox(
            width: 1,
          ),
          Container(
            width: 120,
            child: Text(
              description,
              style: GoogleFonts.quicksand(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }

  //****************** WITCHES ******************* */
  _witches(String description, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          description,
          style: GoogleFonts.quicksand(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold),
        ),
        Text(
          price,
          style: GoogleFonts.quicksand(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold),
        )
      ],
    );
  }

}


