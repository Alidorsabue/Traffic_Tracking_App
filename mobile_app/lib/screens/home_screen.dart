import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'map_screen.dart';
import '../services/api_service.dart';
import '../services/phone_service.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isTracking = false;
  String? _phoneNumber;

  @override
  void initState() {
    super.initState();
    _loadPhoneNumber();
  }

  Future<void> _loadPhoneNumber() async {
    final phone = await PhoneService.getPhoneNumber();
    setState(() {
      _phoneNumber = phone;
    });
  }

  Future<String?> _askForPhoneNumber() async {
    final phoneController = TextEditingController();
    String? result;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Numéro de téléphone'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Veuillez entrer votre numéro de téléphone (10 chiffres)',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  labelText: 'Numéro (10 chiffres)',
                  hintText: '0123456789',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final phone = phoneController.text.trim();
                if (PhoneService.isValidPhoneNumber(phone)) {
                  result = phone.replaceAll(RegExp(r'[^\d]'), '');
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Le numéro doit contenir exactement 10 chiffres'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      final saved = await PhoneService.savePhoneNumber(result!);
      if (saved) {
        setState(() {
          _phoneNumber = result;
        });
        return result;
      }
    }
    return null;
  }

  void startTracking() async {
    // Vérifier le numéro de téléphone
    String? phoneNumber = _phoneNumber;
    if (phoneNumber == null || phoneNumber.isEmpty) {
      phoneNumber = await _askForPhoneNumber();
      if (phoneNumber == null || phoneNumber.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Le numéro de téléphone est requis pour démarrer le tracking'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Vérifier la permission de localisation
    final permission = await Geolocator.checkPermission();
    LocationPermission ensured;
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      ensured = await Geolocator.requestPermission();
      if (ensured == LocationPermission.denied || ensured == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission localisation requise')),
        );
        return;
      }
    }

    setState(() => isTracking = true);
    while (isTracking) {
      try {
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        await ApiService.sendGps(
          latitude: pos.latitude,
          longitude: pos.longitude,
          speed: pos.speed,
          phoneNumber: phoneNumber,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur tracking: ${e.toString()}')),
        );
      }
      await Future.delayed(const Duration(seconds: 10));
    }
  }

  void stopTracking() {
    setState(() => isTracking = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 32,
              width: 32,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(width: 8),
            const Text("Traffic Tracker"),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // Logo principal
                  Image.asset(
                    'assets/images/logo.png',
                    height: 120,
                    width: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback vers icône si logo non trouvé
                      return Icon(
                        Icons.location_on,
                        size: 80,
                        color: Colors.blue.shade700,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Traffic Tracking',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Suivez votre position en temps réel',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // Carte pour le statut
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Image.asset(
                            isTracking ? 'assets/images/position.png' : 'assets/images/localisation.png',
                            height: 60,
                            width: 60,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback vers icône si image non trouvée
                              return Icon(
                                isTracking ? Icons.gps_fixed : Icons.gps_not_fixed,
                                size: 48,
                                color: isTracking ? Colors.green : Colors.grey,
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isTracking ? 'Tracking Actif' : 'Tracking Inactif',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isTracking ? Colors.green : Colors.grey,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Bouton Start/Stop Tracking
                  ElevatedButton.icon(
                    onPressed: isTracking ? stopTracking : startTracking,
                    icon: Image.asset(
                      isTracking ? 'assets/images/position.png' : 'assets/images/localisation.png',
                      height: 28,
                      width: 28,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          isTracking ? Icons.stop_circle : Icons.play_circle_filled,
                          size: 28,
                        );
                      },
                    ),
                    label: Text(
                      isTracking ? "Arrêter le Tracking" : "Démarrer le Tracking",
                      style: const TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isTracking ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Bouton Voir la carte
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MapScreen()),
                      );
                    },
                    icon: Image.asset(
                      'assets/images/position.png',
                      height: 24,
                      width: 24,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.map, size: 24);
                      },
                    ),
                    label: const Text(
                      "Voir la carte",
                      style: TextStyle(fontSize: 18),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
                      side: BorderSide(color: Colors.blue.shade700, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Affichage du numéro de téléphone
                  if (_phoneNumber != null)
                    Card(
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Numéro enregistré:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    PhoneService.formatPhoneNumber(_phoneNumber!),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final newPhone = await _askForPhoneNumber();
                                if (newPhone != null) {
                                  setState(() {
                                    _phoneNumber = newPhone;
                                  });
                                }
                              },
                              tooltip: 'Modifier le numéro',
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Card(
                      color: Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.phone, color: Colors.orange),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Aucun numéro enregistré',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final phone = await _askForPhoneNumber();
                                if (phone != null) {
                                  setState(() {
                                    _phoneNumber = phone;
                                  });
                                }
                              },
                              child: const Text('Ajouter'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  // Info API (cachée dans un expansion tile pour ne pas gêner)
                  ExpansionTile(
                    title: const Text(
                      'Informations techniques',
                      style: TextStyle(fontSize: 12),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'API: ${ApiService.apiUrl}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
