import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // URL du backend configurée au build time via --dart-define=API_BASE_URL
  // Pour émulateur Android: 10.0.2.2
  // Pour appareil physique: IP locale du PC (ex: 192.168.x.x)
  // Pour production: URL du serveur (ex: https://votre-serveur.com)
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.0.121:5000', // IP par défaut pour appareil réel
  );

  static const Duration _timeout = Duration(seconds: 15);
  
  // Méthode pour obtenir l'URL utilisée (pour debug)
  static String get apiUrl => baseUrl;

  static Future<void> sendGps({
    required double latitude,
    required double longitude,
    required double speed,
    String? driverId,
    String? phoneNumber,
  }) async {
    final uri = Uri.parse("$baseUrl/send_gps");
    final payload = {
      if (driverId != null) "driver_id": driverId,
      if (phoneNumber != null) "phone_number": phoneNumber,
      "latitude": latitude,
      "longitude": longitude,
      "speed": speed,
    };

    try {
      final res = await http
          .post(
            uri,
            headers: {HttpHeaders.contentTypeHeader: "application/json"},
            body: jsonEncode(payload),
          )
          .timeout(_timeout);
      if (res.statusCode >= 400) {
        throw HttpException('send_gps failed: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      if (e is HttpException) {
        rethrow;
      }
      // Ajouter l'URL dans le message d'erreur pour debug
      throw Exception('Network error (URL: $baseUrl): $e');
    }
  }

  static Future<List<dynamic>> getPoints() async {
    final uri = Uri.parse("$baseUrl/get_points");
    try {
      final res = await http.get(uri).timeout(_timeout);
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      }
      return <dynamic>[];
    } catch (e) {
      // Retourne une liste vide en cas d'erreur (timeout, réseau, etc.)
      return <dynamic>[];
    }
  }
}
