import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proiectlicenta/pages/home_page.dart';
import 'dart:async';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Location _locationController = new Location();
  LatLng? _currentP = null;
  GoogleMapController? _mapController;
  bool _showPopup = false;
  LatLng? _selectedMarkerPosition;
  String? _selectedMarkerAddress;
  String? _selectedMarkerImagePath;
  Offset _popupOffset = Offset.zero;
  LocationData? _lastLocation;
  double _heading = 0.0;
  BitmapDescriptor? _userArrowIcon;
  Marker? _userMarker;
  Polyline? _routePolyline;

  late final StreamSubscription<LocationData> _locationSubscription;

  @override
  void initState() {
    super.initState();
    getLocationUpdates();
  }

  @override
  void dispose() {
    _locationSubscription.cancel(); // oprește streamul
    _mapController?.dispose(); // oprește controllerul hărții
    super.dispose();
  }

  void didChangeDependencies() {
    super.didChangeDependencies();

    // Rulează o singură dată
    if (_userArrowIcon == null) {
      _loadCustomMarker();
    }
  }

  Future<void> _loadCustomMarker() async {
    final imageConfiguration = createLocalImageConfiguration(context);

    BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(
      imageConfiguration,
      'assets/images/user_arrow.png',
    );

    setState(() {
      _userArrowIcon = icon;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMarkerTapped(LatLng position) async {
    if (_mapController != null) {
      ScreenCoordinate screenCoordinate = await _mapController!
          .getScreenCoordinate(position);
      setState(() {
        _popupOffset = Offset(
          screenCoordinate.x.toDouble(),
          screenCoordinate.y.toDouble(),
        );
        _showPopup = true;
      });
    }
  }

  void _updateUserMarker(LocationData location) {
    final LatLng newPosition = LatLng(location.latitude!, location.longitude!);
    final double newHeading = location.heading ?? 0.0;
    setState(() {
      _userMarker = Marker(
        markerId: MarkerId("user_location"),
        position: newPosition,
        icon: _userArrowIcon ?? BitmapDescriptor.defaultMarker,
        rotation: newHeading,
        anchor: Offset(0.5, 0.5),
        flat: true,
      );
    });
  }

  void _centerUserLocation() {
    if (_mapController != null && _currentP != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentP!,
            zoom: 15, // ajustează zoomul cum vrei
          ),
        ),
      );
    }
  }

  Future<void> _createRoute() async {
    if (_selectedMarkerPosition == null || _currentP == null) return;

    final String apiKey = 'AIzaSyBHW8vaSaBeODBUeOGJmBTjprE-9Nh8jiY';
    final origin =
        '${_selectedMarkerPosition!.latitude},${_selectedMarkerPosition!.longitude}';
    final destination = '${_currentP!.latitude},${_currentP!.longitude}';

    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      final route = data['routes'][0]['overview_polyline']['points'];
      final points = _decodePolyline(route);

      setState(() {
        _routePolyline = Polyline(
          polylineId: PolylineId('route'),
          color: Colors.blue,
          width: 5,
          points: points,
        );
      });
    } else {
      print('Route error: ${data['status']}');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }

  void _clearRoute() {
    setState(() {
      _routePolyline = null;
    });
  }

  static const LatLng _pGooglePlex = LatLng(45.758994, 21.230919);
  static const LatLng _pTicket1Plex = LatLng(
    45.759398703223475,
    21.22839614121234,
  );
  static const LatLng _pTicket2Plex = LatLng(
    45.75639533886752,
    21.224368663400966,
  );
  static const LatLng _pTicket3Plex = LatLng(
    45.75521804423162,
    21.233851093284756,
  );
  static const LatLng _pTicket4Plex = LatLng(
    45.77701663427953,
    21.233377024437676,
  );
  static const LatLng _pTicket5Plex = LatLng(
    45.801366524192495,
    21.24812477690946,
  );
  static const LatLng _pTicket6Plex = LatLng(
    45.75752272463427,
    21.248869245403387,
  );
  static const LatLng _pTicket7Plex = LatLng(
    45.765181957820175,
    21.259810134052156,
  );
  static const LatLng _pTicket8Plex = LatLng(
    45.770425033987536,
    21.30251157175411,
  );
  static const LatLng _pTicket9Plex = LatLng(
    45.71886946874912,
    21.322814152225874,
  );
  static const LatLng _pTicket10Plex = LatLng(
    45.750448820287566,
    21.208442338113475,
  );
  static const LatLng _pTicket11Plex = LatLng(
    45.743933209169064,
    21.23692095188069,
  );
  static const LatLng _pTicket12Plex = LatLng(
    45.74196414286847,
    21.22487749747128,
  );
  static const LatLng _pTicket13Plex = LatLng(
    45.73866554187394,
    21.24078556271889,
  );
  static const LatLng _pTicket14Plex = LatLng(
    45.734528292228546,
    21.237901008709176,
  );
  static const LatLng _pTicket15Plex = LatLng(
    45.740056411415736,
    21.196286625619695,
  );
  static const LatLng _pTicket16Plex = LatLng(
    45.72254129105503,
    21.20069900017259,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
            );
          },
        ),
        title: Text("Hartă stații bilete"),
      ),
      body:
          _currentP == null
              ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo.png', // asigură-te că logo-ul e în folderul corect
                      width: 150,
                      height: 150,
                    ),
                    SizedBox(height: 30),
                    CircularProgressIndicator(),
                  ],
                ),
              )
              : Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _pGooglePlex,
                      zoom: 13,
                    ),
                    onMapCreated: _onMapCreated,
                    onTap: (_) => setState(() => _showPopup = false),
                    markers: {
                      Marker(
                        markerId: MarkerId("user_location"),
                        position: _currentP!,
                        icon: _userArrowIcon ?? BitmapDescriptor.defaultMarker,
                        rotation:
                            _heading, // Heading-ul în grade, între 0 și 360
                        anchor: Offset(0.5, 0.5), // Centrat
                        flat: true, // 🔥 Necesită pentru rotație pe plan 2D
                      ),
                      //Marker(
                      // markerId: MarkerId("_currentlocation"),
                      // icon: BitmapDescriptor.defaultMarkerWithHue(
                      //   BitmapDescriptor.hueBlue,
                      // ),
                      // position: _currentP!,
                      // ),
                      //Marker(
                      // markerId: MarkerId("_initiallocation"),
                      //icon: BitmapDescriptor.defaultMarker,
                      //position: _pGooglePlex,
                      //),
                      Marker(
                        markerId: MarkerId("_sourcelocation"),
                        position: _pTicket1Plex,
                        icon:
                            (_selectedMarkerPosition == _pTicket1Plex)
                                ? BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueGreen,
                                ) // highlight (verde)
                                : BitmapDescriptor.defaultMarker, // normal
                        onTap: () {
                          setState(() {
                            _selectedMarkerPosition = _pTicket1Plex;
                            _selectedMarkerAddress = "Piața Mărăști Timișoara";
                            _selectedMarkerImagePath =
                                "assets/images/_pTicket1Plex_image.jpg";
                            _showPopup = true;
                          });
                        },
                      ),
                      Marker(
                        markerId: MarkerId("_sourcelocation1"),
                        icon:
                            (_selectedMarkerPosition == _pTicket2Plex)
                                ? BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueGreen,
                                ) // highlight (verde)
                                : BitmapDescriptor.defaultMarker, // normal
                        position: _pTicket2Plex,
                        onTap: () {
                          setState(() {
                            _selectedMarkerPosition = _pTicket2Plex;
                            _selectedMarkerAddress =
                                "STPT - Piața 700, Timișoara";
                            _selectedMarkerImagePath =
                                "assets/images/_pTicket2Plex image.jpg";
                            _showPopup = true;
                          });
                        },
                      ),
                      Marker(
                        markerId: MarkerId("_sourcelocation2"),
                        icon:
                            (_selectedMarkerPosition == _pTicket3Plex)
                                ? BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueGreen,
                                ) // highlight (verde)
                                : BitmapDescriptor.defaultMarker, // normal
                        position: _pTicket3Plex,
                        onTap: () {
                          setState(() {
                            _selectedMarkerPosition = _pTicket3Plex;
                            _selectedMarkerAddress =
                                "Bulevardul Ion C. Brătianu 1, Timișoara";
                            _selectedMarkerImagePath =
                                "assets/images/_pTicket3Plex image.jpg";
                            _showPopup = true;
                          });
                        },
                      ),
                      Marker(
                        markerId: MarkerId("_sourcelocation3"),
                        icon:
                            (_selectedMarkerPosition == _pTicket4Plex)
                                ? BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueGreen,
                                ) // highlight (verde)
                                : BitmapDescriptor.defaultMarker, // normal
                        position: _pTicket4Plex,
                        onTap: () {
                          setState(() {
                            _selectedMarkerPosition = _pTicket4Plex;
                            _selectedMarkerAddress =
                                "Strada Dr. Grigore T. Popa 13-1, Timișoara";
                            _selectedMarkerImagePath =
                                "assets/images/_pTicket4Plex image.jpg";
                            _showPopup = true;
                          });
                        },
                      ),
                      Marker(
                        markerId: MarkerId("_sourcelocation4"),
                        icon:
                            (_selectedMarkerPosition == _pTicket5Plex)
                                ? BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueGreen,
                                ) // highlight (verde)
                                : BitmapDescriptor.defaultMarker, // normal
                        position: _pTicket5Plex,
                        onTap: () {
                          setState(() {
                            _selectedMarkerPosition = _pTicket5Plex;
                            _selectedMarkerAddress =
                                "Strada Petőfi Sándor 31, Dumbrăvița";
                            _selectedMarkerImagePath =
                                "assets/images/_pTicket5Plex image.jpg";
                            _showPopup = true;
                          });
                        },
                      ),
                      Marker(
                        markerId: MarkerId("_sourcelocation5"),
                        icon:
                            (_selectedMarkerPosition == _pTicket6Plex)
                                ? BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueGreen,
                                ) // highlight (verde)
                                : BitmapDescriptor.defaultMarker, // normal
                        position: _pTicket6Plex,
                        onTap: () {
                          setState(() {
                            _selectedMarkerPosition = _pTicket6Plex;
                            _selectedMarkerAddress =
                                "Piața Romanilor 1-2, Timișoara";
                            _selectedMarkerImagePath =
                                "assets/images/_pTicket6Plex image.jpg";
                            _showPopup = true;
                          });
                        },
                      ),
                      Marker(
                        markerId: MarkerId("_sourcelocation6"),
                        icon:
                            (_selectedMarkerPosition == _pTicket7Plex)
                                ? BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueGreen,
                                ) // highlight (verde)
                                : BitmapDescriptor.defaultMarker, // normal
                        position: _pTicket7Plex,
                        onTap: () {
                          setState(() {
                            _selectedMarkerPosition = _pTicket7Plex;
                            _selectedMarkerAddress =
                                "Strada Simion Bărnuțiu 75, Timișoara";
                            _selectedMarkerImagePath =
                                "assets/images/_pTicket7Plex image.jpg";
                            _showPopup = true;
                          });
                        },
                      ),
                      Marker(
                        markerId: MarkerId("_sourcelocation7"),
                        icon:
                            (_selectedMarkerPosition == _pTicket8Plex)
                                ? BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueGreen,
                                ) // highlight (verde)
                                : BitmapDescriptor.defaultMarker, // normal
                        position: _pTicket8Plex,
                        onTap: () {
                          setState(() {
                            _selectedMarkerPosition = _pTicket8Plex;
                            _selectedMarkerAddress = "Strada Victoria, Ghiroda";
                            _selectedMarkerImagePath =
                                "assets/images/_pTicket8Plex image.jpg";
                            _showPopup = true;
                          });
                        },
                      ),
                      Marker(
                        markerId: MarkerId("_sourcelocation8"),
                        icon:
                            (_selectedMarkerPosition == _pTicket9Plex)
                                ? BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueGreen,
                                ) // highlight (verde)
                                : BitmapDescriptor.defaultMarker, // normal
                        position: _pTicket9Plex,
                        onTap: () {
                          setState(() {
                            _selectedMarkerPosition = _pTicket9Plex;
                            _selectedMarkerAddress =
                                "Str. Principală 42, Moșnița Nouă";
                            _selectedMarkerImagePath =
                                "assets/images/_pTicket9Plex image.jpg";
                            _showPopup = true;
                          });
                        },
                      ),
                      Marker(
                        markerId: MarkerId("_sourcelocation9"),
                        icon:
                            (_selectedMarkerPosition == _pTicket10Plex)
                                ? BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueGreen,
                                ) // highlight (verde)
                                : BitmapDescriptor.defaultMarker, // normal
                        position: _pTicket10Plex,
                        onTap: () {
                          setState(() {
                            _selectedMarkerPosition = _pTicket10Plex;
                            _selectedMarkerAddress = "Strada Gării, Timișoara";
                            _selectedMarkerImagePath =
                                "assets/images/_pTicket10Plex image.jpg";
                            _showPopup = true;
                          });
                        },
                      ),
                      Marker(
                        markerId: MarkerId("_sourcelocation10"),
                        icon:
                            (_selectedMarkerPosition == _pTicket11Plex)
                                ? BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueGreen,
                                ) // highlight (verde)
                                : BitmapDescriptor.defaultMarker, // normal
                        position: _pTicket11Plex,
                        onTap: () {
                          setState(() {
                            _selectedMarkerPosition = _pTicket11Plex;
                            _selectedMarkerAddress =
                                "Strada Cluj 23, Timișoara";
                            _selectedMarkerImagePath =
                                "assets/images/_pTicket11Plex image.jpg";
                            _showPopup = true;
                          });
                        },
                      ),
                      Marker(
                        markerId: MarkerId("_sourcelocation11"),
                        icon:
                            (_selectedMarkerPosition == _pTicket12Plex)
                                ? BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueGreen,
                                ) // highlight (verde)
                                : BitmapDescriptor.defaultMarker, // normal
                        position: _pTicket12Plex,
                        onTap: () {
                          setState(() {
                            _selectedMarkerPosition = _pTicket12Plex;
                            _selectedMarkerAddress =
                                "Piata Nicolae Balcescu, Strada Gheorghe Doja, Timișoara";
                            _selectedMarkerImagePath =
                                "assets/images/_pTicket12Plex image.jpg";
                            _showPopup = true;
                          });
                        },
                      ),
                      Marker(
                        markerId: MarkerId("_sourcelocation12"),
                        icon:
                            (_selectedMarkerPosition == _pTicket13Plex)
                                ? BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueGreen,
                                ) // highlight (verde)
                                : BitmapDescriptor.defaultMarker, // normal
                        position: _pTicket13Plex,
                        onTap: () {
                          setState(() {
                            _selectedMarkerPosition = _pTicket13Plex;
                            _selectedMarkerAddress = "Str. Arieș, Timișoara";
                            _selectedMarkerImagePath =
                                "assets/images/_pTicket13Plex image.jpg";
                            _showPopup = true;
                          });
                        },
                      ),
                      Marker(
                        markerId: MarkerId("_sourcelocation13"),
                        icon:
                            (_selectedMarkerPosition == _pTicket14Plex)
                                ? BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueGreen,
                                ) // highlight (verde)
                                : BitmapDescriptor.defaultMarker, // normal
                        position: _pTicket14Plex,
                        onTap: () {
                          setState(() {
                            _selectedMarkerPosition = _pTicket14Plex;
                            _selectedMarkerAddress =
                                "Calea Martirilor 1989 29, Timișoara";
                            _selectedMarkerImagePath =
                                "assets/images/_pTicket14Plex image.jpg";
                            _showPopup = true;
                          });
                        },
                      ),
                      Marker(
                        markerId: MarkerId("_sourcelocation14"),
                        icon:
                            (_selectedMarkerPosition == _pTicket15Plex)
                                ? BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueGreen,
                                ) // highlight (verde)
                                : BitmapDescriptor.defaultMarker, // normal
                        position: _pTicket15Plex,
                        onTap: () {
                          setState(() {
                            _selectedMarkerPosition = _pTicket15Plex;
                            _selectedMarkerAddress =
                                "Dep. Tramvaie, Dambovita, Timișoara";
                            _selectedMarkerImagePath =
                                "assets/images/_pTicket15Plex image.jpg";
                            _showPopup = true;
                          });
                        },
                      ),
                      Marker(
                        markerId: MarkerId("_sourcelocation15"),
                        icon:
                            (_selectedMarkerPosition == _pTicket16Plex)
                                ? BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueGreen,
                                ) // highlight (verde)
                                : BitmapDescriptor.defaultMarker, // normal
                        position: _pTicket16Plex,
                        onTap: () {
                          setState(() {
                            _selectedMarkerPosition = _pTicket16Plex;
                            _selectedMarkerAddress = "Calea Șagului, Timișoara";
                            _selectedMarkerImagePath =
                                "assets/images/_pTicket16Plex image.jpg";
                            _showPopup = true;
                          });
                        },
                      ),
                    },
                    polylines: _routePolyline != null ? {_routePolyline!} : {},
                  ),
                  if (_showPopup)
                    Positioned(left: 20, bottom: 100, child: _buildPopup()),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: FloatingActionButton(
                      onPressed: _centerUserLocation,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.my_location, color: Colors.black),
                    ),
                  ),
                  if (_routePolyline != null)
                    Positioned(
                      bottom: 20,
                      left:
                          MediaQuery.of(context).size.width / 2 -
                          70, // centrat orizontal
                      child: ElevatedButton(
                        onPressed: _clearRoute,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text("Șterge ruta"),
                      ),
                    ),
                ],
              ),
    );
  }

  Widget _buildPopup() {
    if (_selectedMarkerPosition == null) return SizedBox.shrink();
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 250,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    _selectedMarkerImagePath ?? 'assets/images/default.jpg',
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMarkerPosition = null;
                        _showPopup = false; // închide pop-up-ul
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              _selectedMarkerAddress ?? 'Adresă necunoscută',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                _createRoute();
              },
              child: Text("Generează rută"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    _serviceEnabled = await _locationController.serviceEnabled();
    if (_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    } else {
      return;
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationController.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 100, // milisecunde
      distanceFilter: 0, // pentru update constant
    );

    _locationSubscription = _locationController.onLocationChanged.listen((
      LocationData currentLocation,
    ) {
      if (!mounted) return;
      if (_lastLocation == null ||
          (currentLocation.latitude! - _lastLocation!.latitude!).abs() >
              0.0001 ||
          (currentLocation.longitude! - _lastLocation!.longitude!).abs() >
              0.0001 ||
          (currentLocation.heading! - _lastLocation!.heading!).abs() > 2) {
        _updateUserMarker(currentLocation);
        setState(() {
          _currentP = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );
          _heading = currentLocation.heading ?? 0.0;
          _lastLocation = currentLocation;
        });
      }
    });
  }
}
