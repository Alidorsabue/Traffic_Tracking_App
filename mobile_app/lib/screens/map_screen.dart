import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Set<Marker> markers = {};
  GoogleMapController? mapController;
  LatLng? currentPosition;
  bool isLoadingPosition = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    loadPoints();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final result = await Geolocator.requestPermission();
        if (result != LocationPermission.whileInUse && result != LocationPermission.always) {
          setState(() => isLoadingPosition = false);
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
        isLoadingPosition = false;
        
        // Ajouter un marqueur pour la position actuelle
        markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: currentPosition!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: const InfoWindow(title: 'Ma position'),
          ),
        );
      });

      // Centrer la carte sur la position actuelle
      if (mapController != null && currentPosition != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(currentPosition!, 15),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingPosition = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur localisation: ${e.toString()}')),
      );
    }
  }

  Future<void> loadPoints() async {
    try {
      final points = await ApiService.getPoints();
      if (!mounted) return;
      setState(() {
        final gpsMarkers = points
            .where((p) => p is Map<String, dynamic>)
            .map((p) {
              final map = p as Map<String, dynamic>;
              final double lat = (map["latitude"] as num).toDouble();
              final double lon = (map["longitude"] as num).toDouble();
              final double speed = (map["speed"] as num? ?? 0).toDouble();
              final String id = map["id"].toString();
              return Marker(
                markerId: MarkerId(id),
                position: LatLng(lat, lon),
                infoWindow: InfoWindow(title: "Vitesse: ${speed.toStringAsFixed(1)} m/s"),
              );
            })
            .toSet();
        
        // Ajouter les marqueurs GPS et conserver le marqueur de position actuelle
        markers = gpsMarkers;
        if (currentPosition != null) {
          markers.add(
            Marker(
              markerId: const MarkerId('current_location'),
              position: currentPosition!,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
              infoWindow: const InfoWindow(title: 'Ma position'),
            ),
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement points: ${e.toString()}')),
      );
    }
  }

  void _centerOnCurrentLocation() {
    if (currentPosition != null && mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(currentPosition!, 15),
      );
    } else {
      _getCurrentLocation();
    }
  }

  void _zoomIn() {
    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.zoomIn());
    }
  }

  void _zoomOut() {
    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.zoomOut());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Position initiale : position actuelle si disponible, sinon Kinshasa par défaut
    final initialPosition = currentPosition ?? const LatLng(-4.325, 15.322);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/localisation.png',
              height: 32,
              width: 32,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(width: 8),
            const Text("Carte du trafic"),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
          tooltip: 'Retour',
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: currentPosition != null ? 15 : 12,
            ),
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            zoomGesturesEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              // Centrer sur la position actuelle si elle est déjà chargée
              if (currentPosition != null) {
                controller.animateCamera(
                  CameraUpdate.newLatLngZoom(currentPosition!, 15),
                );
              }
            },
          ),
          // Boutons de zoom en haut à droite
          Positioned(
            top: 30,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bouton zoom in (+)
                    GestureDetector(
                      onTap: _zoomIn,
                      child: Container(
                        width: 56,
                        height: 56,
                        color: Colors.white,
                        alignment: Alignment.center,
                        child: const Text(
                          '+',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 1,
                      width: 56,
                      color: Colors.grey.shade300,
                    ),
                    // Bouton zoom out (-)
                    GestureDetector(
                      onTap: _zoomOut,
                      child: Container(
                        width: 56,
                        height: 56,
                        color: Colors.white,
                        alignment: Alignment.center,
                        child: const Text(
                          '−',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bouton pour recentrer sur la position actuelle
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _centerOnCurrentLocation,
              backgroundColor: Colors.blue.shade700,
              tooltip: 'Ma position',
              heroTag: "myLocation",
              child: const Icon(Icons.my_location, color: Colors.white, size: 28),
            ),
          ),
          // Indicateur de chargement
          if (isLoadingPosition)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          // Compteur de marqueurs en haut à gauche (sous l'AppBar)
          Positioned(
            top: 20,
            left: 16,
            child: Card(
              color: Colors.white.withValues(alpha: 0.9),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.place,
                      size: 22,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${markers.length} point${markers.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
